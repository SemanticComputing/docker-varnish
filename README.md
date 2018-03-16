# varnish

## Notes
Following are defined in this image:

```
ENV FILE_DEFAULT_VCL "/etc/varnish/default.vcl"
ENV FILE_SITE_VCL "/etc/varnish/site.vcl"
ENV PATH_LOG_VARNISH "/var/log/varnish"
ENV FILE_LOG_VARNISH "$PATH_LOG_VARNISH/varnish.log"
ENV PATH_VAR_VARNISH "/var/lib/varnish"
```
`FILE_DEFAULT_VCL` contains some common configuration and includes `FILE_SITE_VCL` by default.
You need to start varnish in you downstream image by calling e.g.
```
varnishd -f "$FILE_DEFAULT_VCL" -s "malloc,1g"
```

## Pulling

rahti-scripts is a submodule therefore you might want to use

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
