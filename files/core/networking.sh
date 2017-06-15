#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%=jobid%>
#Cluster: <%=cluster%>

run_script network-base
run_script network-ipmi

<% networks.each do |name, network| %>

export NET="<%= name %>"
export INTERFACE="<%= network.interface %>"
export HOSTNAME="<%= network.hostname %>"
export IP="<%= network.ip %>"
export NETMASK="<%= network.netmask %>"
export NETWORK="<%= network.network %>"
export GATEWAY="<%= network.gateway %>"
#If TYPE is 'Bond' or 'Bridge', we'll also need these set to setup the slaves
export SLAVEINTERFACES="<%= slave_interfaces %>"
#This is literally translated to the TYPE in redhat-sysconfig-network
export TYPE="<%= network.type %>"

run_script network-join

<% end %>
