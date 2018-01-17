#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%= config.jobid %>
#Cluster: <%= config.cluster %>

BMCPASSWORD="<%= config.networks.bmc.bmcpassword %>"
BMCCHANNEL="<%= config.networks.bmc.bmcchannel %>"
BMCUSER="<%= config.networks.bmc.bmcuser %>"
BMCUSERID="<%= config.networks.bmc.bmcuserid %>"
BMCVLAN="<%= config.networks.bmc.bmcvlan %>"

# XXX Is the following still needed now defining IPs in configs?
#No IP has been given, use the hosts file as a lookup table
if [ -z "${IP}" ]; then
  IP="$(getent hosts | grep "$HOSTNAME" | awk ' { print $1 }')"
fi

yum -y install ipmitool

if ! [ -z "$HOSTNAME" ]; then
  if ! [ -z "$IP" ]; then
    echo "Setting up BMC for $HOSTNAME. IP: $IP NETMASK: $NETMASK GATEWAY: $GATEWAY CHANNEL: $BMCCHANNEL USER: $BMCUSER USERID: $BMCUSERID"
    service ipmi start
    sleep 1
    ipmitool lan set "$BMCCHANNEL" ipsrc static
    sleep 2
    ipmitool lan set "$BMCCHANNEL" ipaddr "$IP"
    sleep 2
    ipmitool lan set "$BMCCHANNEL" netmask "$NETMASK"
    sleep 2
    ipmitool lan set "$BMCCHANNEL" defgw ipaddr "$GATEWAY"
    sleep 2
    if ! [ -z "${BMCVLAN}" ] ; then
        ipmitool lan set "$BMCCHANNEL" vlan id "${BMCVLAN}"
        sleep 2
    fi
    ipmitool user set name "$BMCUSERID" "$BMCUSER"
    sleep 2
    ipmitool user set password "$BMCUSERID" "$BMCPASSWORD"
    sleep 2
    ipmitool lan print "$BMCCHANNEL"
    ipmitool user list "$BMCUSERID"
    ipmitool mc reset cold
  fi
fi
