#!/bin/bash
# === Stellar-core using Helm charts installation


if [ $(which az) ]; then
    echo "INFO: az cli found"
else
    echo "ERROR: missing az cli in PATH"
    return 1
fi

export MY_APP_NAME="stellar-core"
export MY_RESOURCE_GROUP="<change-me>"
export MY_STORAGE_ACCOUNT="<change-me>"
export MY_LOCATION="westeurope"
export MY_STOCK_KEEPING_UNIT="Standard_LRS"
DEPLOYMENT_LOG="logs/deployment-`date +%Y%m%d-%H%M`.log"
MY_SECRET_NAMESPACE="${MY_APP_NAME}"
DB_ADMIN="postgres"
POSTGRES_ADMIN_PASSWORD_SECRET="postgres-admin-password"

mkdir -p work
mkdir -p logs

az configure --defaults location=${MyLocation}

return 0
