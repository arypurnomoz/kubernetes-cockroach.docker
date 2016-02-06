#!/bin/sh

# set -e

HOST=${HOST:-`hostname -i`}

JOIN=""

TOKEN=`cat /run/secrets/kubernetes.io/serviceaccount/token`

if [ "$SELECTOR" ]; then
  URL="$QUERY_URL/pods?labelSelector=$SELECTOR"

  
  PEER_NODES=$(curl -s \
    --cacert /run/secrets/kubernetes.io/serviceaccount/ca.crt \
    -H "Authorization: Bearer $TOKEN" \
    https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT/api/v1/namespaces/$NAMESPACE/pods?labelSelector=$SELECTOR \
    | grep podIP | grep -v `hostname -i` |awk '{print $2}'|sed 's/"//g' | sed 's/,/:26257/' | xargs echo)
    
  if [ "$PEER_NODES" ]; then
    JOIN="--join=$PEER_NODES"
  fi
fi

echo name=$POD_NAME host=$HOST $JOIN

exec /cockroach/cockroach start \
  --stores=ssd=/store \
  --host=$HOST \
  $JOIN \
  $@


