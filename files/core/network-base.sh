#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%=jobid%>
#Cluster: <%=cluster%>

systemctl disable NetworkManager
service NetworkManager stop

echo "HOSTNAME=<%= networks.pri.hostname %>" >> /etc/sysconfig/network
echo "<%= networks.pri.hostname %>" > /etc/hostname

<% if dns_type == 'named' || alces.nodename != 'self'  %>
cat << EOF > /etc/resolv.conf
search <%= search_domains %>
nameserver <%= internaldns %>
EOF
<% else %>
cat << EOF > /etc/resolv.conf
search <%= search_domains %>
nameserver <%= externaldns %>
EOF
<% end %>

<% if firewall.enabled -%>
systemctl enable firewalld
systemctl start firewalld

<%     firewall.each do |zone, info| -%>
<%     next if zone.to_s == 'enabled' -%>
# Create zone
firewall-cmd --info-zone=<%= zone %> >> /dev/null
if [ $? != 0 ] ; then
    firewall-cmd --new-zone <%= zone %> --permanent
fi
# Add services
<%         info.services.split(' ').each do |service| -%>
firewall-cmd --add-service <%= service %> --zone <%= zone %> --permanent
<%         end -%>

<%     end -%>
firewall-cmd --reload

# Add interfaces to zones
<%     networks.each do |network, info| -%>
<%         if info.defined -%>
firewall-cmd --add-interface <%= info.interface %> --zone <%= info.firewallpolicy %> --permanent
<%         end -%>
<%     end -%>

<% else -%>
systemctl disable firewalld
systemctl stop firewalld
<% end -%>
