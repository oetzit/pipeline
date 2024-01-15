#!/usr/bin/env bash

# Exit on error.
set -o errexit

printf "\n# Checking kubectl is available...\n\n"
kubectl version

printf "\n# Checking cluster is reachable...\n\n"
kubectl cluster-info

K8S_NAMESPACE="prd-oetzit"
printf "\n# Checking namespace %s exists...\n\n" "$K8S_NAMESPACE"
kubectl get namespaces | grep "$K8S_NAMESPACE"

K8S_LABEL="app.kubernetes.io/component=database"
printf "\n# Getting name of first pod labelled %s ...\n\n" "$K8S_LABEL"
K8S_POD_NAME=$(kubectl get pods -l "$K8S_LABEL" -n "$K8S_NAMESPACE" -o=jsonpath='{.items[0].metadata.name}')
echo "$K8S_POD_NAME"

DB_NAME="oetzit_prd_db"
DB_USER="oetzit_prd_un"
SOURCE_TBL_NAME="$1"
TARGET_CSV_PATH="$2"
printf "\n# Copying table %s to file %s ...\n\n" "$SOURCE_TBL_NAME" "$TARGET_CSV_PATH"
kubectl \
    exec -it "$K8S_POD_NAME" -n "$K8S_NAMESPACE" \
    -- psql \
        -U "$DB_USER" \
        -d "$DB_NAME" \
        -c "\copy (SELECT * FROM $SOURCE_TBL_NAME) To STDOUT With CSV HEADER" \
> "$TARGET_CSV_PATH"
