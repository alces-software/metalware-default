<% if config.dns_type == 'named' then %>
yum -y install bind bind-utils

cat << EOF > /etc/named.conf
options {
          listen-on port 53 { any; };
          directory       "/var/named";
          dump-file       "/var/named/data/cache_dump.db";
          statistics-file "/var/named/data/named_stats.txt";
          memstatistics-file "/var/named/data/named_mem_stats.txt";
          allow-query     { any; };
          recursion yes;


          dnssec-enable no;
          dnssec-validation no;
          dnssec-lookaside auto;

          forward first;
          forwarders {
              <%= config.externaldns %>;
          };

};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

include "/etc/named/metalware.conf";
EOF

touch /etc/named/metalware.conf

systemctl stop dnsmasq
systemctl disable dnsmasq

systemctl start named
systemctl enable named
<% else %>
systemctl stop named
systemctl disable named

systemctl start dnsmasq
systemctl enable dnsmasq
<% end %>
