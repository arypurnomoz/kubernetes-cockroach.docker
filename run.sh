#!/bin/sh

if [ ! "$NAMESPACE" ]; then
  >&2 echo \$NAMESPACE variable required
  exit 1
fi

set -e

echo ip `hostname -i`

GOSSIP="self"

if [ "$SELECTOR" ]; then
  echo selector $SELECTOR
  PEER_NODES=$(curl -s \
    --cacert /run/secrets/kubernetes.io/serviceaccount/ca.crt \
    -H "Authorization: Bearer `cat /run/secrets/kubernetes.io/serviceaccount/token`" \
    https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT/api/v1/namespaces/$NAMESPACE/pods?labelSelector=$SELECTOR \
    | grep podIP | grep -v `hostname -i` |awk '{print $2}'|sed 's/"//g' | sed 's/,/:26257/' | xargs echo)
  if [ "$PEER_NODES" ]; then
    GOSSIP="tcp=$PEER_NODES"
    echo peers $PEER_NODES
  fi
fi

echo gossip $GOSSIP

if [ "$GOSSIP" == "self"]; then
  /cockroach/cockroach init --stores=ssd=/store
fi

exec /cockroach/cockroach start \
  --stores=ssd=/store \
  --host=`hostname -i` \
  --gossip=$GOSSIP \
  $@

