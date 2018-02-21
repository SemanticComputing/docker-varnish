
FROM debian:latest

RUN apt-get update
RUN apt-get install -y varnish varnish-modules
RUN apt-get install -y git
RUN apt-get install -y gettext-base
RUN apt-get install -y libcap2-bin

# Compile and install varnish vmod 'urlcode'.
RUN apt-get install -y \
    wget \
    dpkg-dev \
		libtool \
		m4 \
		automake \
		pkg-config \
		docutils-common \
		libvarnishapi-dev
RUN cd /tmp \
		&& mkdir urlcode \
		&& cd urlcode \
		&& wget https://github.com/fastly/libvmod-urlcode/archive/master.tar.gz \
		&& tar -xf master.tar.gz \
		&& cd libvmod-urlcode-master \
		&& sh autogen.sh \
		&& ./configure \
		&& make \
		&& make install \
		&& make check

RUN chmod -R g+rwX /var/lib/varnish/
RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/varnishd

# Create empty file for the site specifiv varnish configuration and give runtime access to it
RUN touch /etc/varnish/site.vcl
RUN chmod -R g+rwX /etc/varnish/site.vcl

# Give access to write varnish logs at runtime
RUN chgrp -R root /var/log/varnish
RUN chmod -R g+rwX /var/log/varnish

# Copy the main varnish configuration
COPY default.vcl /etc/varnish/default.vcl
