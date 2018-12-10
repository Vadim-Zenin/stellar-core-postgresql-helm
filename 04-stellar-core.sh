#!/bin/bash
# === Stellar-core installation

## We need variables from init.sh script
. ./init.sh
kubectl config view | grep current-context: | tee -a $DEPLOYMENT_LOG

if ! [ -x "$(command -v helm)" ]; then
  echo 'Helm not installed' >&2
  exit 1
fi

DIR_STEP="04-stellar-core"
mkdir -p work/${DIR_STEP} | tee -a $DEPLOYMENT_LOG

if [ $(which docker) ]; then
  echo "INFO: docker found"
else
  echo "INFO: installing docker.io"
  sudo apt update -qq; sudo apt install -y docker.io
fi

if [[ ! -f work/${DIR_STEP}/node-seed.txt ]]; then
  sudo docker run --rm -it --entrypoint '' satoshipay/stellar-core stellar-core --genseed | tee work/${DIR_STEP}/node-seed.txt
fi

MY_STELLAR_SECRET_SEED=$(cat work/${DIR_STEP}/node-seed.txt | grep seed | cut -f3 -d' ')
MY_STELLAR_PUBLIC_SEED=$(cat work/${DIR_STEP}/node-seed.txt | grep Public | cut -f2 -d' ')

## Create Azure storage account for persistent volume
az storage account list -o table | grep ${MY_STORAGE_ACCOUNT} | grep -q available
if [[ $?=0 ]]; then
  echo "Storage account ${MY_STORAGE_ACCOUNT} is available" | tee -a $DEPLOYMENT_LOG
else
  echo "Creating storage account ${MY_STORAGE_ACCOUNT}"
  az storage account create --name ${MY_STORAGE_ACCOUNT} --resource-group ${MY_RESOURCE_GROUP} --location ${MY_LOCATION} --sku ${MY_STOCK_KEEPING_UNIT} | tee -a $DEPLOYMENT_LOG
fi

MY_STORAGE_CLASS_NAME="${MY_STOCK_KEEPING_UNIT,,}"
MY_STORAGE_CLASS_NAME="${MY_STORAGE_CLASS_NAME//_/-}"
MY_STORAGE_CLASS_NAME="${MY_LOCATION}-${MY_STORAGE_CLASS_NAME}"

# AKS disk
cat > ./work/${DIR_STEP}/01_AKS_StorageClass.yml <<EOF
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ${MY_STORAGE_CLASS_NAME}
  annotations:
    storageclass.kubernetes.io/is-default-class: true
provisioner: kubernetes.io/azure-disk
parameters:
  storageaccounttype: ${MY_STOCK_KEEPING_UNIT}
  location: ${MY_LOCATION}
  storageAccount: ${MY_STORAGE_ACCOUNT}
  kind: Managed
  # kind: Shared
mountOptions:
  - debug
EOF
cat ./work/${DIR_STEP}/01_AKS_StorageClass.yml
kubectl delete -f ./work/${DIR_STEP}/01_AKS_StorageClass.yml 2>/dev/null; kubectl apply -f ./work/${DIR_STEP}/01_AKS_StorageClass.yml | tee -a $DEPLOYMENT_LOG

kubectl get secret ${POSTGRES_ADMIN_PASSWORD_SECRET} -o jsonpath="{.data.password}" | base64 --decode

pushd work/${DIR_STEP}
helm del --purge ${MY_APP_NAME} 2>/dev/null
kubectl delete persistentvolumeclaim $(kubectl get pvc | grep ${MY_APP_NAME} | cut -f1 -d' ') 2>/dev/null
rm -fr charts 2>/dev/null; git clone https://github.com/helm/charts.git && \
pushd charts/
helm dependency update stable/${MY_APP_NAME}
helm install --name ${MY_APP_NAME} --timeout 600 \
  --set nodeSeed=${MY_STELLAR_SECRET_SEED} \
  --set persistence.storageClass=${MY_STORAGE_CLASS_NAME} \
  --set postgresql.persistence.storageClass=${MY_STORAGE_CLASS_NAME} \
  stable/${MY_APP_NAME} | tee -a ../../../$DEPLOYMENT_LOG
popd
popd
  # --set postgresql.existingSecret=${POSTGRES_ADMIN_PASSWORD_SECRET} \
  # --set persistence.enabled=true \
  # --set persistence.size=8Gi \
  # --set postgresql.persistence.enabled=true \
  # --set postgresql.persistence.size=1Gi \

echo "---> wait for ${MY_APP_NAME} pods up and running: ..."
while true;
do
  sleep ${SLEEP:=3}
  echo -n .
  if kubectl get pods --all-namespaces | grep ${MY_APP_NAME} | grep -q Running; then
    sleep 5s
    echo .
    echo "INFO: ${MY_APP_NAME} pod(s) STATUS is Running" | tee -a $DEPLOYMENT_LOG
    kubectl get pods,deploy,rs,sts,ds,svc,endpoints,pv,pvc --all-namespaces | grep ${MY_APP_NAME}
    break
  elif kubectl get pods --all-namespaces | grep ${MY_APP_NAME} | grep -q Error; then
    echo .
    echo "ERROR: ${MY_APP_NAME} pod(s) STATUS contains Error" | tee -a $DEPLOYMENT_LOG
    kubectl get pods --all-namespaces | grep ${MY_APP_NAME}
    break
  elif kubectl get pods --all-namespaces | grep ${MY_APP_NAME} | grep -q ImagePullBackOff; then
    echo .
    echo "ERROR: ${MY_APP_NAME} pod(s) STATUS is ImagePullBackOff" | tee -a $DEPLOYMENT_LOG
    kubectl get pods --all-namespaces | grep ${MY_APP_NAME}
    break
  fi
done

return 0

az vm update -g ${MY_RESOURCE_GROUP} -n <name>
kubectl get pods,deploy,rs,sts,ds,svc,endpoints,pv,pvc --all-namespaces | grep stellar-core
