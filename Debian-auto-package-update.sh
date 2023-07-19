#!/bin/bash

# Create the auto-package-update.sh script
cat > /usr/local/sbin/auto-package-update.sh <<'EOF'
#!/bin/bash

# Update the package list
apt update

# Upgrade all installed packages without asking for confirmation
apt -y full-upgrade

# Remove all old packages
apt -y autoremove
EOF

# Make the auto-package-update.sh script executable
chmod +x /usr/local/sbin/auto-package-update.sh

# Step 4: Set up a cron job to run the script daily at 4:00 AM
(crontab -l ; echo "0 4 * * * /usr/local/sbin/auto-package-update.sh") | crontab -
