# TConf

TConf is a custom dotfile configuration repository designed to support a shared set of configurations across multiple environments (Workstation, Laptop, Personal Mac, Linux Desktop).

It uses a **layered configuration** approach to maximize code sharing while allowing for device-specific overrides and private secrets.

## Architecture

The configuration is built from three distinct layers:

1. **Shared (Top Level)**: Common configurations applicable to all environments (e.g., standard aliases, global git config, emacs setup).

2. **Device Specific (`devices/`)**: Configurations unique to a specific machine. During setup, the specific device folder is aliased to `local/`.

3. **Private (`priv/` or `secret/`)**: Settings that should not be published to GitHub (e.g., specific tokens, private env vars).

### Merging Strategy

TConf prefers **native merging** where supported by the tool (e.g., `.gitconfig` [include] directives).

For tools that do not support native inclusions, TConf uses a custom **Generation** approach. It concatenates separate configuration modules (e.g., `bashrc` + `aliases` + `vars`) into a single file and links it to the home directory. These generated files are marked as read-only to prevent accidental edits that would be overwritten.

## Directory Structure

```
~/tconf/
├── devices/          # Machine-specific configurations
│   ├── desktop/
│   ├── macbook/
│   └── work_desk/
├── shell/            # Shared shell configs (bash, zsh, aliases)
├── git/              # Shared git configs
├── i3/               # Shared window manager configs
├── emacs/            # Shared editor configs
├── lib/              # Core logic (homemaker.sh)
├── scripts/          # Utility scripts
└── setup.sh          # Main installation entry point
```

## Installation

1. Clone the repository to `~/tconf`:

   ```
   git clone [https://github.com/yourusername/tconf.git](https://github.com/yourusername/tconf.git) ~/tconf
   ```

2. Run the setup script with the target device name:

   ```
   export DEVICE=desktop  # Must match a folder in tconf/devices/
   ~/tconf/setup.sh
   ```

## How It Works: "Homemaker"

The core logic resides in `lib/homemaker.sh`. It provides functions to manage symlinks and file generation safely.

### Key Functions

* **`hml <source> <dest>`** (Home Link)

  * Creates a standard symlink from the source in `tconf` to the destination in `$HOME`.

  * *Example:* Linking `.i3/config`.

* **`hmrol <source> <dest>`** (Read-Only Link)

  * Copies the source to a generation directory, marks it read-only, and links the destination to that generated file.

  * Used for single files that shouldn't be edited directly in `$HOME`.

* **`hmgl <dest> <separator_comment> <source1> <source2>...`** (Generate Link)

  * Concatenates multiple source files into a single output file.

  * Checks modification times to avoid unnecessary writes.

  * *Example:* Building `.Xresources` from `base`, `font`, and `theme`.

## Management

* **Update Configs**: Run `scripts/update-config.sh` to refresh generated files and links.

* **Private Configs**: Place private files in `priv/` (gitignored). The setup script will automatically look for and source files in `priv/` if they mirror the structure of the shared config.
