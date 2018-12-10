#!/bin/bash
# === PostgreSQL installation

## We need variables from init.sh script
. ./init.sh
kubectl config view | grep current-context: | tee -a $DEPLOYMENT_LOG

DIR_STEP="03-postgresql"
# mkdir -p -m 775 ${DIR_STEP} | tee -a $DEPLOYMENT_LOG
mkdir -p work/${DIR_STEP} | tee -a $DEPLOYMENT_LOG
# pushd ${DIR_STEP}

## Create Azure storage account for persistent volume
# az storage account create --name ${MY_STORAGE_ACCOUNT} --resource-group ${MY_RESOURCE_GROUP} --location ${MY_LOCATION} --sku ${MY_STOCK_KEEPING_UNIT} | tee -a $DEPLOYMENT_LOG

# # AKS disk
# cat > ./work/${DIR_STEP}/01_AKS_StorageClass.yml <<EOF
# kind: StorageClass
# apiVersion: storage.k8s.io/v1
# metadata:
#   name: default
#   annotations:
#     storageclass.kubernetes.io/is-default-class: false
# provisioner: kubernetes.io/azure-disk
# parameters:
#   storageaccounttype: ${MY_STOCK_KEEPING_UNIT}
#   location: ${MY_LOCATION}
#   storageAccount: ${MY_STORAGE_ACCOUNT}
#   kind: Managed
#   # kind: Shared
# mountOptions:
#   - debug
# EOF
# cat ./work/${DIR_STEP}/01_AKS_StorageClass.yml
# kubectl delete -f ./work/${DIR_STEP}/01_AKS_StorageClass.yml 2>/dev/null; kubectl apply -f ./work/${DIR_STEP}/01_AKS_StorageClass.yml | tee -a $DEPLOYMENT_LOG

DB_ADMIN_PASS=$(head /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
export DB_ADMIN_PASS=${DB_ADMIN_PASS}
echo "DB_ADMIN_PASS: ${DB_ADMIN_PASS}" | tee -a $DEPLOYMENT_LOG

kubectl delete secret generic ${POSTGRES_ADMIN_PASSWORD_SECRET} 2>/dev/null
kubectl create secret generic ${POSTGRES_ADMIN_PASSWORD_SECRET} --from-literal=username='postgres' --from-literal=password="${DB_ADMIN_PASS}"
kubectl get secret ${POSTGRES_ADMIN_PASSWORD_SECRET} -o jsonpath="{.data.password}" | base64 --decode

return 0
