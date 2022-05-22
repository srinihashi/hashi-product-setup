#!/bin/bash

# Display --help [Command options] Test
if [ $1 = "--help" ]; then
     echo "USAGE: #hashi-install.sh <pkg [oss | ent | ent.hsm]> <product[vault | consul | nomad]> <version> <backend_storage [consul | raft]"
     exit
fi

# Set input arguments
PKG=+$1
PRODUCT=${2,,}
PRODUCT_VERSION=$3
BACKEND_STORAGE=${4,,}

# Set variables
VAULT_LATEST=1.4.3
CONSUL_LATEST=1.8.0
PRODUCT_BASE_URL=https://releases.hashicorp.com
OS=`uname -a | awk '{print tolower ($1)}'`

#Check Architecture
ARCH=`uname -a | awk '{print tolower ($14)}'`
case $ARCH in
x86_64)
  ARCH=386
  ;;

aarch64)
  ARCH=arm64
  ;;
  
*)
  echo "Architecture: UNKNOWN"
  ;;
esac

#Print
echo Proudct Type: ${PKG^}
echo Product to install: ${PRODUCT^}
echo Version to install: ${PRODUCT_VERSION^}
echo Backend Storage to use: ${BACKEND_STORAGE^}
echo Operating System: ${OS^}

# Product specific variables
if [ "$PKG" = "+oss" ]; then
  PKG=""
fi
PRODUCT_URL=$PRODUCT_BASE_URL/${PRODUCT}/${PRODUCT_VERSION}${PKG}/${PRODUCT}_${PRODUCT_VERSION}${PKG}_${OS}_${ARCH}.zip
echo Product URL: $PRODUCT_URL


# Install unzip
if [ "$OS" = "linux" ]; then
  echo "Installing unzip package..."
  # If RHEL
  if [[ `cat /proc/version` == *"Red Hat"* ]];
  then
    sudo dnf -y install unzip
  fi

  # If Ubuntu
  if [[ `cat /proc/version` == *"Ubuntu"* ]];
  then
    sudo apt-get install -y unzip
  fi
  
  # If SUSE
  if [[ `cat /proc/version` == *"SUSE"* ]];
  then
    sudo zypper install unzip
  fi
fi

if [ "$OS" = "darwin" ]; then
  echo "Installing unzip package..."
  sudo brew -y install unzip
fi

# Download Hashi Product
curl $PRODUCT_URL > /tmp/${PRODUCT}.zip

# Unzip Vault binaries
sudo unzip -o /tmp/${PRODUCT}.zip -d /usr/local/bin/.

if [[ "${PRODUCT}" = "vault" && "${BACKEND_STORAGE}" = "consul" ]]; then
  #Download Consul
  PRODUCT=$BACKEND_STORAGE
  # NEED TO ENHANCE
  PRODUCT_VERSION=$CONSUL_LATEST
  PRODUCT_URL=$PRODUCT_BASE_URL/${BACKEND_STORAGE}/${PRODUCT_VERSION}${PKG}/${BACKEND_STORAGE}_${PRODUCT_VERSION}${PKG}_${OS}_${ARCH}.zip
  echo Product URL: $PRODUCT_URL

  # Download Consul
  curl $PRODUCT_URL > /tmp/${BACKEND_STORAGE}.zip

  # Unzip Consul binaries
  sudo unzip -o /tmp/${BACKEND_STORAGE}.zip -d /usr/local/bin/.
fi

# Print installed versions
$PRODUCT --version

if [ "${BACKEND_STORAGE}" = "consul" ]; then
  $BACKEND_STORAGE --version
fi
