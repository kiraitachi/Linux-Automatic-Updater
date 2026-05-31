# Linux-Automatic-Updater
<p align="center">
  <img src="https://github.com/kiraitachi/Linux-Automatic-Updater/blob/main/LinuxAutomaticUpdater.png">
</p>

# auto-update.sh

A single-file Bash script that detects your Linux distribution, runs the appropriate package updates, and optionally schedules them to run automatically via cron.

## Features

- **Automatic distro detection** — works across Debian, Ubuntu, Alpine, Arch, Fedora, RHEL, openSUSE, Gentoo, Void, Solus, NixOS, and many derivatives.
- **One-command updates** — runs the correct package manager for your system without manual configuration.
- **Built-in cron scheduler** — schedule daily auto-updates interactively or via CLI flags.
- **Colorized terminal output** and optional logging to `/var/log/auto-update.log`.
- **Safe execution** — uses `set -euo pipefail` and validates all user input.

## Supported Distributions

| Distro Family | Detected IDs | Package Manager |
|---------------|--------------|-----------------|
| Debian-based | `debian`, `ubuntu`, `linuxmint`, `pop`, `elementary`, `zorin`, `kali`, `parrot`, `mx` | `apt` |
| Alpine | `alpine` | `apk` |
| Arch-based | `arch`, `manjaro`, `endeavouros`, `garuda`, `artix` | `pacman` / `yay` / `paru` |
| RHEL-based | `fedora`, `rhel`, `centos`, `rocky`, `almalinux`, `oracle`, `scientific` | `dnf` / `yum` |
| SUSE | `opensuse*`, `suse*` | `zypper` |
| Gentoo | `gentoo`, `funtoo`, `calculate` | `emerge` |
| Void | `void` | `xbps` |
| Solus | `solus` | `eopkg` |
| NixOS | `nixos` | `nix` |

## Installation

1. Download or copy `auto-update.sh` to your machine.
2. Make it executable:
   ```bash
   chmod +x /home/kira/auto-update.sh
   ```

## Usage

```bash
./auto-update.sh [OPTION]
```

### Options

| Option | Description |
|--------|-------------|
| *(no args)* | Detect OS, run updates, and interactively prompt to schedule a cron job |
| `--run-auto` | Run updates silently and log to `/var/log/auto-update.log` (intended for cron) |
| `--schedule HH:MM` | Schedule a daily cron job at the specified 24-hour time |
| `--unschedule` | Remove the existing auto-update cron job |
| `--help`, `-h` | Show help text and exit |

### Examples

**Run updates interactively**
```bash
./auto-update.sh
```

**Run updates and schedule them daily at 02:30**
```bash
./auto-update.sh --schedule 02:30
```

**Run updates silently (useful in a cron/systemd context)**
```bash
./auto-update.sh --run-auto
```

**Remove the scheduled cron job**
```bash
./auto-update.sh --unschedule
```

## Cron Scheduling

When you run `./auto-update.sh` with no arguments, the script will prompt you for a daily update time in `HH:MM` format. Enter a time (e.g., `02:30`) or type `skip` to disable automatic scheduling.

The cron entry is added to the current user's crontab. You can verify it with:
```bash
crontab -l
```

If you schedule as root, the script runs with root privileges automatically. If running as a regular user, ensure the user has passwordless sudo or run the script under root.

## Logging

When executed with `--run-auto`, all output is appended to:
```
/var/log/auto-update.log
```

Each run logs a timestamp and the detected distribution name.

## Requirements

- Bash 4.x or later
- Root privileges (or passwordless sudo) for most package managers
- `cron` installed and running if you use the scheduling features

## Notes

- The script uses `set -euo pipefail` for strict error handling.
- On Arch-based systems, it prefers `yay` or `paru` if installed, falling back to `pacman`.
- On RHEL-based systems, it prefers `dnf` over `yum` when available.
- Colorized output is automatically suppressed when not attached to a TTY.

## Important Note

- Automatic package updates can be convenient, but they should be used with caution, especially in production environments. Before enabling automatic updates, ensure you have proper backups and understand the potential risks of automatic upgrades.

## License

This script is released under the [MIT License](LICENSE). Feel free to use, modify, and distribute it according to the terms of the license.
