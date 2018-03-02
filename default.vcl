# conf
#
# Common/built-in configuration for all sites
# This configuration consists of 3 parts: HEAD, SITE and TAIL.
# The code in the subroutines within each part are concatenated in order.
# HEAD and TAIl contain common configuration. SITE is included from /etc/varnish/site.vcl
# and can contain any site-specific configuration.

vcl 4.0;

import vsthrottle;
import std;
import urlcode;

# HEAD

sub vcl_recv {

    # Add us to X-Forwarded-For. X-Forwarded-For=(client, proxy1, proxy2, ...)
    if (req.http.X-Forwarded-For) {
        set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;
    } else {
        set req.http.X-Forwarded-For = client.ip;
    }

    # Google Analytics cookies don't inhibit caching
    if (req.http.Cookie) {
        set req.http.Cookie = regsuball(req.http.Cookie, "(^|; ) *__utm.=[^;]+;? *", "\1"); # Remove Google Analytics Cookies
        if (req.http.Cookie == "") {
            unset req.http.Cookie;
        }
    }
}


sub vcl_backend_response {

    set beresp.do_stream = true;
    set beresp.http.x-url = bereq.url;
    set beresp.http.x-host = bereq.http.host;

    # Fix response protocol if https forwarding is used
    if(bereq.http.X-Forwarded-Proto == "https" && regsub(beresp.http.Location, "^http://([^/]+)/.*", "\1") == bereq.http.Host ) {
        set beresp.http.Location = regsub(beresp.http.Location, "^http://(.*)", "https://\1");
    }
    
    # Do not compress already compressed formats
    if (bereq.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") { 
        set beresp.do_gzip = false;
    }

}

sub vcl_backend_error {
        # Errors coming from different origin?
        set beresp.http.Access-Control-Allow-Origin = "*"; # allow all + basic authentication with CORS
        set beresp.http.Access-Control-Allow-Headers = "X-Requested-With, Content-Type, Authorization";
        set beresp.http.Access-Control-Allow-Methods = "HEAD, GET, POST, OPTIONS, PUT, DELETE";

        if (beresp.status == 401) {
            set beresp.http.WWW-Authenticate = "Basic realm=Restricted";
        }

        # Process synth(503, reason)
        if (beresp.status == 503) {
            synthetic({"<?xml version="1.0" encoding="utf-8"?>
                    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
                     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
                    <html>
                        <head>
                            <title>"} + beresp.status + " " + beresp.reason + {"</title>
                        </head>
                        <body>
                            <h1>Error "} + beresp.status + " " + beresp.reason + {"</h1>
                            <p>It seems our front-end could not connect to the back-end server ("} + bereq.backend + {") which hosts the service you were trying to access (<a href="http://"} + bereq.http.host + "" + bereq.url + {"">http://"} + bereq.http.host + bereq.url + {"</a>).</p>
                            <p>This means that the back-end or our service infrastructure may be experiencing problems.</p>
                            <p>Please try again in a couple of minutes and if the problem persists, contact <a href="mailto:seco-help@list.aalto.fi">seco-help@list.aalto.fi</a> in order to notify us of the situation.</p>
                        </body>
                    </html>
            "});
            return(deliver);
        }
}

sub vcl_synth {
        # Synthetic response origin?
        set resp.http.Access-Control-Allow-Origin = "*"; # allow all + basic authentication with CORS
        set resp.http.Access-Control-Allow-Headers = "X-Requested-With, Content-Type, Authorization";
        set resp.http.Access-Control-Allow-Methods = "HEAD, GET, POST, OPTIONS, PUT, DELETE";

        # Process synth(401, reason)
        if (resp.status == 401) {
            set resp.http.WWW-Authenticate = "Basic realm=Restricted";
        }
        # Process synth(200, reason)
        if (resp.status == 200) {
            set resp.status = 200;
            set resp.http.Allow = "HEAD, GET, POST, OPTIONS, PUT, DELETE";
            set resp.reason = "OK";
            return (deliver);
        }
        # Process synth(301, reason)
        if (resp.status == 301) {
            set resp.http.Location = resp.reason;
            set resp.status = 301;
            set resp.reason = "Moved Permanently";
            return (deliver);
        }
        # Process synth(302, reason)
        if (resp.status == 302) {
            set resp.http.Location = resp.reason;
            set resp.status = 302;
            set resp.reason = "Found";
            return (deliver);
        }
        # Process synth(303, reason)
        if (resp.status == 303) {
            set resp.http.Location = resp.reason;
            set resp.status = 303;
            set resp.reason = "See Other"; 
            return (deliver);
        }
        set resp.http.Content-Type = "text/html; charset=utf-8";
}

sub vcl_hit {
        if (req.http.Cache-Control ~ "no-cache") {
                # Ignore requests via proxy caches,  IE users and badly behaved crawlers
                # like msnbot that send no-cache with every request.
                if (! (req.http.Via || req.http.User-Agent ~ "bot|MSIE")) {
                        return (miss);
                } 
        }
}

sub vcl_deliver {
    if(obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }
}

# SITE SPECIFIC
# Any site-specific configuration can be provided in /etc/varnish/site.vcl
# Or if needed, this file (/etc/varnish/default.vcl) could be overridden as well.
include "site.vcl";

# TAIL

# If something needs to be added after the site-specific configuration, add it here

sub vcl_recv {}
sub vcl_backend_response {}
sub vcl_backend_error {}
sub vcl_synth {}
sub vcl_hit {}
sub vcl_deliver {}
