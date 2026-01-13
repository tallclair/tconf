#!/usr/bin/env -S uv run --script
# /// script
# dependencies = [
#   "rich",
# ]
# ///

import argparse
import concurrent.futures
import re
import shutil
import subprocess
import sys
from collections import defaultdict
from typing import Optional

from rich.console import Console
from rich.prompt import Confirm
from rich.progress import Progress, SpinnerColumn, TextColumn, BarColumn, TaskProgressColumn
from rich.table import Table
from rich import box

# --- Configuration ---
# Matches standard protected branch names
PROTECTED_PATTERN = re.compile(r"^(master|main|dev|devel|development|trunk|release-.*)$")
console = Console(highlight=False)

class GitCleanup:
    def __init__(self, dry_run: bool, non_interactive: bool, skip_gh: bool):
        self.dry_run = dry_run
        self.non_interactive = non_interactive
        self.skip_gh = skip_gh
        
        self.worktree_branches: dict[str, str] = {}
        self.skipped_worktrees: list[str] = []
        self.upstream_remote = "upstream"
        self.main_branch = "main"
        self.default_target_ref = ""
        
        # Cache for branch info: name -> upstream_ref
        self.branch_upstreams: dict[str, str] = {}

    def run_cmd(self, cmd: list[str], check: bool = False) -> subprocess.CompletedProcess:
        """Run a shell command with consistent encoding handling."""
        return subprocess.run(
            cmd,
            text=True,
            capture_output=True,
            check=check
        )
    
    def style_branch(self, name: str) -> str:
        from rich.markup import escape
        return f"[bold cyan]{escape(name)}[/bold cyan]"

    def section(self, title: str):
        console.print(f"\n[bold]{title}[/bold]")

    def log(self, message: str, style: str = ""):
        console.print(message, style=style)

    def warn(self, message: str):
        console.print(f"[yellow]Warning:[/yellow] {message}")

    def error(self, message: str):
        console.print(f"[bold red]Error:[/bold red] {message}")

    def success(self, message: str):
        console.print(f"[green]{message}[/green]")

    def confirm_action(self, prompt: str) -> bool:
        if self.non_interactive:
            return True
        return Confirm.ask(prompt, default=False)

    # --- Git Helpers ---

    def detect_upstream_remote(self):
        """Auto-detect upstream remote (upstream > origin)."""
        proc = self.run_cmd(["git", "remote"])
        if proc.returncode == 0:
            remotes = set(proc.stdout.splitlines())
            if "upstream" in remotes:
                self.upstream_remote = "upstream"
            elif "origin" in remotes:
                self.upstream_remote = "origin"

    def load_worktrees(self):
        """Map branches checked out in any worktree to their paths."""
        proc = self.run_cmd(["git", "worktree", "list", "--porcelain"])
        if proc.returncode != 0:
            return

        current_path = ""
        for line in proc.stdout.splitlines():
            if line.startswith("worktree "):
                current_path = line.split(" ", 1)[1]
            elif line.startswith("branch refs/heads/"):
                branch = line.split("refs/heads/", 1)[1]
                self.worktree_branches[branch] = current_path

    def load_local_branches(self) -> list[str]:
        """Load local branches and their immediate upstreams."""
        # format: refname:short|upstream
        proc = self.run_cmd(["git", "branch", "--format=%(refname:short)|%(upstream)"])
        candidates = []
        for line in proc.stdout.splitlines():
            if not line.strip(): continue
            parts = line.split("|", 1)
            branch = parts[0]
            upstream = parts[1] if len(parts) > 1 else ""
            
            if not PROTECTED_PATTERN.match(branch):
                candidates.append(branch)
                if upstream:
                    self.branch_upstreams[branch] = upstream
        
        return candidates

    def resolve_ultimate_upstream(self, branch: str) -> Optional[str]:
        """
        Recursively resolve upstream to a remote branch.
        Uses in-memory cache populated by load_local_branches.
        """
        seen = {branch}
        current = branch
        
        # Max depth implicit by loop detection
        while True:
            upstream = self.branch_upstreams.get(current)
            if not upstream:
                return None
            
            if upstream.startswith("refs/remotes/"):
                return upstream
            
            if upstream.startswith("refs/heads/"):
                next_branch = upstream.replace("refs/heads/", "")
                if next_branch in seen:
                    return None # Cycle detected
                seen.add(next_branch)
                current = next_branch
                continue
            
            # Unknown ref type
            return None

    def delete_branch(self, branch: str, reason: str, force: bool = False):
        if branch in self.worktree_branches:
            wt_path = self.worktree_branches[branch]
            self.skipped_worktrees.append(f"{self.style_branch(branch)} [grey70]({wt_path})[/grey70]")
            return

        if self.dry_run:
            self.log(f"[dim]Would delete {self.style_branch(branch)} ({reason})[/dim]")
        else:
            cmd = ["git", "branch", "-D" if force else "-d", branch]
            proc = self.run_cmd(cmd)
            if proc.returncode == 0:
                self.success(f"Deleted {self.style_branch(branch)} ({reason})")
            else:
                self.warn(f"Failed to delete {self.style_branch(branch)}:\n{proc.stderr.strip()}")

    def _check_gh_pr(self, branch: str) -> Optional[dict]:
        """Check GitHub PR status for a single branch. Returns info dict if actionable."""
        # 1. Try to extract ID from branch name
        pr_number = None
        match = re.search(r"(?:^|/)(\d+)(?:-|$)", branch)
        if match:
             # simple heuristic: if a number is prominent, treat as PR number
             # e.g. pr/123, 123-fix, fix-123
             m1 = re.search(r"pr/[^/]+/(\d+)", branch)
             m2 = re.match(r"^(\d+)-", branch)
             if m1: pr_number = m1.group(1)
             elif m2: pr_number = m2.group(1)

        state = ""
        url = ""
        number = ""

        if pr_number:
            # Check specific PR
            cmd = ["gh", "pr", "view", pr_number, "--json", "state,url", "--jq", ".state + \" \" + .url"]
            proc = self.run_cmd(cmd)
            if proc.returncode == 0:
                parts = proc.stdout.strip().split(" ")
                if len(parts) >= 2:
                    state, url = parts[0], parts[1]
                    number = pr_number
        else:
            # Find PR by branch head
            cmd = ["gh", "pr", "list", "--head", branch, "--state", "all", "--json", "number,state,url", "--jq", ".[0] | \"\\(.number) \\(.state) \\(.url)\""]
            proc = self.run_cmd(cmd)
            if proc.returncode == 0:
                out = proc.stdout.strip()
                if out and out != "null":
                    parts = out.split(" ")
                    if len(parts) >= 3:
                        number, state, url = parts[0], parts[1], parts[2]

        if state in ("MERGED", "CLOSED"):
            return {
                "branch": branch,
                "number": number,
                "state": state,
                "url": url
            }
        return None

    # --- Phases ---

    def phase_setup(self):
        if self.run_cmd(["git", "rev-parse", "--git-dir"]).returncode != 0:
            self.error("Not a git repository.")
            sys.exit(1)

        self.detect_upstream_remote()
        self.load_worktrees()

        console.print(f"Fetching [bold cyan]{self.upstream_remote}[/bold cyan]...")
        self.run_cmd(["git", "fetch", "-p", self.upstream_remote])

        # Resolve main branch
        if shutil.which("git-default-branch"):
            proc = self.run_cmd(["git-default-branch", self.upstream_remote])
            if proc.returncode == 0:
                self.main_branch = proc.stdout.strip()
        
        self.default_target_ref = f"refs/remotes/{self.upstream_remote}/{self.main_branch}"

    def phase_untracked(self, candidates: list[str]) -> dict[str, list[str]]:
        self.section("1. Upstream Configuration")
        
        untracked = []
        target_groups = defaultdict(list)
        
        for branch in candidates:
            target = self.resolve_ultimate_upstream(branch)
            
            # Map to default if no upstream or upstream is not a protected base
            is_protected_target = False
            if target:
                short_target = target.split('/')[-1]
                if PROTECTED_PATTERN.match(short_target):
                    is_protected_target = True

            if not target or not is_protected_target:
                if not target:
                    untracked.append(branch)
                target = self.default_target_ref
            
            target_groups[target].append(branch)

        if untracked:
            console.print(f"Found {len(untracked)} branches with no upstream tracking:")
            for b in untracked:
                console.print(f"  - {self.style_branch(b)}")
            
            if self.confirm_action(f"Set these to track {self.default_target_ref.replace('refs/remotes/', '')}?"):
                remote_branch = self.default_target_ref.replace("refs/remotes/", "")
                for b in untracked:
                    if self.dry_run:
                        self.log(f"[dim]Would set upstream for {self.style_branch(b)}[/dim]")
                    else:
                        self.run_cmd(["git", "branch", "-u", remote_branch, b])
                        self.success(f"Updated {self.style_branch(b)}")
        else:
            self.success("All branches have valid tracking targets.")
        
        return target_groups

    def phase_strict_merge(self, target_groups: dict[str, list[str]]) -> set[str]:
        self.section("2. Strict Merge Cleanup")
        processed = set()
        merged_count = 0

        for target, branches in target_groups.items():
            if self.run_cmd(["git", "rev-parse", "--verify", target]).returncode != 0:
                continue

            # Check merged branches
            proc = self.run_cmd(["git", "branch", "--merged", target])
            merged_output = {line.strip().lstrip("*+ ") for line in proc.stdout.splitlines()}

            for branch in branches:
                if branch in merged_output:
                    target_short = target.replace("refs/remotes/", "")
                    self.delete_branch(branch, f"Merged into {target_short}")
                    processed.add(branch)
                    merged_count += 1
        
        if merged_count == 0:
            self.log("No strictly merged branches found.")
        
        self.report_skipped()
        return processed

    def phase_pr_cleanup(self, candidates: list[str], processed: set[str]):
        self.section("3. PR State Cleanup")
        
        if self.skip_gh or not shutil.which("gh"):
            reason = "requested" if self.skip_gh else "'gh' CLI not found"
            self.log(f"Skipping PR status check ({reason}).")
            return

        to_check = [b for b in candidates if b not in processed]
        if not to_check:
            self.log("No additional branches to check.")
            return

        pr_details = []

        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            BarColumn(),
            TaskProgressColumn(),
            console=console
        ) as progress:
            task = progress.add_task("Checking GitHub status...", total=len(to_check))
            
            # Parallelize GH calls
            with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
                future_to_branch = {executor.submit(self._check_gh_pr, b): b for b in to_check}
                for future in concurrent.futures.as_completed(future_to_branch):
                    result = future.result()
                    if result:
                        pr_details.append(result)
                    progress.advance(task)

        if pr_details:
            table = Table(title="Finished PRs", box=box.SIMPLE)
            table.add_column("Branch", style="bold cyan")
            table.add_column("PR", style="magenta")
            table.add_column("State", style="bold")
            table.add_column("URL", style="dim")

            for item in pr_details:
                state_style = "green" if item["state"] == "MERGED" else "red"
                table.add_row(
                    item["branch"],
                    f"#{item['number']}",
                    f"[{state_style}]{item['state']}[/{state_style}]",
                    item["url"]
                )
            
            console.print(table)
            
            if self.confirm_action("Delete these branches?"):
                for item in pr_details:
                    self.delete_branch(item["branch"], f"PR #{item['number']} is {item['state']}", force=True)
                    processed.add(item["branch"])
                self.report_skipped()
        else:
            self.log("No merged/closed PR branches found.")

    def phase_duplicates(self):
        self.section("4. Duplicate Branches")
        
        proc = self.run_cmd(["git", "for-each-ref", "--format=%(objectname) %(refname:short)", "refs/heads"])
        hash_map = defaultdict(list)
        for line in proc.stdout.splitlines():
            parts = line.split(" ", 1)
            if len(parts) == 2:
                sha, branch = parts
                hash_map[sha].append(branch)

        has_dupes = False
        for sha, branches in hash_map.items():
            if len(branches) > 1:
                # Check if any branch in this group is NOT protected
                unprotected = [b for b in branches if not PROTECTED_PATTERN.match(b)]
                if not unprotected:
                    continue # All are protected, ignore (e.g. main & release)

                has_dupes = True
                console.print(f"[bold]Commit {sha}:[/bold]")
                for b in branches:
                    console.print(f"  - {self.style_branch(b)}")
                console.print("")

        if not has_dupes:
            self.success("No duplicate branches found.")

    def report_skipped(self):
        if self.skipped_worktrees:
            self.warn("The following branches are eligible for deletion but are checked out:")
            for entry in self.skipped_worktrees:
                console.print(f"  - {entry}")
            self.skipped_worktrees = []

    def execute(self):
        self.phase_setup()
        
        candidates = self.load_local_branches()
        target_groups = self.phase_untracked(candidates)
        processed = self.phase_strict_merge(target_groups)
        self.phase_pr_cleanup(candidates, processed)
        self.phase_duplicates()

def main():
    parser = argparse.ArgumentParser(description="Clean up local git branches.")
    parser.add_argument("-y", "--yes", action="store_true", help="Non-interactive mode")
    parser.add_argument("-n", "--dry-run", action="store_true", help="Dry run")
    parser.add_argument("-s", "--skip-gh", action="store_true", help="Skip GitHub PR checks")
    
    args = parser.parse_args()
    
    cleaner = GitCleanup(args.dry_run, args.yes, args.skip_gh)
    try:
        cleaner.execute()
    except KeyboardInterrupt:
        console.print("\n[bold red]Aborted by user.[/bold red]")
        sys.exit(130)

if __name__ == "__main__":
    main()
