#!/usr/bin/env bash

# auto-update.sh — Detect Linux distro, run updates, and optionally schedule them via cron.
# Supports Debian, Ubuntu, Alpine, Arch Linux, Fedora, RHEL, CentOS, openSUSE, Gentoo, etc.

set -euo pipefail

SCRIPT_PATH="$(realpath "$0")"
LOGFILE="/var/log/auto-update.log"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

###############################################################################
# Distro Detection
###############################################################################

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        echo "$ID" | tr '[:upper:]' '[:lower:]'
    elif command -v lsb_release &>/dev/null; then
        lsb_release -si | tr '[:upper:]' '[:lower:]'
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/alpine-release ]]; then
        echo "alpine"
    else
        echo "unknown"
    fi
}

###############################################################################
# Update Commands by Distro
###############################################################################

run_updates() {
    local distro="$1"
    local pkg_manager=""
    local update_cmd=""

    echo -e "${CYAN}Detected distribution:${NC} ${BOLD}$distro${NC}"
    echo "---"

    case "$distro" in
        debian|ubuntu|linuxmint|pop|elementary|zorin|kali|parrot|mx)
            pkg_manager="apt"
            update_cmd="apt update && DEBIAN_FRONTEND=noninteractive apt upgrade -y && apt autoremove -y"
            ;;
        alpine)
            pkg_manager="apk"
            update_cmd="apk update && apk upgrade"
            ;;
        arch|manjaro|endeavouros|garuda|artix)
            pkg_manager="pacman"
            if command -v yay &>/dev/null; then
                update_cmd="yay -Syu --noconfirm"
            elif command -v paru &>/dev/null; then
                update_cmd="paru -Syu --noconfirm"
            else
                update_cmd="pacman -Syu --noconfirm"
            fi
            ;;
        fedora|rhel|centos|rocky|almalinux|oracle|scientific)
            if command -v dnf &>/dev/null; then
                pkg_manager="dnf"
                update_cmd="dnf update -y"
            else
                pkg_manager="yum"
                update_cmd="yum update -y"
            fi
            ;;
        opensuse*|suse*)
            pkg_manager="zypper"
            update_cmd="zypper refresh && zypper update -y"
            ;;
        gentoo|funtoo|calculate)
            pkg_manager="emerge"
            update_cmd="emerge --sync && emerge -uDU @world"
            ;;
        void)
            pkg_manager="xbps"
            update_cmd="xbps-install -Su"
            ;;
        solus)
            pkg_manager="eopkg"
            update_cmd="eopkg upgrade -y"
            ;;
        nixos)
            pkg_manager="nix"
            update_cmd="nixos-rebuild switch --upgrade"
            ;;
        *)
            echo -e "${RED}Unsupported or unknown distribution: $distro${NC}"
            echo "You can manually add support by editing the run_updates function."
            exit 1
            ;;
    esac

    echo -e "${GREEN}Using package manager:${NC} ${BOLD}$pkg_manager${NC}"
    echo -e "${GREEN}Update command:${NC} $update_cmd"
    echo "---"

    # Run updates
    if ! eval "$update_cmd"; then
        echo -e "${RED}ERROR: Update command failed.${NC}"
        exit 1
    fi

    echo -e "${GREEN}Updates completed successfully!${NC}"
}

###############################################################################
# Logging & Notifications
###############################################################################

log_update() {
    local distro="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] Updated $distro" | tee -a "$LOGFILE" 2>/dev/null || true
}

###############################################################################
# Cron Scheduling
###############################################################################

setup_cron() {
    local time_str="$1"
    local hour minute cron_entry

    # Validate HH:MM format
    if ! [[ "$time_str" =~ ^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$ ]]; then
        echo -e "${RED}Invalid time format. Please use HH:MM (24-hour format).${NC}"
        return 1
    fi

    hour="${time_str%%:*}"
    minute="${time_str##*:}"

    # Ensure two-digit hour
    printf -v hour '%02d' "$hour"

    cron_entry="$minute $hour * * * $SCRIPT_PATH --run-auto"

    # Remove any existing entries for this script
    (crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH --run-auto" || true) > /tmp/crontab.tmp

    # Add new entry
    echo "$cron_entry" >> /tmp/crontab.tmp

    # Install new crontab
    if crontab /tmp/crontab.tmp; then
        rm -f /tmp/crontab.tmp
        echo -e "${GREEN}Cron job scheduled.${NC}"
        echo -e "Your system will auto-update daily at ${BOLD}$hour:$minute${NC}."
        echo -e "Run ${CYAN}crontab -l${NC} to verify."
    else
        rm -f /tmp/crontab.tmp
        echo -e "${RED}Failed to install crontab. Make sure cron is installed and running.${NC}"
        return 1
    fi
}

remove_cron() {
    (crontab -l 2>/dev/null | grep -v "$SCRIPT_PATH --run-auto" || true) > /tmp/crontab.tmp
    crontab /tmp/crontab.tmp
    rm -f /tmp/crontab.tmp
    echo -e "${GREEN}Auto-update cron job removed.${NC}"
}

###############################################################################
# Interactive Prompt
###############################################################################

prompt_time() {
    while true; do
        echo
        echo -n -e "${CYAN}Enter the time for daily auto-updates (HH:MM, 24h) or 'skip' to disable: ${NC}"
        read -r user_time

        if [[ "$user_time" =~ ^[Ss]kip$ ]]; then
            echo "No automatic updates will be scheduled."
            remove_cron 2>/dev/null || true
            break
        elif [[ "$user_time" =~ ^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$ ]]; then
            setup_cron "$user_time"
            break
        else
            echo -e "${RED}Invalid format. Example: 02:30 or 14:00. Use 24-hour format.${NC}"
        fi
    done
}

###############################################################################
# Main Entry Points
###############################################################################

print_help() {
    cat <<EOF
Usage: auto-update.sh [OPTIONS]

  (no args)          Detect OS, run updates, and prompt to schedule
  --run-auto         Run updates silently (for cron/systemd timer)
  --schedule TIME    Schedule daily updates at TIME (HH:MM)
  --unschedule       Remove the auto-update cron job
  --help             Show this help message

Supported distros: Debian, Ubuntu, Mint, Pop!_OS, Zorin, Kali, Alpine,
Arch, Manjaro, EndeavourOS, Fedora, RHEL, CentOS, Rocky, AlmaLinux,
openSUSE, Gentoo, Void, Solus, NixOS, and more.
EOF
}

main() {
    local distro
    distro=$(detect_distro)

    case "${1:-}" in
        --run-auto)
            # Silent/background mode for cron
            {
                echo "=== Auto-Update Started: $(date) ==="
                run_updates "$distro"
                log_update "$distro"
                echo "=== Finished: $(date) ==="
                echo
            } >> "$LOGFILE" 2>&1
            ;;
        --schedule)
            if [[ -z "${2:-}" ]]; then
                echo "Usage: --schedule HH:MM"
                exit 1
            fi
            setup_cron "$2"
            ;;
        --unschedule)
            remove_cron
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        "")
            # Interactive mode
            echo -e "${BOLD}=====================================${NC}"
            echo -e "${BOLD}   Linux Auto-Update Script${NC}"
            echo -e "${BOLD}=====================================${NC}"
            echo
            run_updates "$distro"
            log_update "$distro"
            echo
            prompt_time
            echo
            echo -e "${GREEN}All done!${NC}"
            ;;
        *)
            echo "Unknown option: $1"
            print_help
            exit 1
            ;;
    esac
}

main "$@"
