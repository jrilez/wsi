#!/bin/bash
# // Nginx Remover
# //

[[ ! "$(id -u)" -eq 0 ]] && echo "ERROR: Must be run as root, EXIT ..."

systemctl stop nginx
systemctl disable nginx

# Remove Nginx packages
apt-get purge nginx nginx-common nginx-full -y
apt-get autoremove -y

# Remove Nginx configuration files and directories
rm -rf /etc/nginx /var/www/html /var/log/nginx /usr/share/nginx /etc/systemd/system/nginx.service

# Verify Nginx removal
if ! command -v nginx > /dev/null; then
    echo "// nginx removal - success"
else
    echo "// nginx removal = failed"
fi
