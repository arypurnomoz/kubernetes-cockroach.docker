#!/bin/sh

set -e

if [ ! "$KUBE_MASTER" ]; then 
  echo env KUBE_MASTER is required
  exit 1
fi

ROACH_ADDRESS=`ifconfig eth0|grep 'inet addr'|cut -d: -f2| awk '{print $1}'`

PEER_NODES=`wget $KUBE_MASTER/api/v1/pods?labelSelector=app=cockroach -qO -|grep podIP|awk '{print $2}'|sed 's/"//g'|sed 's/,/:8080/'|xargs echo`
PEER_NODES=`echo $PEER_NODES|sed 's/ /,/'`

echo peers $PEER_NODES

if [ "$ROACH_IDENDITY" ]; then 
  echo $ROACH_IDENDITY > /store/IDENTITY
fi



exec /cockroach/cockroach start --addr=${ROACH_ADDRESS}:8080 --gossip=tcp=${PEER_NODES} $@ 
