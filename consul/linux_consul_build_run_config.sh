#!/bin/bash
#
# Display --help [Command options]
if [ $1 = "--help" ]; then
     echo "USAGE: #linux_consul_systemd.sh <product[vault | consul | nomad]> <os [linux | darwin]>"
     exit
fi

PRODUCT=$1
OS=$2
SCRIPT="${OS}_${PRODUCT}_config.sh"
SCRIPT_SNIPPET=https://raw.githubusercontent.com/srinihashi/hashi-product-setup/master/${PRODUCT}/${OS}_${PRODUCT}_config_script_snippet
VARS=https://raw.githubusercontent.com/srinihashi/hashi-product-setup/master/${PRODUCT}/${OS}_${PRODUCT}_config_vars.vars
echo "#!/bin/bash
" > ./${SCRIPT}

`curl -H 'Cache-Control: no-cache' ${VARS}?$(date +%s) >> ./${SCRIPT}`
sleep 3
`curl -H 'Cache-Control: no-cache' ${SCRIPT_SNIPPET}?$(date +%s) >> ./${SCRIPT}`
sleep 3
sudo chmod a+x ./${SCRIPT}
echo "Running final consul config script...."
sleep 3
./${SCRIPT}
