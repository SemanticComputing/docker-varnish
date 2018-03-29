#!/bin/bash

VARNISH_BACKEND_IP=${VARNISH_BACKEND_IP:-"127.0.0.1"}
VARNISH_BACKEND_PORT=${VARNISH_BACKEND_PORT:-"8080"}



#############
# DEEFAULTS #
#############

# The default backend and copy of beginning of the built-in vcl_recv
cat -  <<EOF
backend default {
    .host = "$VARNISH_BACKEND_IP";
    .port = "$VARNISH_BACKEND_PORT";
}
sub vcl_recv {
    if (req.method == "PRI") {
    /* We do not support SPDY or HTTP/2.0 */
    return (synth(405));
    }
    if (req.method != "GET" &&
      req.method != "HEAD" &&
      req.method != "PUT" &&
      req.method != "POST" &&
      req.method != "TRACE" &&
      req.method != "OPTIONS" &&
      req.method != "DELETE") {
        /* Non-RFC2616 or CONNECT which is weird. */
        return (pipe);
    }

    if (req.method != "GET" && req.method != "HEAD") {
        /* We only deal with GET and HEAD by default */
        return (pass);
    }
}
EOF



###############################
# CACHE/IGNORE AUTHORIZATION? #
###############################

if [ "$VARNISH_CACHE_AUTH" != "" ]; then
cat -  <<EOF
sub vcl_hash {
    if (req.http.Authorization) {
        hash_data(req.http.Authorization);
    }
}
EOF
elif [ "$VARNISH_IGNORE_AUTH" == "" ]; then
cat -  <<EOF
sub vcl_recv {
    if (req.http.Authorization) {
        return(pass);
    }
}
EOF
fi



########################
# CACHE/IGNORE COOKIE? #
########################

if [ "$VARNISH_CACHE_COOKIE" != "" ]; then
cat -  <<EOF
sub vcl_hash {
    if (req.http.Cookie) {
        hash_data(req.http.Cookie);
    }
}
EOF
elif [ "$VARNISH_IGNORE_COOKIE" != "" ]; then
cat -  <<EOF
sub vcl_recv {
    if (req.http.Cookie) {
        return(pass);
    }
}
EOF
fi


#############
# DEEFAULTS #
#############

# Skip the built-in configuration
cat -  <<EOF
sub vcl_recv {
    return(hash);
}
EOF

if [ "$VARNISH_DEFAULT_TTL" != "" ]; then
cat -  <<EOF
sub vcl_backend_response {
	set beresp.ttl = $VARNISH_DEFAULT_TTL;
}
EOF
fi
