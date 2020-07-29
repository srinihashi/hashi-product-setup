#!/bin/bash

# Display --help [Command options]
if [ $1 = "--help" ]; then
     echo "USAGE: #linux_vault_config_dir.sh <product[vault | consul | nomad]> <backend_storage [file | raft | consul] <storage_path> <config_dir> <log_dir>"
     exit
fi

# Set input arguments
PRODUCT=$1
if [ "${PRODUCT,,}" = "vault" ];
then
  PRODUCT_PROJECT=project
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

# Create Product config file
echo "
disable_mlock = true
ui = true
log_level = \"Debug\"
" > /tmp/${PRODUCT}.hcl

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
  }
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

echo "
listener \"tcp\" {
 address     = \"127.0.0.1:8200\"
 tls_disable = 1
 telemetry {
    unauthenticated_metrics_access = true
  }
}
" >> /tmp/${PRODUCT}.hcl

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
echo "## ${PRODUCT} config dir complete! ##"
echo "#################################"
