#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%=jobid%>
#Cluster: <%=cluster%>

systemctl disable NetworkManager
service NetworkManager stop

echo "HOSTNAME=<%= networks.pri.hostname %>" >> /etc/sysconfig/network
echo "<%= networks.pri.hostname %>" > /etc/hostname

systemctl disable firewalld

#if ! [ "<%= profile %>" = "MASTER" ]; then
cat << EOF > /etc/resolv.conf
search <%= search_domains %>
nameserver <%= internaldns %>
EOF
#else
#cat << EOF > /etc/resolv.conf
#search <%= search_domains %>
#nameserver <%= externaldns %>
#EOF
#fi
