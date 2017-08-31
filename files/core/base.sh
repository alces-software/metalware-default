#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%=jobid%>
#Cluster: <%=cluster%>

curl "<%= alces.hosts_url %>" > /etc/hosts

yum -y install git vim emacs xauth xhost xdpyinfo xterm xclock tigervnc-server ntpdate wget vconfig bridge-utils patch tcl-devel gettext

mkdir -m 0700 /root/.ssh
install_file authorized_keys /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> /root/.ssh/config

yum -y install net-tools bind-utils ipmitool

yum -y update

#Branch for profile
if [ "<%= profile %>" == 'INFRA' ]; then
  yum -y install device-mapper-multipath sg3_utils
  yum -y groupinstall "Gnome Desktop"
  mpathconf
  mpathconf --enable
else
  echo "Unrecognised profile"
fi

# NTP/Chrony
yum -y install chrony
<% if ntp.is_server -%>
cat << EOF > /etc/chrony.conf
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 2.centos.pool.ntp.org iburst
server 3.centos.pool.ntp.org iburst

stratumweight 0

driftfile /var/lib/chrony/drift

rtcsync

makestep 10 3

bindcmdaddress 127.0.0.1
bindcmdaddress ::1

keyfile /etc/chrony.keys

commandkey 1

generatecommandkey

noclientlog

logchange 0.5

logdir /var/log/chrony

allow <%= networks.pri.network %>/<% require 'ipaddr'; puts IPAddr.new(networks.pri.netmask).to_i.to_s(2).count('1') %>
EOF
<% else -%>
cat << EOF > /etc/chrony.conf
tinker panic 0

restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 127.0.0.1
restrict -6 ::1

server <%= ntp.server %> iburst
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 2.centos.pool.ntp.org iburst

driftfile /var/lib/ntp/drift
EOF
<% end -%>
systemctl start chronyd
systemctl enable chronyd
