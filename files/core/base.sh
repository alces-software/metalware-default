#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%=jobid%>
#Cluster: <%=cluster%>

<% if alces.nodename != 'self' -%>
curl "<%= alces.hosts_url %>" > /etc/hosts
<% else -%>
echo "<%= networks.pri.ip %> <%= networks.pri.hostname %>" >> /etc/hosts
<% end -%>

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

allow <%= networks.pri.network %>/<% require 'ipaddr'; netmask=IPAddr.new(networks.pri.netmask).to_i.to_s(2).count('1') %><%= netmask %>
EOF
<% else -%>
cat << EOF > /etc/chrony.conf
server <%= ntp.server %> iburst
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 2.centos.pool.ntp.org iburst

driftfile /var/lib/ntp/drift
EOF
<% end -%>
systemctl start chronyd
systemctl enable chronyd

# Syslog
yum -y install rsyslog
<% if rsyslog.is_server -%>
cat << EOF > /etc/rsyslog.d/metalware.conf
\$template remoteMessage, "/var/log/slave/%FROMHOST%/messages.log"
:fromhost-ip, !isequal, "127.0.0.1" ?remoteMessage
& ~
EOF

sed -i -e "s/^#\$ModLoad imudp.*$/\$ModLoad imudp/g" /etc/rsyslog.conf
sed -i -e "s/^#\$UDPServerRun 514.*$/\$UDPServerRun 514/g" /etc/rsyslog.conf
sed -i -e "s/^#\$ModLoad imtcp.*$/\$ModLoad imtcp/g" /etc/rsyslog.conf
sed -i -e "s/^#\$InputTCPServerRun 514.*$/\$InputTCPServerRun 514/g" /etc/rsyslog.conf

cat << EOF > /etc/logrotate.d/rsyslog-remote
/var/log/slave/*/*.log {
    sharedscripts
    compress
    rotate 2
    postrotate
        /bin/kill -HUP \`cat /var/run/syslogd.pid 2> /dev/null\` 2> /dev/null || true
        /bin/kill -HUP \`cat /var/run/rsyslogd.pid 2> /dev/null\` 2> /dev/null || true
    endscript
}
EOF
firewall-cmd --add-port 514/udp --zone internal --permanent
firewall-cmd --add-port 514/tcp --zone internal --permanent
fiewall-cmd --reload
<% else -%>
echo '*.* @<%= rsyslog.server %>:514' >> /etc/rsyslog.conf
<% end -%>

systemctl enable rsyslog
systemctl restart rsyslog
