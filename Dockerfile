# Only debian seems to provide varnish 5
FROM debian:latest

# INSTALL
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


# ENVIRONMENT VARIABLES
ENV FILE_DEFAULT_VCL "/etc/varnish/default.vcl"
ENV FILE_SITE_VCL "/etc/varnish/site.vcl"
ENV PATH_LOG_VARNISH "/var/log/varnish"
ENV FILE_LOG_VARNISH "$PATH_LOG_VARNISH/varnish.log"
ENV PATH_VAR_VARNISH "/var/lib/varnish"

# PERMISSIONS 
RUN chmod -R g=u "$PATH_VAR_VARNISH"
RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/varnishd
RUN touch "$FILE_SITE_VCL"
RUN chmod -R g=u "$FILE_SITE_VCL"
RUN mkdir -p "$PATH_LOG_VARNISH"
RUN touch "$FILE_LOG_VARNISH"
RUN chgrp -R root "$PATH_LOG_VARNISH" && chmod -R g=u "$PATH_LOG_VARNISH"

# Copy the main varnish configuration
COPY default.vcl "$FILE_DEFAULT_VCL"
