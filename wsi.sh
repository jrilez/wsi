#!/bin/bash
# // Webserver Installer
# // https://github.com/jrilez/wsi
# //

[[ ! "$(id -u)" -eq 0 ]] && echo "ERROR: Must be run as root, EXIT ..." && exit 1

LOG_FILE="wsi.log"
[[ ! -f "$LOG_FILE" ]] && touch "$LOG_FILE"

log() {
    local message="$1"
    echo "$message"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

ssl=false
ufw=false
keep_log=true

while getopts ":s:d:u :x" option; do
  case $option in
    s)
      ssl="true"
      email="$OPTARG"
      [[ ! "$OPTARG" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]] && echo "ERROR: $OPTARG is an invalid email, EXIT ..." && exit 1
      log "// SSL configuration enabled ..."
      log "// Email set to $OPTARG ..."
      ;;
    d)
      [[ $ssl = "true" && ! "$OPTARG" =~ ^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$ ]] && log "// ERROR: $OPTARG is an invalid domain, EXIT ..." && exit 1
      [ -d "/var/www/$OPTARG" ] && log "// ERROR: Directory '$OPTARG' exists, EXIT ..." && exit 1
      site="$OPTARG"
      block="/etc/nginx/sites-available/$site"
      log "// Site/domain set to $OPTARG, root directory created ..."
      ;;
    u)
      ufw=true
      log "// UFW configuration enabled ..."
      ;;
    x)
      keep_log=false
      log "// Log file will be deleted ..."
      ;;
    :)
      echo "// ERROR: -$OPTARG is missing an argument, EXIT ..." && exit 1
      ;;
  esac
done

apt-get update
nginx -v >/dev/null 2>&1 || log "// Installing Nginx ..."; apt-get install -y nginx
mkdir /var/www/$site; log "// Site root created ..."

# tried using a for loop but it kept missing /etc/nginx/sites-enabled/default for some reason
sudo rm "/var/www/html" && echo "// Deleted /var/www/html"
sudo rm "/etc/nginx/sites-available/default" && echo "// Deleted /etc/nginx/sites-available/default"
sudo rm "/etc/nginx/sites-enabled/default" && echo "// Deleted /etc/nginx/sites-enabled/default"

log "// Empty index.html created in root dir ..."
echo "Webserver installed and configured." >> /var/www/$site/index.html

if grep -q "server {" /etc/nginx/sites-available/$site; then
    echo "// WARN: Server block already exists. No changes made ..."
else
    cat <<EOF >> /etc/nginx/sites-available/$site
server {
    listen 80;
    root /var/www/$site;
    index index.html index.htm;
    server_name $site;
    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
    log "// Server block inserted into Nginx configuration file ..."
fi

ln -s $block /etc/nginx/sites-enabled/$site && log "// Symbolic link created ..."
sudo systemctl restart nginx && log "// Restarted Nginx ..."

$ssl && {
  apt install python3-acme python3-certbot python3-mock python3 openssl python3-pkg-resources python3-pyparsing python3-zope.interface -y 
  apt install python3-certbot-nginx 
  certbot --nginx --no-eff-email --non-interactive --agree-tos --email $email -d $site
}

$ufw && {
  apt install ufw -y
  yes | ufw enable
  ufw status | grep -qE '(80|443|22)/tcp' || ufw allow 80,443,22/tcp
}

! $keep_log && { echo "// Deleting log file: $LOG_FILE ..."; rm -R "$LOG_FILE"; }

log "// END ..."
