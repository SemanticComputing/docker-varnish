# varnish

## Pulling

rahti-scripts is a submodule therefore you might want to use e.g.

```
git clone --recursive
```
and

```
git pull --recurse-submodules
```


## Building

```
docker build -t varnish .
```

## Running

In order to run the varnish with a custom vcl config mounted, you can for example run something along the lines:
```
docker run -it --rm -u "$(id -u)" -p 8080:8080 -v '/path/to/default.vcl:/etc/varnish/default.vcl' varnish
```

## Notes

If the `default.vcl` config file is not provided, the container generates some default configuration - see the included `default.vcl` and `generate-site-vcl.sh` for details. In this case the config generation can be controlled by environment variables:
```
VARNISH_CACHE_COOKIES # Cache requests with cookies and include the cookie in hash
VARNISH_IGNORE_COOKIES # Cache requests with cookies, but ignore the cookie value in hash
VARNISH_CACHE_AUTH # Cache requests with Authorization and include the Authorization in hash
VARNISH_IGNORE_AUTH # Cache requests with Authorization, but ignore the Authorization in hash
VARNISH_DEFAULT_TTL # Time for which objects are cached
VARNISH_BACKEND_IP # Backend IP address
VARNISH_BACKEND_PORT # Backend port
```

* If set, CACHE_AUTH will cause content to be accessible for TTL even if the Authorization is invalidated on the backend. IGNORE_AUTH may give access to content with invalid Authorization
* By default, requests containing Authorization are not cached.
