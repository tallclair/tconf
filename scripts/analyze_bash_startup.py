#!/usr/bin/env python3
import sys
import re
import subprocess
import os

LOG_FILE = "/tmp/bash_startup.log"

def generate_log():
    print("Generating startup log...")
    # We set SHELL to fish to avoid the bashrc switching to fish immediately
    cmd = [
        "env",
        "SHELL=/usr/bin/fish",
        "PS4=+$(date \"+%s.%N\") ",
        "bash",
        "-i",
        "-x",
        "-c",
        "exit"
    ]
    
    # Using shell=True to handle the env vars and redirection easily, 
    # or better yet, construct the command string for shell execution to handle stderr redirection.
    command_str = "env SHELL=/usr/bin/fish PS4='+$(date \"+%s.%N\") ' bash -i -x -c exit"
    
    with open(LOG_FILE, "w") as f:
        subprocess.run(command_str, shell=True, stderr=f, stdout=subprocess.DEVNULL)
    print(f"Log written to {LOG_FILE}")

def analyze(filename):
    if not os.path.exists(filename):
        print(f"Error: {filename} not found.")
        return

    with open(filename, 'r') as f:
        lines = f.readlines()

    entries = []
    # Regex to capture timestamp and command
    # Pattern: +<timestamp> <command>
    for line in lines:
        match = re.match(r'^([+]+)([0-9]+\.[0-9]+)\s+(.*)$', line)
        if match:
            depth = len(match.group(1))
            ts = float(match.group(2))
            cmd = match.group(3)
            entries.append({'ts': ts, 'cmd': cmd, 'depth': depth, 'line': line.strip()})
    
    if not entries:
        print("No timestamped entries found.")
        return

    parsed_count = len(entries)
    start_time = entries[0]['ts']
    end_time = entries[-1]['ts']
    total_time = end_time - start_time
    
    print(f"Parsed {parsed_count} entries.")
    print(f"Total Time: {total_time:.6f}s")
    
    # Calculate inclusive duration for all entries
    # inclusive_duration = time until the next command at the same or lower depth
    command_durations = []
    
    for i in range(len(entries)):
        entry = entries[i]
        depth = entry['depth']
        
        # Find the end of this block
        end_ts = end_time
        end_index = len(entries)
        
        for j in range(i + 1, len(entries)):
            if entries[j]['depth'] <= depth:
                end_ts = entries[j]['ts']
                end_index = j
                break
        
        # If we didn't find a next command at <= depth, end_ts remains the last timestamp
        if end_index == len(entries) and len(entries) > 0:
             end_ts = entries[-1]['ts']

        duration = end_ts - entry['ts']
        command_durations.append({
            'index': i,
            'duration': duration,
            'cmd': entry['cmd'],
            'depth': depth,
            'end_index': end_index,
            'ts': entry['ts']
        })
    
    # Sort by duration descending
    command_durations.sort(key=lambda x: x['duration'], reverse=True)

    print("\nTop 20 Slowest Steps (Inclusive):")
    
    shown_indices = []
    count = 0
    
    for item in command_durations:
        if count >= 20:
            break
            
        # Check if this item is a child of any already shown item
        is_hidden_child = False
        for parent_idx in shown_indices:
            # Find the parent in our list
            parent_item = next(p for p in command_durations if p['index'] == parent_idx)
            
            # Check if nested
            if parent_item['index'] < item['index'] < parent_item['end_index']:
                # It is a child. 
                # Determine if the parent is allowed to hide it.
                
                parts = parent_item['cmd'].split()
                cmd_name = parts[0] if parts else ""
                
                # 1. Only source, ., and eval can hide children
                is_container = cmd_name in ['.', 'source', 'eval']
                
                if not is_container:
                    # Parent cannot hide child (e.g. [[ ... ]])
                    continue
                
                # 2. TCONF sources do NOT hide children (drill-down)
                is_tconf_source = False
                if cmd_name in ['.', 'source']:
                    if '/tconf/' in parent_item['cmd']:
                        is_tconf_source = True
                
                if is_tconf_source:
                    # Parent explicitly allows showing children
                    continue
                
                # Otherwise, the parent hides the child
                is_hidden_child = True
                break
        
        if is_hidden_child:
            continue

        shown_indices.append(item['index'])
        percentage = (item['duration'] / total_time) * 100
        print(f"{count+1:2d}. {item['duration']:8.6f}s ({percentage:5.2f}%): {item['cmd']}")
        count += 1

if __name__ == "__main__":
    generate_log()
    analyze(LOG_FILE)
