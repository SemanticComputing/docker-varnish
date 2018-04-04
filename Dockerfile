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


# BUILD-TIME ENVIRONMENT VARIABLES
ENV FILE_DEFAULT_VCL "/etc/varnish/default.vcl"
ENV FILE_SITE_VCL "/etc/varnish/site.vcl"
ENV PATH_LOG_VARNISH "/var/log/varnish"
ENV FILE_LOG_VARNISH "$PATH_LOG_VARNISH/varnish.log"
ENV PATH_VAR_VARNISH "/var/lib/varnish"
ENV FILE_GENERATE_SITE_VCL_SH "/etc/varnish/generate-site-vcl.sh"
ENV FILE_RUN_VARNISH_SH "/run-varnish.sh"
ENV EXEC_VARNISH "exec $FILE_RUN_VARNISH_SH"

# RUN-TIME ENVIRONMENT VARIABLES
ENV VARNISH_CACHE_COOKIE ""
ENV VARNISH_IGNORE_COOKIES ""
ENV VARNISH_CACHE_AUTH ""
ENV VARNISH_IGNORE_AUTH ""
ENV VARNISH_DEFAULT_TTL ""
ENV VARNISH_BACKEND_IP ""
ENV VARNISH_BACKEND_PORT ""
ENV VARNISH_MEM "1G"

# Copy files
COPY default.vcl "$FILE_DEFAULT_VCL"
COPY generate-site-vcl.sh "$FILE_GENERATE_SITE_VCL_SH"

# PERMISSIONS: PORTS
RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/varnishd

# PERMISSIONS: FILES and FOLDERS
RUN mkdir -p "$PATH_LOG_VARNISH"; chgrp -R root "$PATH_LOG_VARNISH"; chmod g=u -R "$PATH_LOG_VARNISH"
RUN mkdir -p "$PATH_VAR_VARNISH"; chgrp -R root "$PATH_VAR_VARNISH"; chmod g=u -R "$PATH_VAR_VARNISH"
RUN mkdir -p "$(dirname '$FILE_DEFAULT_VCL')"; touch "$FILE_SITE_VCL"; chmod g=u "$FILE_SITE_VCL"
RUN mkdir -p "$(dirname '$FILE_SITE_VCL')"; touch "$FILE_SITE_VCL"; chmod g=u "$FILE_SITE_VCL"
RUN mkdir -p "$(dirname '$FILE_LOG_VARNISH')"; touch "$FILE_LOG_VARNISH"; chmod g=u "$FILE_LOG_VARNISH"

COPY run "$FILE_RUN_VARNISH_SH"

ENTRYPOINT [ "/run-varnish.sh" ]
