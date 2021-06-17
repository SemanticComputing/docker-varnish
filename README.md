# varnish

## Building

Run something along these lines:
```
docker build -t varnish .
```

## Running

In order to run the varnish with a custom vcl config mounted, you can for example run something along the lines:
```
docker run -it --rm -u "$(id -u)" -p 8080:8080 -v '/path/to/default.vcl:/etc/varnish/default.vcl' varnish
```

## Configuration

Below are listed environment variables (and their default values) for configuring the container.

```
FILE_DEFAULT_VCL="/etc/varnish/default.vcl" # Path to the varnish configuration
VARNISH_MEM="1G" # Memory for varnish
VARNISH_VSL_MASK_HASH="" # If nonempty, log hashes - run varnishd with -p vsl_mask=+Hash
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
These environment variables do not have effect if you provide your own default.vcl

* If set, CACHE_AUTH will cause content to be accessible for TTL even if the Authorization is invalidated on the backend. IGNORE_AUTH may give access to content with invalid Authorization
* By default, requests containing Authorization are not cached.
