#!/bin/bash

# Display --help [Command options]
if [ $1 = "--help" ]; then
     echo "USAGE: #hashi-systemd-setup.sh <product[vault | consul | nomad]> <backend_storage [consul | raft]"
     exit
fi

# Set input arguments
PRODUCT=vault
PRODUCT_PROJECT=""
PRODUCT_CONFIG_PATH=/etc/${PRODUCT}.d
PRODUCT_CONFIG_FILE=${PRODUCT_CONFIG_PATH}/${PRODUCT}.hcl
TMP_FILE=/tmp/${PRODUCT}.service
SERVICE_FILE=/etc/systemd/system/${PRODUCT}.service

if [ "${PRODUCT,,}" = "vault" ]; then
  PRODUCT_PROJECT=project
fi

#Print
echo Service to setup: ${PRODUCT^}

# Create systemd service file
echo "[Unit]
Description="HashiCorp ${PRODUCT^} - A tool for managing secrets"
Documentation=https://www.${PRODUCT}${PRODUCT_PROJECT}.io/docs/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=${PRODUCT_CONFIG_FILE}
StartLimitIntervalSec=60
StartLimitBurst=3

[Service]
User=${PRODUCT}
Group=${PRODUCT}
ProtectSystem=full
ProtectHome=read-only
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/local/bin/${PRODUCT} server -config=${PRODUCT_CONFIG_PATH}
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

if [ -n $SERVICE_FILE ]; then
  sudo mv $TMP_FILE $SERVICE_FILE
  ls -l $SERVICE_FILE
fi
