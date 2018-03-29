# varnish

## Notes
Following paths

```
ENV FILE_DEFAULT_VCL "/etc/varnish/default.vcl"
ENV FILE_SITE_VCL "/etc/varnish/site.vcl"
ENV PATH_LOG_VARNISH "/var/log/varnish"
ENV FILE_LOG_VARNISH "$PATH_LOG_VARNISH/varnish.log"
ENV PATH_VAR_VARNISH "/var/lib/varnish"
```

`FILE_DEFAULT_VCL` contains some common configuration and by default includes `FILE_SITE_VCL`, which is meant for app-specific configuration.

You can exec varnish by calling
```
$EXEC_VARNISH
```
, which will generate `FILE_SITE_VCL` if it does not exist, start varnish and forward varnishlog to stdout. Generation of `FILE_SITE_VCL` can be controlled using the following environment variables:
```
VARNISH_CACHE_COOKIES # Cache requests with cookies and include the cookie in hash
VARNISH_IGNORE_COOKIES # Cache requests with cookies, but ignore the cookie value in hash
VARNISH_CACHE_AUTH # Cache requests with Authorization and include the Authorization in hash
VARNISH_IGNORE_AUTH # Cache requests with Authorization, but ignore the Authorization in hash
VARNISH_DEFAULT_TTL # Time for which objects are cached
VARNISH_BACKEND_IP # Backend IP address
VARNISH_BACKEND_PORT # Backend port
```
`Remember that CACHE_AUTH will cause content to be accessible for TTL even if the Authorization is invalidated on the backend. IGNORE_AUTH will give access to content with invalid Authorization`
`Do not set these two if you don't know what you are doing`
Default behaviour is to not cache anything with Cookies or Authorization.

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
./docker-build.sh [-c]
```
* -c
    * no cache


## Running in docker

```
./docker-run.sh
```
The service is available at localhost:8080 by default.


## Debugging in docker

```
docker exec -it <container-name> bash`
```

Opens bash inside the running container.


## Running on Rahti

### Initialize OpenShift resources

```
./rahti-init.sh
```
Can be done via the web intarface as well. See rahti-params.sh for the template and parameters to use.

### Rebuild the service

```
./rahti-rebuild.sh
```
Can be done via the web interface as well. Navigate to the BuildConfig in question and click "Start Build"

### Remove the OpenShift resources

```
./rahti-scrap.sh
```

### Webhooks

The template also generates WebHook for triggering the build followed by redeploy.
You can see the exact webhook URL with e.g. following commands
```
oc describe bc <ENVIRONMENT>-<APP_NAME> | grep -A 1 "Webhook"
oc describe bc -l "app=<APP_NAME>,environment=<ENVIRONMENT>"
```
or via the OpenShift web console by navigating to the BuildConfig in question.
