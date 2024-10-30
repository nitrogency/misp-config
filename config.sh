#!/bin/bash

sudo chmod 600 /var/www/MISP/app/Config/config.php
sudo chmod 600 /var/www/MISP/app/Config/database.php
sudo chmod 600 /var/www/MISP/app/Config/email.php

KEY=$(openssl rand -base64 32)

sudo -u www-data /var/www/MISP/app/Console/cake Admin setSetting "Security.encryption_key" "$KEY"

sudo -u www-data /var/www/MISP/app/Console/cake Admin setSetting "Security.alert_on_suspicious_logins" "true"


sudo -u www-data /var/www/MISP/app/Console/cake Admin setSetting "Plugin.Enrichment_services_enable" "true"
sudo -u www-data /var/www/MISP/app/Console/cake Admin setSetting "Plugin.Enrichment_hover_enable" "true"
sudo -u www-data /var/www/MISP/app/Console/cake Admin setSetting "Plugin.Enrichment_hover_popover_only" "true"

sudo -u www-data /var/www/MISP/app/Console/cake Admin setSetting "Plugin.Import_services_enable" "true" 	
sudo -u www-data /var/www/MISP/app/Console/cake Admin setSetting "Plugin.Export_services_enable" "true"
sudo -u www-data /var/www/MISP/app/Console/cake Admin setSetting "Plugin.Action_services_enable" "true"

sudo -u www-data /var/www/MISP/app/Console/cake Admin setSetting "Plugin.Cortex_services_enable" "false"

# Installs elasticsearch dependencies, further installation described here: https://raw.githubusercontent.com/MISP/MISP/2.4/docs/CONFIG.elasticsearch-logging.md
cd /var/www/MISP
y | sudo -u www-data composer require elasticsearch/elasticsearch

EXTENSIONS="
extension=zstd
extension=simdjson 
extension=brotli
"


for line in $EXTENSIONS; do
    if ! grep -q "^$line" /etc/php/8.3/cli/php.ini; then
        echo "$line" | sudo tee -a /etc/php/8.3/cli/php.ini > /dev/null
    fi
done

for line in $EXTENSIONS; do
    if ! grep -q "^$line" /etc/php/8.3/apache2/php.ini; then
        echo "$line" | sudo tee -a /etc/php/8.3/apache2/php.ini > /dev/null
    fi
done

sudo systemctl restart apache2.service


