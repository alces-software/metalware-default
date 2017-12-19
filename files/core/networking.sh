#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%= config.jobid %>
#Cluster: <%= config.cluster %>

run_script network-base

<% config.networks.each do |name, network| %>
<% if network.defined %>
export NET="<%= network.domain %>"
export INTERFACE="<%= network.interface %>"
export HOSTNAME="<%= network.hostname %>"
export IP="<%= network.ip %>"
export NETMASK="<%= network.netmask %>"
export NETWORK="<%= network.network %>"
export GATEWAY="<%= network.gateway %>"
#If TYPE is 'Bond' or 'Bridge', we'll also need these set to setup the slaves
export SLAVEINTERFACES="<%= network.slave_interfaces %>"
#Bond options
export BONDOPTIONS="<%= network.bond_options %>"
#This is literally translated to the TYPE in redhat-sysconfig-network
export TYPE="<%= network.type %>"
export ZONE="<%= network.firewallpolicy %>"

if [ "${INTERFACE}" == 'bmc' ]
then
  run_script network-ipmi
else
  run_script network-join
fi
<% end %>
<% end %>
