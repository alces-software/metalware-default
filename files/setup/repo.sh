yum -y install createrepo httpd yum-plugin-priorities yum-utils

cat << EOF > /etc/httpd/conf.d/installer.conf
<Directory /opt/alces/repo/>
    Options Indexes MultiViews FollowSymlinks
    AllowOverride None
    Require all granted
    Order Allow,Deny
    Allow from <%= networks.pri.ip %>/255.255.0.0
</Directory>
Alias /repo /opt/alces/repo

<Directory /opt/alces/installers/>
    Options Indexes MultiViews FollowSymlinks
    AllowOverride None
    Require all granted
    Order Allow,Deny
    Allow from <%= networks.pri.ip %>/255.255.0.0
</Directory>
Alias /installers /opt/alces/installers
EOF

mkdir -p /opt/alces/{repo/custom,installers}
cd /opt/alces/repo
createrepo custom

systemctl enable httpd
systemctl restart httpd
