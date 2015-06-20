#!/bin/sh
WEBHOME='/var/www/html/pan/status'
PAN_STATUS_HOME='/root/bin/pan_status/'
PAN_IB_HOME='/root/bin/pan_ib_topology/'

#IPV4
${PAN_STATUS_HOME}/bin/parse_fping.rb ${PAN_STATUS_HOME}/conf/hosts_management_net ${WEBHOME}/rack_management_state.json
${PAN_STATUS_HOME}/bin/parse_fping.rb ${PAN_STATUS_HOME}/conf/hosts_provisioning_net ${WEBHOME}/rack_provisioning_state.json
${PAN_STATUS_HOME}/bin/parse_fping.rb ${PAN_STATUS_HOME}/conf/hosts_ib_net ${WEBHOME}/rack_ipoib_state.json

#IB
${PAN_IB_HOME}/bin/gen_json_status.rb
