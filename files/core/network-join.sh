#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%= config.jobid %>
#Cluster: <%= config.cluster %>

echo "Running network configuration for NET:$NET HOSTNAME:$HOSTNAME INTERFACE:$INTERFACE NETMASK:$NETMASK NETWORK:$NETWORK GATEWAY:$GATEWAY IP:$IP"

# Base Vars
FILENAME="${CONFIGDIR}ifcfg-${INTERFACE}"

# Identify Type (Bridge takes priority over Bond, Bond over Eth/IB)
if ! [ -z "${BRIDGE}" ] ; then
  TYPE="Bridge"
elif ! [ -z "${BOND}" ] ; then
  TYPE="Bond"
elif ( `echo "${INTERFACE}" | grep -q "^ib.*$"` ) ; then
  TYPE="Infiniband"
else
  TYPE="Ethernet"
fi

########
# MAIN #
########

# Base
echo "Writing: $FILENAME"
cat << EOF > $FILENAME
TYPE=$TYPE
BOOTPROTO=none
DEFROUTE=yes
PEERDNS=no
PEERROUTES=no
IPV4_FAILURE_FATAL=no
IPV6INIT=no
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
IPV6_FAILURE_FATAL=no
NAME=$INTERFACE
DEVICE=$INTERFACE
ONBOOT=yes
IPADDR=$IP
NETMASK=$NETMASK
ZONE=$ZONE
EOF

# Add Gateway
if ! [ -z "$GATEWAY" ]; then
  echo "GATEWAY=\"${GATEWAY}\"" >> "$FILENAME"
fi

# BRIDGE - Main
if [[ $INTERFACE == $BRIDGEINTERFACE ]] ; then
  echo "STP=no" >> "$FILENAME"
fi

# BOND - Main
if [[ $INTERFACE == $BONDINTERFACE ]] ; then
  echo "BONDING_OPTS=\"${BONDOPTIONS}\"" >> "$FILENAME"
fi

##########
# SLAVES #
##########

SLAVEBASE="BOOTPROTO=none
DEFROUTE=no
PEERDNS=no
PEERROUTES=no
IPV4_FAILURE_FATAL=no
IPV6INIT=no
IPV6_AUTOCONF=no
IPV6_DEFROUTE=no
IPV6_PEERDNS=no
IPV6_PEERROUTES=no
IPV6_FAILURE_FATAL=no
ONBOOT=yes"

slave_interface() {
  iface=$1
  slavefile="${CONFIGDIR}ifcfg-$iface"
  echo "Writing: $slavefile"

  # Configure bond (if slave is a bond)
  if [[ $iface == $BONDINTERFACE ]] ; then
    echo "TYPE=Bond" >> $slavefile
    echo "BONDING_OPTS=\"${BONDOPTIONS}\"" >> $slavefile
  fi

  # Base slave config to file
  echo "$SLAVEBASE" >> $slavefile
  echo "NAME=$iface
DEVICE=$iface" >> $slavefile

  # Add bridge slave config
  if [[ $BRIDGESLAVEINTERFACES == *"$iface"* ]] ; then
    echo "BRIDGE=$BRIDGEINTERFACE" >> $slavefile
  fi

  # Add bond slave config
  if [[ $BONDSLAVEINTERFACES == *"$iface"* ]] ; then
    echo "MASTER=$BONDINTERFACE
SLAVE=yes" >> $slavefile
  fi
}


# Setup Bridge Slaves
if ! [ -z "${BRIDGE}" ] ; then
  for i in $BRIDGESLAVEINTERFACES ; do
    slave_interface $i
  done
fi

# Setup Bond Slaves
if ! [ -z "${BOND}" ] ; then
  for i in $BONDSLAVEINTERFACES ; do
    slave_interface $i
  done
fi
