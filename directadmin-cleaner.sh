#!/usr/bin/env bash
# Directadmin CLEANER Settings
discord="#"
HOSTNAME=$(hostname)

# Vrije ruimte aan het begin
vrije_ruimte_begin=$(df -h | awk '/\/$/ {print $4}')

## Removing Installatron backups
RESTIC_CACHE="yes"  ## remove the restic cache
if [[ "$RESTIC_CACHE" == "yes" ]]; then
  echo "Removing Restic cache..."
  rm -rf /root/.cache/restic/*
  wait $!
fi

## Removing Installatron backups
INSTALLATRON="yes"  ## will remove Installatron backups
if [[ "$INSTALLATRON" == "yes" ]]; then
  echo "Removing Installatron backups..."
  rm -rf /home/*/application_backups/*.tar.gz
  wait $!
fi

## Removing Magento Logs files
MAGENTO_LOGS="yes"  ## will remove Magento logs
if [[ "$MAGENTO_LOGS" == "yes" ]]; then
  echo "Removing Magento Logs..."
  truncate -s 0 /home/*/domains/*/public_html/var/log/*.log
  wait $!
fi

USER_LOGS="yes"  ## will remove User logs
if [[ "$USER_LOGS" == "yes" ]]; then
  echo "Removing user log backups…."
  rm -rf /home/*/domains/*/logs/*.tar.gz
  wait $!
fi

SYSTEM_LOGS="yes"  ## will empty System logs (/var/log)
if [[ "$SYSTEM_LOGS" == "yes" ]]; then
  echo "Empty system log files…."
  ## Empty System Logs files
  truncate -s 0 /var/log/maillog-* /var/log/secure-* /var/log/messages-* /var/log/yum.log-* /var/log/wtmp-* /var/log/dovecot*.log /var/log/cron-* /var/log/btmp-* /var/log/exim/rejectlog-* /var/log/exim/spooler-*  /var/log/exim/secure-*  /var/log/exim/pureftpd.log-*
  wait $!
fi

USER_STATS="yes"  ## will remove User website visitor logs
if [[ "$USER_STATS" == "yes" ]]; then
  echo "Removing user log backups…."
  rm -rf /home/*/domains/*/stats/ctry_usage_*.png && /home/*/domains/*/stats/daily_usage_*.png && /home/*/domains/*/stats/hourly_usage_*.png && /home/*/domains/*/stats/usage_*.html
  wait $!
fi

WORDPRESS_BACKUPS="yes"  ## will remove User website visitor logs
if [[ "$WORDPRESS_BACKUPS" == "yes" ]]; then
  echo "Removing WordPress backups…."
  rm -rf /home/*/domains/*/public_html/*/wp-content/ai1wm-backups/*.wpress && rm -rf /home/*/domains/*/public_html/wp-content/updraft/*.zip
  wait $!
fi

WEBALIZER="yes"
# ## will remove WEBALIZER current file
if [[ "$WEBALIZER" == "yes" ]]; then
  echo "Empty WebAlizer stats…."
  truncate -s 0 /home/*/domains/*/stats/webalizer.current
  wait $!
fi

# Empty HTTPD Logs
VAR_LOG_HTTPD="yes"
if [[ "$VAR_LOG_HTTPD" == "yes" ]]; then
  echo "Empty HTTPD Logs…."
  truncate -s 0 /var/log/httpd/sulsphp_log* /var/log/httpd/error_lo* /var/log/httpd/access_l* /var/log/httpd/domains/*.log /var/log/httpd/domains/*.log* /var/log/httpd/domains/*.log-2*
  wait $!
fi

# Vrije ruimte aan het einde
vrije_ruimte_einde=$(df -h | awk '/\/$/ {print $4}')

# Verwijderen van de 'G' uit de waarden
vrije_ruimte_begin=${vrije_ruimte_begin%G}
vrije_ruimte_einde=${vrije_ruimte_einde%G}

# Berekenen hoeveel ruimte er is bespaard
bespaarde_ruimte=$((vrije_ruimte_einde - vrije_ruimte_begin))

# Toevoegen van de 'G' aan de uitvoer
bespaarde_ruimte="${bespaarde_ruimte} GB"

# Weergeven van de resultaten
echo "Vrije ruimte aan het begin: $vrije_ruimte_begin"
echo "Vrije ruimte aan het einde: $vrije_ruimte_einde"
echo "Bespaarde ruimte: $bespaarde_ruimte"

# send to Discord
DISCORD_MESSAGE='{"content": "Cleaning Report for: '${HOSTNAME}', '${bespaarde_ruimte}' Diskspace saved.  "}'
curl -H "Content-Type: application/json" -X POST -d "$DISCORD_MESSAGE" "$discord"
