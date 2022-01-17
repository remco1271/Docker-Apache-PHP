#!/bin/bash

# Check if config exists. If not, copy in the sample config
if [ -f /config/proxy-config.conf ]; then
  echo "Using existing config file."
else
  echo "Creating config from template."
  mv /etc/apache2/000-default.conf /config/proxy-config.conf
  cp /root/.htpasswd /config/.htpasswd
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
apt-get update && apt-get -yq upgrade

# git pull latest iPXE repository
if [ -z "$(ls -A '/ipxe')" ]; then
	echo "[info] clone ipxe..."
	git clone https://git.ipxe.org/ipxe.git /ipxe
else
	echo "[info] revert ipxe local changes and pull from github..."
	rm -f /ipxe/.git/index && rm -f /ipxe/.git/index.lock && git -C /ipxe checkout -f && git -C /ipxe pull
fi

# git pull latest buildweb
if [ -z "$(ls -A '/ipxe-buildweb')" ]; then
	echo "[info] clone ipxe-buildweb..."
	git clone https://github.com/xbgmsharp/ipxe-buildweb.git /ipxe-buildweb
else
	echo "[info] revert ipxe-buildweb local changes and pull from github..."
	rm -f /ipxe-buildweb/.git/index && rm -f /ipxe-buildweb/.git/index.lock && git -C /ipxe-buildweb checkout -f && git -C /ipxe-buildweb pull
fi

if [ -f '/ipxe-buildweb/parseheaders.pl' ]; then
	echo "[info] copying parseheaders.pl '/ipxe-buildweb/parseheaders.pl' to '/ipxe/src/util/'..."
	cp /ipxe-buildweb/parseheaders.pl /ipxe/src/util/
fi

echo "[info] chown folders..."
chown -R www-data:www-data /var/run/ipxe-build/ipxe-build-cache.lock /var/cache/ipxe-build /var/run/ipxe-build /var/tmp/ipxe-build /var/tmp/ipxe

exec /usr/sbin/apache2 -D FOREGROUND