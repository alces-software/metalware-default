#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%=jobid%>
#Cluster: <%=cluster%>

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $BASEDIR/config

systemctl disable NetworkManager
service NetworkManager stop

echo "HOSTNAME=${_ALCES_BASE_HOSTNAME}.prv.${DOMAIN}" >> /etc/sysconfig/network
echo "${_ALCES_BASE_HOSTNAME}.prv.${DOMAIN}" > /etc/hostname

systemctl disable firewalld

if ! [ "$_ALCES_PROFILE" = "MASTER" ]; then
cat << EOF > /etc/resolv.conf
search $_ALCES_SEARCHDOMAINS
nameserver $_ALCES_INTERNALDNS
EOF
else
cat << EOF > /etc/resolv.conf
search $_ALCES_SEARCHDOMAINS
nameserver $_ALCES_EXTERNALDNS
EOF
fi
