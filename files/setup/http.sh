yum -y install httpd

cat << EOF > /etc/httpd/conf.d/deployment.conf
<Directory /var/lib/metalware/rendered/>
    Options Indexes MultiViews FollowSymlinks
    AllowOverride None
    Require all granted
    Order Allow,Deny
    Allow from <%= networks.pri.network %>/<%= networks.pri.netmask %>
    Allow from 127.0.0.1/8
</Directory>
Alias /metalware /var/lib/metalware/rendered/
EOF

cat << EOF > /etc/httpd/conf.d/installer.conf
<Directory /opt/alces/installers/>
    Options Indexes MultiViews FollowSymlinks
    AllowOverride None
    Require all granted
    Order Allow,Deny
    Allow from <%= networks.pri.network %>/<%= networks.pri.netmask %>
</Directory>
Alias /installers /opt/alces/installers
EOF

mkdir -p /opt/alces/installers

mkdir -p /var/lib/metalware/rendered/exec/
cat << 'EOF' > /var/lib/metalware/rendered/exec/kscomplete.php
<?php
$cmd="touch /var/lib/metalware/cache/built-nodes/metalwarebooter." . $_GET['name'];
exec($cmd);
?>
EOF

systemctl enable httpd
systemctl restart httpd
