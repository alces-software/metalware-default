yum -y install tftp xinetd tftp-server syslinux syslinux-tftpboot

mkdir -p <%= build.pxeboot_path %>
curl http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/images/pxeboot/initrd.img > "<%= build.pxeboot_path %>/centos7-initrd.img"
curl http://mirror.ox.ac.uk/sites/mirror.centos.org/7/os/x86_64/images/pxeboot/vmlinuz > "<%= build.pxeboot_path %>/centos7-kernel"
mkdir -p /var/lib/tftpboot/pxelinux.cfg/
cat << EOF > /var/lib/tftpboot/pxelinux.cfg/default
DEFAULT menu
PROMPT 0
MENU TITLE PXE Menu
TIMEOUT 100
TOTALTIMEOUT 1000
ONTIMEOUT local

LABEL local
     MENU LABEL (local)
     MENU DEFAULT
     LOCALBOOT 0
EOF


sed -ie "s/^.*disable.*$/\    disable = no/g" /etc/xinetd.d/tftp

systemctl enable xinetd 
systemctl restart xinetd
