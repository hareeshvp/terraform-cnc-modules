#!/usr/bin/env bash

set -xv
set -euo pipefail


export COVERITY_APP_NAME=${COVERITY_APP_NAME:-"coverity-example"}
export COVERITY_CHART_LOCATION=${COVERITY_CHART_LOCATION:-sig-repo/cnc}

export COVERITY_ANALYSIS_NODE_NAME=${COVERITY_ANALYSIS_NODE_NAME:-kind-control-plane}
export COVERITY_ANALYSIS_NODE_LABEL=${COVERITY_ANALYSIS_NODE_LABEL:-"coverity-custom-node-pool-label"}

export COVERITY_NS=${COVERITY_NS:-"coverity"}
export COVERITY_LICENSE_SECRET_NAME="${COVERITY_APP_NAME}-license"
export COVERITY_HOST=${COVERITY_HOST:-"coverity-example.local"}

export MINIO_COVERITY_BUCKET_NAME="${COVERITY_NS}-uploads-bucket"
export MINIO_ROOT_USER=${MINIO_ROOT_USER:-"admin"}
export MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD:-"synopsys"}


kubectl create ns "$COVERITY_NS" || true


helm upgrade --install "cim-pg" postgresql \
  --repo https://charts.bitnami.com/bitnami \
  --namespace "$COVERITY_NS" \
  --version "10.13.11" \
  --set metrics.enabled=true \
  --set postgresqlDatabase=cim \
  -f postgres-values.yaml

# need to wait a few seconds, otherwise you might see an "error: no matching resources found" failure
sleep 5

kubectl wait --for=condition=ready pod \
  -l app.kubernetes.io/name=postgresql \
  --namespace "$COVERITY_NS" \
  --timeout=10m


# label node for job farm
# note that this node name depends on the kind cluster name
pool_type=$(kubectl get nodes -o=jsonpath='{.items[0].metadata.labels.pool-type}')
if [ "${pool_type}" != "${COVERITY_ANALYSIS_NODE_LABEL}" ]; then
  kubectl label nodes --overwrite "${COVERITY_ANALYSIS_NODE_NAME}" pool-type="${COVERITY_ANALYSIS_NODE_LABEL}"
  echo "verifying job farm kube node label -- $(kubectl get nodes -o=jsonpath='{.items[0].metadata.labels.pool-type}')"
fi


helm upgrade --install "coverity-minio" minio \
  --repo https://charts.bitnami.com/bitnami \
  --version 10.1.4 \
  --debug \
  --namespace "$COVERITY_NS" \
  --set defaultBuckets="${MINIO_COVERITY_BUCKET_NAME}" \
  --set auth.rootUser="${MINIO_ROOT_USER}" \
  --set auth.rootPassword="${MINIO_ROOT_PASSWORD}" \
  -f minio-values.yaml


kubectl create secret generic "$COVERITY_LICENSE_SECRET_NAME" -n "$COVERITY_NS" \
  --from-file=license.dat

#  kubectl create secret tls "$COVERITY_CIM_TLS_NGINX_SECRET_NAME" \
#    --namespace "$COVERITY_NS" \
#    --cert=tls.crt \
#    --key=tls.key


helm install "$COVERITY_APP_NAME" "${COVERITY_CHART_LOCATION}" \
  --wait \
  --timeout 60m0s \
  --debug \
  --namespace "$COVERITY_NS" \
  --set cnc-storage-service.s3.bucket="${COVERITY_NS}-uploads-bucket" \
  --set "licenseSecretName=${COVERITY_LICENSE_SECRET_NAME}" \
  --set "cnc-storage-service.s3.accessKey=$MINIO_ROOT_USER" \
  --set "cnc-storage-service.s3.secretKey=$MINIO_ROOT_PASSWORD" \
  --set "cim.cimweb.webUrl=https://${COVERITY_HOST}:443" \
  --set "cnc-processor-loader.environment.CUSTOMNODEPOOL_LABEL=${COVERITY_ANALYSIS_NODE_LABEL}" \
  --set "cnc-processor-loader.environment.COVANALYSIS_DEFAULTPOOLTYPE=${COVERITY_ANALYSIS_NODE_LABEL}" \
  --set "licenseSecretName=${COVERITY_LICENSE_SECRET_NAME}" \
  -f coverity-values.yaml \
  "$@"
