FROM phusion/baseimage:jammy-1.0.1
MAINTAINER remco1271

# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME            /root
ENV LC_ALL          C.UTF-8
ENV LANG            en_US.UTF-8
ENV LANGUAGE        en_US.UTF-8
ENV TERM xterm

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

# Define working directory.
WORKDIR /tmp

# Copy files
COPY helpers/* /usr/local/bin/

RUN \
	# Configure user nobody to match unRAID's settings
	usermod -u 99 nobody && \
	usermod -g 100 nobody && \
	usermod -d /home nobody && \
	chown -R nobody:users /home && \
	chmod +x /usr/local/bin/add-pkg && \
	chmod +x /usr/local/bin/del-pkg && \
	chmod +x /usr/local/bin/sed-patch && \
	add-pkg \
		# Install basic compilation tools and dev libraries
		make \
		gcc \
		iasl \
		lzma-dev \
		mtools \
		# Install Git tools
		git \
		# Install Apache 2 with fast CGI and PHP5 module
		libapache2-mod-fcgid \
		libapache2-mod-php8.1 \
		apache2 \
		# wget
		wget \
		# Install to remove vulnerable version
		vim \
		&& \
	a2enmod fcgid php8.1 rewrite && \
	add-pkg \
		php8.1-mysql \
		php8.1-zip \
		php8.1-gd \
		php8.1-mbstring \
		php8.1-curl \
		php8.1-xml \
		php8.1-bcmath \
		&& \
	rm /etc/apache2/sites-available/* && \
	rm /etc/apache2/apache2.conf && \
	rm -rf /tmp/* /tmp/.[!.]*
# Copy files
COPY ipxe /

RUN \
	# Manually set the apache environment variables in order to get apache to work immediately.
	echo www-data > /etc/container_environment/APACHE_RUN_USER && \
	echo www-data > /etc/container_environment/APACHE_RUN_GROUP && \
	echo /var/log/apache2 > /etc/container_environment/APACHE_LOG_DIR && \
	echo /var/lock/apache2 > /etc/container_environment/APACHE_LOCK_DIR && \
	echo /var/run/apache2.pid > /etc/container_environment/APACHE_PID_FILE && \
	echo /var/run/apache2 > /etc/container_environment/APACHE_RUN_DIR && \
	# Prepare the git buildweb repository
	mkdir -p /var/www && \
	# Prepare config folder
	mkdir -p /config && \
	chmod +x /etc/my_init.d/firstrun.sh && \
	rm -rf /tmp/* /tmp/.[!.]*
RUN \
    mkdir -p /web && \
    # Update apache configuration with this one
	cp /etc/apache2/000-default.conf /config/proxy-config.conf && \
	ln -s /config/proxy-config.conf /etc/apache2/sites-available/000-default.conf && \
	rm /etc/apache2/sites-enabled/000-default.conf && \
	ln -s /config/proxy-config.conf /etc/apache2/sites-enabled/000-default.conf && \
	ln -s /var/log/apache2 /logs && \
    rm -rf /var/lib/apt/lists/* && \
	rm /config/proxy-config.conf

# Expose Ports
EXPOSE 80

# The www directory and proxy config location
VOLUME ["/logs","/web", "/config"]
