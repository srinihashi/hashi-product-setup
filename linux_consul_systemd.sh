#!/bin/bash

# Display --help [Command options]
if [ $1 = "--help" ]; then
     echo "USAGE: #hashi-systemd-setup.sh <product[vault | consul | nomad]> <config_dir> <log_dir>"
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

PRODUCT_CONFIG_DIR=$2/${PRODUCT}.d
PRODUCT_CONFIG_FILE=${PRODUCT}.hcl
TMP_FILE=/tmp/${PRODUCT}.service
SERVICE_FILE=/etc/systemd/system/${PRODUCT}.service

# Set dir for product logs
LOG_PATH=$3/${PRODUCT}.log
sudo touch ${LOG_PATH}

#Print
echo Service to setup: ${PRODUCT^}

# Create systemd service file
echo "[Unit]
Description="HashiCorp ${PRODUCT^} - A tool for managing secrets"
Documentation=https://www.${PRODUCT}${PRODUCT_PROJECT}.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=${PRODUCT_CONFIG_DIR}/${PRODUCT_CONFIG_FILE}
StartLimitIntervalSec=60
StartLimitBurst=3
[Service]
User=root
Group=root
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/${PRODUCT} server -config=${PRODUCT_CONFIG_DIR} > ${LOG_PATH}
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGINT
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitInterval=60
StartLimitIntervalSec=60
StartLimitBurst=3
LimitNOFILE=65536
LimitMEMLOCK=infinity
[Install]
WantedBy=multi-user.target" > $TMP_FILE

sudo mv $TMP_FILE $SERVICE_FILE

sleep 3
# Enable Hashi Product  service and start it
sudo systemctl enable ${PRODUCT}.service
sudo systemctl start ${PRODUCT}.service

sleep 2
# Set env variables
case $PRODUCT in
vault)
  export VAULT_ADDR="http://127.0.0.1:8200"
  ;;

*)
  echo "Nothing to set"
  ;;
esac

#Check Hashi Product status
${PRODUCT} status
