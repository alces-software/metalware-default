#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%= config.jobid %>
#Cluster: <%= config.cluster %>

run_script network-base

<% config.networks.each do |name, network| %>
<% if network.defined %>
#Base Network Configuration
export NET="<%= network.domain %>"
export INTERFACE="<%= network.interface %>"
export HOSTNAME="<%= network.hostname %>"
export IP="<%= network.ip %>"
export NETMASK="<%= network.netmask %>"
export NETWORK="<%= network.network %>"
export GATEWAY="<%= network.gateway %>"

#Bridge Configuration
export BRIDGE="<%= if (network.bridge rescue false) then 'Bridge' end %>"
export BRIDGEINTERFACE="<%= if (network.bridge rescue false) then network.bridge.interface end %>"
export BRIDGESLAVEINTERFACES="<%= if (network.bridge rescue false) then network.bridge.slave_interfaces end %>"

#Bond Configuration
export BOND="<%= if (network.bond rescue false) then 'Bond' end %>"
export BONDINTERFACE="<%= if (network.bond rescue false) then network.bond.interface end %>"
export BONDSLAVEINTERFACES="<%= if (network.bond rescue false) then network.bond.slave_interfaces end %>"
export BONDOPTIONS="<%= if (network.bond rescue false) then network.bond.options end %>"

export ZONE="<%= network.firewallpolicy %>"

if [ "${INTERFACE}" == 'bmc' ]
then
  run_script network-ipmi
else
  run_script network-join
fi
<% end %>
<% end %>
