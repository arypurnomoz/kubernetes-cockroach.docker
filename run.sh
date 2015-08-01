#!/bin/sh

set -e

if [ ! "$KUBE_MASTER" ]; then 
  echo env KUBE_MASTER is required
  exit 1
fi

if [ ! "$SELECTOR" ]; then 
  echo env SELECTOR is required
  exit 1
fi

ROACH_ADDRESS=`ifconfig eth0|grep 'inet addr'|cut -d: -f2| awk '{print $1}'`

PEER_NODES=`wget $KUBE_MASTER/api/v1/pods?labelSelector=$SELECTOR -qO -|grep podIP|grep -v $ROACH_ADDRESS|awk '{print $2}'|sed 's/"//g'|sed 's/,/:8080/'|xargs echo`
PEER_NODES=`echo $PEER_NODES|sed 's/ /,/'`

GOSSIP="self="
if [ "$PEER_NODES" ]; then
  GOSSIP="tcp=${PEER_NODES}"
  echo peers $PEER_NODES
fi

echo gossip $GOSSIP

if [ "$ROACH_IDENDITY" ]; then 
  echo "$ROACH_IDENDITY" > /store/IDENTITY
fi

exec /cockroach/cockroach start --addr=${ROACH_ADDRESS}:8080 --gossip=${GOSSIP} $@ 
