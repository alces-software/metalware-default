yum -y install tftp xinetd tftp-server syslinux syslinux-tftpboot php

mkdir -p <%= config.build.pxeboot_path %>
curl <%= config.yumrepo.build_url %>/images/pxeboot/initrd.img > "<%= config.build.pxeboot_path %>/centos7-initrd.img"
curl <%= config.yumrepo.build_url %>/images/pxeboot/vmlinuz > "<%= config.build.pxeboot_path %>/centos7-kernel"
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
