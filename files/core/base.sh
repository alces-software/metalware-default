#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%= domain.config.jobid %>
#Cluster: <%= domain.config.cluster %>

<% unless node.name == 'local' -%>
curl "<%= domain.hosts_url %>" > /etc/hosts
<% else -%>
echo "<%= config.networks.pri.ip %> <%= config.networks.pri.hostname %>" >> /etc/hosts
<% end -%>

yum -y install git vim emacs xauth xhost xdpyinfo xterm xclock tigervnc-server ntpdate wget vconfig bridge-utils patch tcl-devel gettext

mkdir -m 0700 /root/.ssh
install_file authorized_keys /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
echo "StrictHostKeyChecking no" >> /root/.ssh/config

yum -y install net-tools bind-utils ipmitool

yum -y update

#Branch for profile
if [ "<%= config.profile %>" == 'INFRA' ]; then
  yum -y install device-mapper-multipath sg3_utils
  yum -y groupinstall "Gnome Desktop"
  mpathconf
  mpathconf --enable
else
  echo "Unrecognised profile"
fi

# NTP/Chrony
yum -y install chrony
<% if config.ntp.is_server -%>
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

allow <%= config.networks.pri.network %>/<% require 'ipaddr'; netmask=IPAddr.new(config.networks.pri.netmask.to_s).to_i.to_s(2).count('1') %><%= netmask %>
EOF
<% else -%>
cat << EOF > /etc/chrony.conf
server <%= config.ntp.server %> iburst

makestep 360 10

driftfile /var/lib/ntp/drift
EOF
<% end -%>
systemctl start chronyd
systemctl enable chronyd

# First boot
mkdir -p /var/lib/firstrun/{bin,scripts}
mkdir -p /var/log/firstrun/

cat << EOF > /var/lib/firstrun/bin/firstrun
#!/bin/bash
function fr {
  echo "-------------------------------------------------------------------------------"
  echo "Symphony deployment Suite - Copyright (c) 2008-2017 Alces Software Ltd"
  echo "-------------------------------------------------------------------------------"
  echo "Running Firstrun scripts.."
  if [ -f /var/lib/firstrun/RUN ]; then
    for script in \`find /var/lib/firstrun/scripts -type f -iname *.bash\`; do
      echo "Running \$script.." >> /root/firstrun.log 2>&1
      /bin/bash \$script >> /root/firstrun.log 2>&1
    done
    rm -f /var/lib/firstrun/RUN
  fi
  echo "Done!"
  echo "-------------------------------------------------------------------------------"
}
trap fr EXIT
EOF

cat << EOF > /var/lib/firstrun/bin/firstrun-stop
#!/bin/bash
/bin/systemctl disable firstrun.service
if [ -f /firstrun.reboot ]; then
  echo -n "Reboot flag set.. Rebooting.."
  rm -f /firstrun.rebooot
  shutdown -r now
fi
EOF

cat << EOF >> /etc/systemd/system/firstrun.service
[Unit]
Description=FirstRun service
After=network-online.target remote-fs.target
Before=display-manager.service getty@tty1.service
[Service]
ExecStart=/bin/bash /var/lib/firstrun/bin/firstrun
Type=oneshot
ExecStartPost=/bin/bash /var/lib/firstrun/bin/firstrun-stop
SysVStartPriority=99
TimeoutSec=0
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target
EOF

chmod 664 /etc/systemd/system/firstrun.service
systemctl daemon-reload
systemctl enable firstrun.service
touch /var/lib/firstrun/RUN

# Syslog
yum -y install rsyslog
<% if config.rsyslog.is_server -%>
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
cat << EOF > /var/lib/firstrun/scripts/firewall_rsyslog.bash
firewall-cmd --add-port 514/udp --zone internal --permanent
firewall-cmd --add-port 514/tcp --zone internal --permanent
firewall-cmd --reload
EOF
<% else -%>
echo '*.* @<%= config.rsyslog.server %>:514' >> /etc/rsyslog.conf
<% end -%>

systemctl enable rsyslog
systemctl restart rsyslog

# Postfix setup
yum -y install postfix
<% unless node.name == 'local' -%>
sed -n -e '/^relayhost\s*=/!p' -e '$arelayhost=[<%=config.postfix.relayhost%>]' /etc/postfix/main.cf -i
<% end -%>
systemctl enable postfix
systemctl restart postfix


