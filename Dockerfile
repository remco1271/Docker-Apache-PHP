FROM debian:stable-slim
LABEL maintainer="remco1271"

# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME            /root
ENV LC_ALL          C.UTF-8
ENV LANG            en_US.UTF-8
ENV LANGUAGE        en_US.UTF-8
ENV TERM xterm

# Use baseimage-docker's init system
CMD ["/etc/my_init.d/firstrun.sh"]

# Define working directory.
WORKDIR /tmp

# Copy files
COPY helpers/* /usr/local/bin/

ENV PHP_VERSION 8.1

RUN \
	# Configure user nobody to match unRAID's settings
	usermod -u 99 nobody && \
	usermod -g 100 nobody && \
	usermod -d /home nobody && \
	chown -R nobody:users /home && \
	chmod +x /usr/local/bin/add-pkg && \
	chmod +x /usr/local/bin/del-pkg && \
	chmod +x /usr/local/bin/sed-patch && \
	# add  repo
	add-pkg lsb-release ca-certificates curl && \
	curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg && \
	sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' && \
	# install normal
	add-pkg \
		# Install Apache 2 with fast CGI and PHP5 module
		libapache2-mod-fcgid \
		libapache2-mod-php${PHP_VERSION} \
		apache2 \
		# wget
		wget \
		&& \
	a2enmod fcgid php${PHP_VERSION} rewrite && \
	add-pkg \
		php${PHP_VERSION}-mysql \
		php${PHP_VERSION}-zip \
		php${PHP_VERSION}-gd \
		php${PHP_VERSION}-mbstring \
		php${PHP_VERSION}-curl \
		php${PHP_VERSION}-xml \
		php${PHP_VERSION}-bcmath \
		&& \
	rm /etc/apache2/sites-available/* && \
	rm /etc/apache2/apache2.conf && \
	rm -rf /tmp/* /tmp/.[!.]*
# Copy files
COPY ipxe /
# Manually set the apache environment variables in order to get apache to work immediately.
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
RUN \
	# Prepare the git buildweb repository
	mkdir -p /var/www && \
	# Prepare config folder
	mkdir -p /config && \
	chmod +x /etc/my_init.d/firstrun.sh && \
	rm -rf /tmp/* /tmp/.[!.]*
RUN \
    mkdir -p /web && \
    # Update apache configuration with this one
	ln -s /config/proxy-config.conf /etc/apache2/sites-available/000-default.conf && \
	rm /etc/apache2/sites-enabled/000-default.conf && \
	ln -s /config/proxy-config.conf /etc/apache2/sites-enabled/000-default.conf && \
	ln -s /var/log/apache2 /logs && \
    rm -rf /var/lib/apt/lists/*

# Expose Ports
EXPOSE 80

# The www directory and proxy config location
VOLUME ["/logs","/web", "/config"]
