# Linux-Automatic-Updater
<p align="center">
  <img src="https://github.com/kiraitachi/PyShieldGUI/blob/main/Pyshield.png">
</p>

This is an automatic update script to update all your Debian and RHEL machines automatically. Alternative for unnatended-upgrades if you find this complicated to configure, specially for external repositories.

I have scripted all the steps within the `Debian-auto-package-update.sh` or `RHEL-auto-package-update.sh` based on your Distro, so you should only run this script and all below steps will be automatically configured. Enjoy!

# Auto Package Update Script

The `auto-package-update.sh` script is a bash script that automates the process of updating packages on a Debian and RHEL based systems, ensuring that the system stays up to date with the latest security patches and bug fixes. Also patches any package in external repositories within /etc/apt/sources.list.d

# Compatibility
The script has been tested and verified to work on the following systems:

* Proxmox Virtual Environment (PVE): Proxmox VE is an open-source virtualization platform based on Debian. The script has been tested and verified to work on Proxmox VE systems.

* Raspberry Pi with Debian Bullseye: The script has been tested and verified to work on Raspberry Pi devices running the Debian Bullseye operating system.

* Debian Bookworm: The script has been tested and verified to work on systems running Debian Bookworm, the codename for Debian's testing distribution.

* CentOS Stream 9: The script has been tested and verified to work on CentOS Stream 9, a rolling release distribution.

## How It Works

1. **Update the Package List**: The script starts by updating the package list using the `apt update` command. This fetches the latest information about available packages from the repositories.

2. **Upgrade Installed Packages**: After updating the package list, the script proceeds to upgrade all installed packages without asking for confirmation. It achieves this using the `apt -y full-upgrade` command. This ensures that the system's software is updated to the latest versions available in the repositories.

3. **Remove Old Packages**: The script also takes care of cleaning up the system by removing old, no longer needed packages. It does this using the `apt -y autoremove` command, which frees up disk space and keeps the system clean.

4. **Cron Job for Automation**: To enable automated updates, the script sets up a cron job to run daily at 4:00 AM. It achieves this by adding a new entry to the system's crontab using the `(crontab -l ; echo "0 4 * * * /usr/local/sbin/auto-package-update.sh") | crontab -` command. The cron job ensures that the script runs at the specified time regularly, keeping the system up to date without manual intervention.

## Important Note

- Automatic package updates can be convenient, but they should be used with caution, especially in production environments. Before enabling automatic updates, ensure you have proper backups and understand the potential risks of automatic upgrades.

## License

This script is released under the [MIT License](LICENSE). Feel free to use, modify, and distribute it according to the terms of the license.
