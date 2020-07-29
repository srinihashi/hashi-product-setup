#!/bin/bash

# Display --help [Command options]
if [ $1 = "--help" ]; then
     echo "USAGE: #linux_vault_config_dir.sh <product[vault | consul | nomad]> <backend_storage [file | raft | consul] <storage_path> <config_dir> <log_dir> <auto-unseal [azure | gcp | hsm]>"
     exit
fi

# Set input arguments
PRODUCT=$1
if [ "${PRODUCT,,}" = "vault" ];
then
  PRODUCT_PROJECT=project
  AUTO_UNSEAL=$6
  TENANT_ID="0e3e2e88-8caf-41ca-b4da-e3b33b6c52ec"
  CLIENT_ID="81a29d4b-40b1-41e5-89a0-6b9f5c8840c4"
  CLIENT_SECRET="eR6Anls-3KZ:6ca3lw_TEXkBkd_SoZ1L"
  VAULT_NAME="Srini-Vault-Auto-Unseal"
  KEY_NAME="Vault-Unseal-Key2"
else
  PRODUCT_PROJECT=""
fi

BACKEND_STORAGE=$2
STORAGE_PATH=$3
PRODUCT_CONFIG_DIR=$4/${PRODUCT}.d
#PRODUCT_CONFIG_PATH=/etc/${PRODUCT}.d
PRODUCT_CONFIG_FILE=${PRODUCT}.hcl
#TMP_FILE=/tmp/${PRODUCT}.service
#SERVICE_FILE=/etc/systemd/system/${PRODUCT}.service

# Set dir for product logs
LOG_DIR=$5

# Set host IP Address
#HOST_IP=`ifconfig | sed -n '2p' | awk '{ print $2 }'`
HOST_IP=`curl http://checkip.amazonaws.com`

# Set hostname
HOST_NAME=`hostname`

# Create Product config file
echo "
disable_mlock = true
ui = true
log_level = \"Debug\"
listener \"tcp\" {
 address     = \"127.0.0.1:8200\"
 tls_disable = 1
 telemetry {
    unauthenticated_metrics_access = true
  }
}

listener \"tcp\" {
  address = \"${HOST_IP}:8200\"
  cluster_address = \"${HOST_IP}:8201\"
  tls_disable = true
}
" > /tmp/${PRODUCT}.hcl

case $AUTO_UNSEAL in
azure)
  echo "
  seal \"azurekeyvault\" {
    tenant_id      = \"${TENANT_ID}\"
    client_id      = \"${CLIENT_ID}\"
    client_secret  = \"${CLIENT_SECRET}\"
    vault_name     = \"${VAULT_NAME}\"
    key_name       = \"${KEY_NAME}\"
  }
  " >> /tmp/${PRODUCT}.hcl
  ;;
  
gcp)
  
  ;;

hsm)
  
  ;;

*)
  ;;
 
esac


case $BACKEND_STORAGE in
file)
  sudo mkdir -p ${STORAGE_PATH}/${PRODUCT}/data
  echo "
  storage \"file\" {
  path    = \"${STORAGE_PATH}/${PRODUCT}/data/\"
  }
  " >> /tmp/${PRODUCT}.hcl
  ;;

raft)
  sudo mkdir -p ${STORAGE_PATH}/${PRODUCT}/raft
  echo "
  storage \"raft\" {
  path    = \"${STORAGE_PATH}/${PRODUCT}/raft/\"
  node_id = \"${HOST_NAME}\"
  }
  api_addr = \"http://${HOST_IP}:8200\"
  cluster_addr = \"http://${HOST_IP}:8201\"
  " >> /tmp/${PRODUCT}.hcl
  ;;

consul)
  echo "
  storage \"consul\" {
  path    = \"${STORAGE_PATH}/${PRODUCT}/raft/\"
  }
  " >> /tmp/${PRODUCT}.hcl
  ;;

*)
  ;;
esac


# Create product config dir if not exists
if [ -n ${PRODUCT_CONFIG_DIR} ]; then
  sudo mkdir -p $PRODUCT_CONFIG_DIR
fi

# Move product config file to config dir
sudo mv /tmp/${PRODUCT}.hcl ${PRODUCT_CONFIG_DIR}/.

sleep 3
# Print config
echo "... created config dirs and files"
ls -la ${PRODUCT_CONFIG_DIR}
ls -la ${BACKEND_STORAGE}
ls -ls ${STORAGE_PATH}
cat ${PRODUCT_CONFIG_DIR}/${PRODUCT_CONFIG_FILE}

sleep 3
echo "#################################"
echo "## ${PRODUCT} config complete! ##"
echo "#################################"