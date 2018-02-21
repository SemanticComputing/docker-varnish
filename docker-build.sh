#! /bin/bash

PARAMS=""

while getopts ":c" opt; do
    case ${opt} in
        c)
            PARAMS="$PARAMS --no-cache"
            ;;
    esac
done

docker build $PARAMS -t varnish .
