#!/usr/bin/env bash

# ----------------------
# DirectAdmin CLEANER
# ----------------------

HOSTNAME=$(hostname)

# Vrije ruimte aan het begin
vrije_ruimte_begin=$(df -h | awk '/\/$/ {print $4}')

# ----------------------
# Cleanup: Restic cache
# ----------------------
echo "Removing Restic cache..."
rm -rf /root/.cache/restic/*

# ------------------------------
# Cleanup: Installatron backups
# ------------------------------
echo "Removing Installatron backups..."
rm -rf /home/*/application_backups/*.tar.gz

# ----------------------
# Cleanup: Magento logs
# ----------------------
echo "Truncating Magento logs..."
truncate -s 0 /home/*/domains/*/public_html/var/log/*.log

# ---------------------
# Cleanup: User log tar.gz
# ---------------------
echo "Removing user log backups..."
rm -rf /home/*/domains/*/logs/*.tar.gz

# ---------------------
# Cleanup: System logs
# ---------------------
echo "Emptying system log files..."
truncate -s 0 /var/log/maillog-* /var/log/secure-* /var/log/messages-* /var/log/yum.log-* /var/log/wtmp-* /var/log/dovecot*.log /var/log/cron-* /var/log/btmp-* /var/log/exim/rejectlog-* /var/log/exim/spooler-*  /var/log/exim/secure-*  /var/log/exim/pureftpd.log-*

# --------------------------
# Cleanup: User visitor stats
# --------------------------
echo "Removing user visitor stats..."
rm -rf /home/*/domains/*/stats/ctry_usage_*.png
rm -rf /home/*/domains/*/stats/daily_usage_*.png
rm -rf /home/*/domains/*/stats/hourly_usage_*.png
rm -rf /home/*/domains/*/stats/usage_*.html

# ------------------------
# Cleanup: WordPress backups
# ------------------------
echo "Removing WordPress backup files..."
rm -rf /home/*/domains/*/public_html/*/wp-content/ai1wm-backups/*.wpress
rm -rf /home/*/domains/*/public_html/wp-content/updraft/*.zip

# ----------------------
# Cleanup: Webalizer stats
# ----------------------
echo "Emptying Webalizer stats..."
truncate -s 0 /home/*/domains/*/stats/webalizer.current

# ----------------------
# Cleanup: HTTPD logs
# ----------------------
echo "Emptying HTTPD logs..."
truncate -s 0 /var/log/httpd/sulsphp_log* /var/log/httpd/error_lo* /var/log/httpd/access_l* /var/log/httpd/domains/*.log /var/log/httpd/domains/*.log* /var/log/httpd/domains/*.log-2*

# ----------------------
# Cleanup: Magento 2 caches
# ----------------------
echo "Flushing Magento 2 caches (if any found)..."
find /home/ -type d \( -name "bin" -a ! -path "*/dev/tests/*" -a ! -path "*/vendor/magento/*" \) -exec find {} -type f -name "magento" \; | while IFS= read -r dir; do
  processed_path=$(echo "$dir")
  user=$(echo "$processed_path" | awk -F'/' '{print $3}')
  echo "User: $user"
  echo "Magento 2 installation found in: $processed_path"
  echo "Emptying Magento 2 caches..."
  php_version=$(ls -1 /usr/local/directadmin/data/users/"$(basename "$user")"/php/php-fpm*.conf 2>/dev/null | awk -F'php-fpm|.conf' '{print $2}' | sort -nr | head -1)
  php_path="/usr/local/php$php_version/bin/php"
  "$php_path" "$processed_path" cache:flush
  done

# -----------------------------
# Cleanup: WordPress cache/logs
# -----------------------------
echo "Cleaning WordPress cache, logs, wpallimport..."
# WP All Import logs
find /home/*/domains/*/public_html/wp-content/uploads/wpallimport/logs/ -type f -delete 2>/dev/null
# Wordfence logs
find /home/*/domains/*/public_html/wp-content/wflogs/ -type f -delete 2>/dev/null
# General cache folders
find /home/*/domains/*/public_html/wp-content/cache/ -type f -delete 2>/dev/null
find /home/*/domains/*/public_html/wp-content/plugins/w3-total-cache/ -type f -delete 2>/dev/null
find /home/*/domains/*/public_html/wp-content/webp-express/log/ -type f -delete 2>/dev/null

# Verwijderen van BackupBuddy-backups
find /home/*/domains/*/public_html/wp-content/uploads/backupbuddy_backups/ -type f -name "*.zip" -exec rm -f {} \;

# Verwijderen van UpdraftPlus backups (.zip en .gz bestanden)
find /home/*/domains/*/public_html/wp-content/updraft/ -type f \( -name "*.zip" -o -name "*.gz" \) -delete 2>/dev/null

# Verwijderen van All-in-One WP Migration backups (.wpress bestanden)
find /home/*/domains/*/public_html/wp-content/ai1wm-backups/ -type f -name "*.wpress" -delete 2>/dev/null

# WooCommerce fatal error logs ouder dan 7 dagen
find /home/*/domains/*/public_html/wp-content/uploads/wc-logs/ -type f -name "fatal-errors*" -mtime +7 -delete 2>/dev/null

# Vrije ruimte aan het einde
vrije_ruimte_einde=$(df -h | awk '/\/$/ {print $4}')
vrije_ruimte_begin=${vrije_ruimte_begin%G}
vrije_ruimte_einde=${vrije_ruimte_einde%G}
bespaarde_ruimte=$((vrije_ruimte_einde - vrije_ruimte_begin))
bespaarde_ruimte="${bespaarde_ruimte} GB"

echo "----------------------"
echo "Vrije ruimte aan het begin: $vrije_ruimte_begin GB"
echo "Vrije ruimte aan het einde: $vrije_ruimte_einde GB"
echo "Bespaarde ruimte: $bespaarde_ruimte"
echo "----------------------"
