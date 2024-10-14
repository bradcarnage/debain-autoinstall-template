#!/bin/bash
# preseed.sh
# This script runs in the installation environment, which writes a service file to have the installed system fetch a seed script once booted.

echo "Installing Persistent post-install script..."
cat >"/etc/post-install-scripts.txt" <<'EOF'
https://dev.example.com/d-i/post-install.sh
EOF
cat >"/etc/post-install.sh" <<'EOF'
#!/bin/bash

# File containing URLs
URL_FILE="/etc/post-install-scripts.txt"
# Check if URL file exists
DOWNLOAD_FILENAME="/tmp/post-install-script"
if [ ! -f "$URL_FILE" ]; then
    echo "Error: URL file '$URL_FILE' not found."
else
    # Loop through each URL in the file
    while IFS= read -r url || [[ -n "$url" ]]; do
        echo "Attempting to download $url..."
        wget -O "$DOWNLOAD_FILENAME" "$url"
        if [ $? -eq 0 ]; then
            echo "Download successful."
            chmod +x "$DOWNLOAD_FILENAME"
            echo "Running the script..."
            sleep 1
            "$DOWNLOAD_FILENAME"
        else
            echo "Download failed for $url"
        fi
        rm "$DOWNLOAD_FILENAME"
        
    done < "$URL_FILE"
fi
# Random delay between 60 and 120 seconds
RANDOM_DELAY=$((60 + RANDOM % 61))
echo "redownloading all scripts in $RANDOM_DELAY seconds..."
sleep $RANDOM_DELAY
EOF

# Make the Persistent Seed installation script executable
chmod +x "/etc/post-install.sh"

cat >"/etc/systemd/system/post-install.service" <<'EOF'
[Unit]
Description=Post-Installation script that continiously gets fetched and ran
After=network.target

[Service]
Type=simple
ExecStartPre=/bin/sleep 5
ExecStart=/etc/post-install.sh
Restart=on-failure
StandardOutput=tty
StandardInput=tty
TTYPath=/dev/tty1

[Install]
WantedBy=multi-user.target

[Timer]
OnCalendar=*-*-* 00:00:00
Persistent=true
Unit=post-install.service
EOF

systemctl daemon-reload
# disable login prompt for tty1 (leave tty2 thru tty6 enabled (use ctrl alt f2 for tty2))
systemctl disable getty@tty1.service
systemctl enable post-install.service

# Edit the GRUB configuration file to boot in 1 second rather than 10
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
update-grub


# disable this on liveboot instance. will be started upon system reboot
# systemctl restart post-install.service
