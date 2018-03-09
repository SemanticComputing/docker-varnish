#!/bin/bash

. rahti-params.sh

# Login if needed
CURRENT_SERVER=$(oc status | head -n 1 | awk -F' ' '{print $NF}')
oc whoami
if [ $? != 0 ] || [ $CURRENT_SERVER != $SERVER ]; then
    oc login $SERVER
fi

# Switch project
oc project $PROJECT_NAME
if [ $? != 0 ]; then
    exit 1
fi

# Check template exists
oc get template "$TEMPLATE_NAME"
if [ $? != 0 ]; then
    echo "Template $TEMPLATE_NAME missing from the OpenShift project. Upload the OpenShift templates first"
    exit 1
fi

# Check base image exists
if [ "$FROM" != "" ]; then
    oc get imagestreamtags "$FROM:latest"
    if [ $? != 0 ]; then
        echo "ImageStreamTag $FROM:latest missing from the OpenShift internal registry. Please deploy/build it first"
        echo "Note: If the image is already deployed and built, see that IMAGE_NAME has the environment prefix e.g. production-apache-varnish."
        echo "You can list available images with 'oc get imagestreamtags'"
        exit 1;
    fi
fi;

# Check PersistentVolumeCLaim exists
if [ "$PVC_NAME" != "" ]; then
    oc get template "$PVC_NAME"
    if [ $? != 0 ]; then
        echo "PersitentVolumeClaim $PVC_NAME missing from the OpenShift project. Create the volume claim first"
    fi;
fi;

# Build OC_PROCESS_CMD
OC_PROCESS_CMD="oc process -o yaml"
append_param() {
    if [ ! -z $2 ]; then
        OC_PROCESS_CMD="$OC_PROCESS_CMD -p $1=$2"
    fi
}
OC_PROCESS_CMD="$OC_PROCESS_CMD $TEMPLATE_NAME"
append_param "APP_NAME" "$APP_NAME"
append_param "ENVIRONMENT" "$ENVIRONMENT"
append_param "GIT_URL" "$GIT_URL"
append_param "GIT_REF" "$GIT_REF"
append_param "GIT_DIR" "$GIT_DIR"
append_param "GIT_SECRET" "$GIT_SECRET"
append_param "FROM" "$FROM"
append_param "IP" "$IP"
append_param "PVC_NAME" "$PVC_NAME"
append_param "PVC_TARGET" "$PVC_TARGET"
append_param "CORES" "$CORES"
append_param "MEM" "$MEM"
append_param "ENV1_NAME" "$ENV1_NAME"
append_param "ENV1_VALUE" "$ENV1_VALUE"
append_param "ENV2_NAME" "$ENV2_NAME"
append_param "ENV2_VALUE" "$ENV2_VALUE"
append_param "ENV3_NAME" "$ENV3_NAME"
append_param "ENV3_VALUE" "$ENV3_VALUE"
append_param "ENV4_NAME" "$ENV4_NAME"
append_param "ENV4_VALUE" "$ENV4_VALUE"
append_param "ENV5_NAME" "$ENV5_NAME"
append_param "ENV5_VALUE" "$ENV5_VALUE"
append_param "ENV6_NAME" "$ENV6_NAME"
append_param "ENV6_VALUE" "$ENV6_VALUE"
append_param "ENV7_NAME" "$ENV7_NAME"
append_param "ENV7_VALUE" "$ENV7_VALUE"
append_param "ENV8_NAME" "$ENV8_NAME"
append_param "ENV8_VALUE" "$ENV8_VALUE"
# Generate resources yaml from the template
echo "$OC_PROCESS_CMD"
YAML=$($OC_PROCESS_CMD)

echo ""
echo "Resources to be created:"
echo "$YAML"
echo ""

read -p "Create the resources (y/n)?" choice
case "$choice" in 
    y|Y ) ;;
    * ) exit 1;;
esac
echo ""

# Create the resources
echo "$YAML" | oc create -f -
if [ $? != 0 ]; then exit 1; fi;

# Start the build
BUILDCONFIG=$(oc get BuildConfig -l "app=$APP_NAME,environment=$ENVIRONMENT" -o name)
if [ $? == 0 ]; then
    oc start-build $BUILDCONFIG
fi
