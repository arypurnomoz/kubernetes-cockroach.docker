#!/bin/sh

# set -e

HOST=${HOST:-`hostname -i`}

if [ -n "$DOMAIN" ]; then
  HOST="`hostname -i|sed 's/\./-/g'`.$DOMAIN"
fi
 
JOIN=""
BASE_URL="https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT"

QUERY_URL="$BASE_URL/api/v1"
if [ -n "$POD_NAMESPACE" ]; then
  QUERY_URL="$QUERY_URL/namespaces/$POD_NAMESPACE"
fi

TOKEN=`cat /run/secrets/kubernetes.io/serviceaccount/token`

_curl() {
  curl -s --cacert /run/secrets/kubernetes.io/serviceaccount/ca.crt --header "Authorization: Bearer $TOKEN" $@
}


if [ "$SELECTOR" ]; then
  URL="$QUERY_URL/pods?labelSelector=$SELECTOR"

  for pod in `_curl $URL | grep selfLink | grep -v "$POD_NAME" | grep -Eo '/api[^"]*'`; do
    PEER_NAMESPACE=`echo $pod | cut -d/ -f5`
    PEER_NAME=`echo $pod | cut -d/ -f7`
    if [ "$PEER_NAME" ]; then
      POD_IP=`_curl $BASE_URL$pod| grep podIP |awk '{print $2}'|sed 's/[",]//g' | sed 's/\./-/g'`
      PEER_NODES="$PEER_NODES,$POD_IP.$PEER_NAMESPACE.pod.$CLUSTER_DOMAIN"
    fi
  done
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


