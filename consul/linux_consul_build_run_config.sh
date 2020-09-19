#!/bin/bash
SCRIPT="linux_consul_config.sh"
SCRIPT_SNIPPET=https://raw.githubusercontent.com/srinihashi/hashi-product-setup/master/linux_consul_config_script_snippet
VARS=https://raw.githubusercontent.com/srinihashi/hashi-product-setup/master/linux_consul_config_vars.vars
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
