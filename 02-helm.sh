#!/bin/bash
# === HELM installation

# . ./init.sh
kubectl config view | grep current-context:

# HELM role
cat > work/01-tiller-rbac.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: tiller-clusterrolebinding
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: ""
EOF
cat work/01-tiller-rbac.yaml
kubectl apply -f work/01-tiller-rbac.yaml

# HELM client installation
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > 11-get_helm.sh
chmod 750 11-get_helm.sh
./11-get_helm.sh

# HELM server installation
helm init --service-account tiller

echo "---> wait for tiller pods up and running: ..."
while true;
do
  sleep ${SLEEP:=3}
  echo -n .
  if kubectl get pods --all-namespaces | grep tiller | grep -q Running; then
    sleep 6s
    echo .
    echo "INFO: tiller pod(s) STATUS is Running"
    kubectl get pods --all-namespaces | grep tiller
    break
  elif kubectl get pods | grep tiller | grep -q ImagePullBackOff; then
    echo .
    echo "ERROR: tiller pod(s) STATUS is ImagePullBackOff"
    kubectl get pods --all-namespaces | grep tiller
    break
  fi
done
