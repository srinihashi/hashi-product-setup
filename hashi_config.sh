#!/bin/bash

# Display --help [Command options]
if [ $1 = "--help" ]; then
     echo "USAGE: #hashi-config.sh <product[vault | consul | nomad]> <config_dir> <log_dir> backend_storage [file | raft | consul] <storage_path>"
     exit
fi

# Set input arguments
PRODUCT=$1
PRODUCT_CONFIG_DIR=$2
LOG_DIR=$3
BACKEND_STORAGE=$4
STORAGE_PATH=$5

OS=`uname -a | awk '{print tolower ($1)}'`

CONFIG_DIR_SCRIPT_URL=https://raw.githubusercontent.com/srinihashi/hashi-product-setup/master/${OS,,}_${PRODUCT}_config.sh
echo ${CONFIG_DIR_SCRIPT_URL}
TMP_CONFIG_FILE=/tmp/${PRODUCT}-config.sh

URL=${CONFIG_DIR_SCRIPT_URL}
TMP_FILE=${TMP_CONFIG_FILE}
curl -k ${URL} -o ${TMP_FILE}
sudo chmod a+x ${TMP_FILE}
${TMP_FILE} ${PRODUCT} ${BACKEND_STORAGE} ${STORAGE_PATH} ${PRODUCT_CONFIG_DIR} ${LOG_DIR}

SYSTEMD_SCRIPT_URL=https://raw.githubusercontent.com/srinihashi/hashi-product-setup/master/${OS}_${PRODUCT}_systemd.sh
TMP_SYSTEMD_FILE=/tmp/${PRODUCT}-systemd.sh

URL=${SYSTEMD_SCRIPT_URL}
TMP_FILE=${TMP_SYSTEMD_FILE}
curl -k ${URL} -o ${TMP_FILE}
sudo chmod a+x ${TMP_FILE}
${TMP_FILE} ${PRODUCT} ${PRODUCT_CONFIG_DIR} ${LOG_DIR}
