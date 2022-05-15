#!/bin/bash

echo "Try to find the xonotic cluster..."

kubectl config get-clusters | grep 500480925365 | grep xonotic

if [ $? != 0 ]; then
    echo "Error: Failed find cluster."
fi

echo "Try to check simple server ..."

#nc -u ${IP} ${PORT}
#
#Hello World !
#ACK: Hello World !
#EXIT