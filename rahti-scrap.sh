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

# Remove resources
oc delete all -l "app=$APP_NAME,environment=$ENVIRONMENT"
