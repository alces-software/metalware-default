#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%=jobid%>
#Cluster: <%=cluster%>

systemctl disable NetworkManager
service NetworkManager stop

echo "HOSTNAME=<%= alces.nodename %>.prv.<%= domain %>" >> /etc/sysconfig/network
echo "<%= alces.nodename %>.prv.<%= domain %>" > /etc/hostname

systemctl disable firewalld

if ! [ "<%= profile %>" = "MASTER" ]; then
cat << EOF > /etc/resolv.conf
search <%= search_domains %>
nameserver <%= internaldns %>
EOF
else
cat << EOF > /etc/resolv.conf
search <%= search_domains %>
nameserver <%= externaldns %>
EOF
fi
