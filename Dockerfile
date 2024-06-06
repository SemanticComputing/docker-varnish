FROM debian:11

# INSTALL
RUN apt-get update && \
    apt-get install -y \
    varnish \
    varnish-modules \
    gettext-base \
    libcap2-bin

# BUILD-TIME ENVIRONMENT VARIABLES
ENV FILE_DEFAULT_VCL "/etc/varnish/default.vcl"
ENV FILE_SITE_VCL "/etc/varnish/site.vcl"
ENV PATH_VAR_VARNISH "/var/lib/varnish"
ENV FILE_GENERATE_SITE_VCL_SH "/etc/varnish/generate-site-vcl.sh"
ENV RUN_VARNISH "/run-varnish.sh"
ENV EXEC_VARNISH "exec $RUN_VARNISH"

# RUN-TIME ENVIRONMENT VARIABLES
ENV VARNISH_CACHE_COOKIE ""
ENV VARNISH_IGNORE_COOKIE ""
ENV VARNISH_CACHE_AUTH ""
ENV VARNISH_IGNORE_AUTH ""
ENV VARNISH_DEFAULT_TTL ""
ENV VARNISH_BACKEND_IP ""
ENV VARNISH_BACKEND_PORT ""
ENV VARNISH_MEM "1G"
ENV VARNISH_VSL_MASK_HASH ""
ENV VARNISH_HTTP_PORT "80"

# Copy files
COPY default.vcl "$FILE_DEFAULT_VCL"
COPY generate-site-vcl.sh "$FILE_GENERATE_SITE_VCL_SH"

# PERMISSIONS: PORTS
RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/sbin/varnishd

# PERMISSIONS: FILES and FOLDERS
RUN D="$PATH_VAR_VARNISH"  && mkdir -p "$D" && chgrp -R root "$D" && chmod g=u -R "$D"
RUN F="$FILE_SITE_VCL"     && D="$(dirname "$F")" && mkdir -p "$D" && chmod g=u "$D" && touch "$F"  && chmod g=u "$F" && \
    F="$FILE_DEFAULT_VCL"  && D="$(dirname "$F")" && mkdir -p "$D" && chmod g=u "$D" && touch "$F"  && chmod g=u "$F"

COPY run "$RUN_VARNISH"
RUN chmod ug+x "$RUN_VARNISH"

ENTRYPOINT [ "/run-varnish.sh" ]
