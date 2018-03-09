SERVER="https://rahti.csc.fi:8443"
PROJECT_NAME="seco"
TEMPLATE_NAME="seco-image"

APP_NAME="varnish"
ENVIRONMENT="production"
GIT_URL="git@version.aalto.fi:seco/docker-varnish.git"
GIT_REF=""
GIT_DIR=""
GIT_SECRET="seco-git"
#FROM="apache-varnish"
#IP="172.30.10.33"
#CONTAINER_PORT="80"
#TARGET_PORT="80"
#WEBHOOK_SECRET="JOacMuKpbvKh"
#IP="172.30.10.33"
#PVC_NAME="volume-name"
#PVC_TARGET="/m/"
#CORES="1"
#MEM="2g"


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

# Generate resources yaml from the template
YAML=$(oc process -o yaml $TEMPLATE_NAME \
    -p "APP_NAME=$APP_NAME" \
    -p "ENVIRONMENT=$ENVIRONMENT" \
    -p "GIT_URL=$GIT_URL" \
    -p "GIT_REF=$GIT_REF" \
    -p "GIT_DIR=$GIT_DIR" \
    -p "GIT_SECRET=$GIT_SECRET"
    #-p "FROM=$FROM" \
    #-p "IP=$IP" \
    #-p "PVC_NAME=$PVC_NAME" \
    #-p "PVC_TARGET=$PVC_TARGET" \
    # CORES, MEM not added to the templates yet
    #-p "CORES=$CORES" \
    #-p "MEM=$MEM" \
    #-p "ENV1_NAME=$ENV1_NAME" \
    #-p "ENV1_VALUE=$ENV1_VALUE" \
    #-p "ENV2_NAME=$ENV2_NAME" \
    #-p "ENV2_VALUE=$ENV2_VALUE" \
    #-p "ENV3_NAME=$ENV3_NAME" \
    #-p "ENV3_VALUE=$ENV3_VALUE" \
    #-p "ENV4_NAME=$ENV4_NAME" \
    #-p "ENV4_VALUE=$ENV4_VALUE" \
    #-p "ENV5_NAME=$ENV5_NAME" \
    #-p "ENV5_VALUE=$ENV5_VALUE" \
    #-p "ENV6_NAME=$ENV6_NAME" \
    #-p "ENV6_VALUE=$ENV6_VALUE" \
    #-p "ENV7_NAME=$ENV7_NAME" \
    #-p "ENV7_VALUE=$ENV7_VALUE" \
    #-p "ENV8_NAME=$ENV8_NAME" \
    #-p "ENV8_VALUE=$ENV8_VALUE"
    )

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
