#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%=jobid%>
#Cluster: <%=cluster%>

# NET="BMC" # XXX Need to make this configurable?
NETDOMAIN="<%= bmcdomain %>" # XXX Unused - needed?
NETMASK="<%= bmcnetmask %>"
NETWORK="<%=bmcnetwork %>" # XXX Unused - needed?
GATEWAY="<%= bmcgateway %>"

#Force an IP, rather than attempt a lookup
IP="<%= bmcip %>"

HOST="<%= alces.nodename %>.<%= bmcdomain %>"

#No IP has been given, use the hosts file as a lookup table
if [ -z "${IP}" ]; then
  echo "Guessing IP using: $HOST"
  IP=`getent hosts | grep $HOST | awk ' { print $1 }'`
fi

BMCPASSWORD="<%= bmcpassword %>"
BMCCHANNEL="<%= bmcchannel %>"
BMCUSER="<%= bmcuser %>"

yum -y install ipmitool

if ! [ -z "$HOST" ]; then
  if ! [ -z "$IP" ]; then
    echo "Setting up BMC for $HOST. IP: $IP NETMASK: $NETMASK GATEWAY: $GATEWAY CHANNEL: $BMCCHANNEL USER: $BMCUSER"
    service ipmi start
    sleep 1
    ipmitool lan set $BMCCHANNEL ipsrc static
    sleep 2
    ipmitool lan set $BMCCHANNEL ipaddr $IP
    sleep 2
    ipmitool lan set $BMCCHANNEL netmask $NETMASK
    sleep 2
    ipmitool lan set $BMCCHANNEL defgw ipaddr $GATEWAY
    sleep 2
    ipmitool user set name $BMCUSER admin
    sleep 2
    ipmitool user set password $BMCUSER $BMCPASSWORD
    sleep 2
    ipmitool lan print $BMCCHANNEL
    ipmitool user list $BMCUSER
    ipmitool mc reset cold
  fi
fi
