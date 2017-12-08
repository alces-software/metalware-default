yum -y install dhcp

cat << EOF > /etc/dhcp/dhcpd.conf
# dhcpd.conf
omapi-port 7911;

default-lease-time 43200;
max-lease-time 86400;
ddns-update-style none;
option domain-name "<%= config.networks.pri.domain %>.<%= config.domain %>";
option domain-name-servers <%= config.networks.pri.ip %>;
option ntp-servers <%= config.networks.pri.ip %>;

allow booting;
allow bootp;

option fqdn.no-client-update    on;  # set the "O" and "S" flag bits
option fqdn.rcode2            255;
option pxegrub code 150 = text ;

option space PXE;
option PXE.mtftp-ip    code 1 = ip-address;
option PXE.mtftp-cport code 2 = unsigned integer 16;
option PXE.mtftp-sport code 3 = unsigned integer 16;
option PXE.mtftp-tmout code 4 = unsigned integer 8;
option PXE.mtftp-delay code 5 = unsigned integer 8;
option arch code 93 = unsigned integer 16; # RFC4578

# PXE Handoff.
next-server <%= config.networks.pri.ip %>;
filename "pxelinux.0";

log-facility local7;
group {
  include "/etc/dhcp/dhcpd.hosts";
}
#################################
# private network
#################################
subnet <%= config.networks.pri.network %> netmask <%= config.networks.pri.netmask %> {
#  pool
#  {
#    range 10.10.200.100 10.10.200.200;
#  }

  option subnet-mask <%= config.networks.pri.netmask %>;
  option routers <%= config.networks.pri.ip %>;
  class "pxeclients" {
          match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
          if option arch = 00:07 {
                          filename "efi/grubx64.efi";
                  } else {
                          filename "pxelinux.0";
                  }
        }

}
EOF

touch /etc/dhcp/dhcpd.hosts

systemctl enable dhcpd
systemctl restart dhcpd
