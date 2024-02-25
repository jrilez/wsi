#!/bin/bash
# // Webserver Cleaner
# // https://github.com/jrilez/wsi
# //

[[ ! "$(id -u)" -eq 0 ]] && echo "ERROR: Must be run as root, EXIT ..."

LOG_FILE="wsc.log"
[[ ! -f "$LOG_FILE" ]] && touch "$LOG_FILE"

log() {
    local message="$1"
    echo "$message"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $message" >> "$LOG_FILE"
}

warning=1
keep_log=true

while getopts "fas:" option; do
    case $option in
    f)
        log "// Warning suppressed .."
        warning=0
        response=y
        ;;
    a)
        [[ $warning -eq 1 ]] && read -p "// Do you want to to delete ALL sites? (y/n): " response
        case "$response" in
        [yY]|[yY][eE][sS])
            log "// Deleting ALL sites ..."
            directories=(/var/www /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/letsencrypt/live)
            for directory in "${directories[@]}"; do
                [ -d "$directory" ] && rm -R $directory/*
            done
            log "// END ..."
            exit 1
            ;;
        [nN]|[nN][oO])
            log "// Re-run script with '-s' (not '-a') flag and specify which sites you want deleted, EXIT ..." && exit 1
            ;;
        *)
            echo "// ERROR: Invalid input, EXIT ..." && exit 1
            ;;
        esac
        ;;
    s)
        [[ $warning -eq 1 ]] && read -p "// Are you sure you want to delete $OPTARG? (y/n): " response
        case "$response" in
        [yY]|[yY][eE][sS])
            log "// Deleting $OPTARG ..."
            directories=(/var/www /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/letsencrypt/live)
            for directory in "${directories[@]}"; do
                [ -d "$directory" ] && rm -R $directory/$OPTARG
            done
            log "// END ..."
            exit 1
            ;;
        [nN]|[nN][oO])
            log "// 'No' specified, EXIT ..." && exit 1
            ;;
        *)
            echo "// ERROR: Invalid input, EXIT ..." && exit 1
            ;;
        esac
        ;;
    x)
      keep_log=false
      log "// Log file will be deleted ..."
      ;;
    :) echo "// ERROR: -$OPTARG is missing an argument, EXIT ..." && exit 1 ;;
    *) echo "// ERROR: Invalid option, EXIT ..."; exit 1 ;;
    esac
done

! $keep_log && { echo "// Deleting log file: $LOG_FILE ..."; rm -R "$LOG_FILE"; }
log "// ERROR: No sites specified, nothing deleted, EXIT ..."
log "// END ..."