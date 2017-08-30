yum -y install dhcp

cat << EOF > /etc/dhcp/dhcpd.conf
# dhcpd.conf
omapi-port 7911;

default-lease-time 43200;
max-lease-time 86400;
ddns-update-style none;
option domain-name "<%= networks.pri.domain %>.<%= domain %>";
option domain-name-servers <%= networks.pri.ip %>;
option ntp-servers <%= networks.pri.ip %>;

allow booting;
allow bootp;

option fqdn.no-client-update    on;  # set the "O" and "S" flag bits
option fqdn.rcode2            255;
option pxegrub code 150 = text ;



# PXE Handoff.
next-server <%= networks.pri.ip %>;
filename "pxelinux.0";

log-facility local7;
group {
  include "/etc/dhcp/dhcpd.hosts";
}
#################################
# private network
#################################
subnet <%= networks.pri.network %> netmask <%= networks.pri.netmask %> {
#  pool
#  {
#    range 10.10.200.100 10.10.200.200;
#  }

  option subnet-mask <%= networks.pri.netmask %>;
  option routers <%= networks.pri.ip %>;
}
EOF

systemctl enable dhcpd
systemctl restart dhcpd