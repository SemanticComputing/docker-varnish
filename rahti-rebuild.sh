SERVER="https://rahti.csc.fi:8443"
PROJECT_NAME="seco"

APP_NAME="varnish"
ENVIRONMENT="production"

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

# Start the build
BUILDCONFIG=$(oc get BuildConfig -l "app=$APP_NAME,environment=$ENVIRONMENT" -o name)
if [ $? == 0 ]; then
    oc start-build $BUILDCONFIG
fi
