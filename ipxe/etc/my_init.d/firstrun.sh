#!/bin/bash

# Check if config exists. If not, copy in the sample config
if [ -f /config/proxy-config.conf ]; then
  echo "Using existing config file."
  rm /etc/apache2/000-default.conf
else
  echo "Creating config from template."
  mv /etc/apache2/000-default.conf /config/proxy-config.conf
fi

# Add Persistent Cron Configuration Capability
if [ -f /config/crons.conf ]; then
  echo "Using existing Cron config file."
#  crontab /config/crons.conf
#  cron
else
  echo "Copying blank  Cron config file."
  cp /root/crons.conf /config/crons.conf
#  crontab /config/crons.conf
#  cron
fi

# Upgrade system
#apt-get update && apt-get -yq upgrade
# Clean-up system
#apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
# Silence all safe.directory warnings
#git config --system --add safe.directory '*'

echo "[info] Start apache2..."

exec /usr/sbin/apache2 -D FOREGROUND
#exec service apache2 start