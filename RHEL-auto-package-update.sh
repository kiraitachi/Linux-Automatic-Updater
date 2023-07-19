#!/bin/bash

# Step 3: Create the auto-package-update.sh script
cat > /usr/local/sbin/auto-package-update.sh <<'EOF'
#!/bin/bash

# Update the package list
yum check-update

# Upgrade all installed packages without asking for confirmation
yum -y update

# Clean up old packages and free up disk space
yum -y autoremove
EOF

# Make the auto-package-update.sh script executable
chmod +x /usr/local/sbin/auto-package-update.sh

# Step 4: Set up a cron job to run the script daily at 4:00 AM
(crontab -l ; echo "0 4 * * * /usr/local/sbin/auto-package-update.sh") | crontab -
