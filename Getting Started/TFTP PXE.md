# TFTP 구성 (옵션)-(PXE 부팅 사용시)

### package install

    yum -y install syslinux tftp-server
    yum -y install xinetd

### coreos 설치 boot 파일

    cd /var/lib/tftpboot/
    mkdir ocp4.3
    cd ocp4.3
    wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.3/latest/rhcos-4.3.0-x86_64-installer-kernel
    wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.3/latest/rhcos-4.3.0-x86_64-installer-initramfs.img

### pxe 부팅 파일 복사

    cp -Rp /usr/share/syslinux/chain.c32 /var/lib/tftpboot/
    cp -Rp /usr/share/syslinux/mboot.c32 /var/lib/tftpboot/
    cp -Rp /usr/share/syslinux/memdisk /var/lib/tftpboot/
    cp -Rp /usr/share/syslinux/menu.c32 /var/lib/tftpboot/
    cp -Rp /usr/share/syslinux/pxelinux.0 /var/lib/tftpboot/

### pxe 부팅 설정 파일 생성

    mkdir /var/lib/tftpboot/pxelinux.cfg
    vi /var/lib/tftpboot/pxelinux.cfg/default
    DEFAULT menu.c32
    TIMEOUT 30
    PROMPT 30
    menu title ### OS Installer Boot Menu ###
    LABEL label Bootstrap Node
    KERNEL ocp4.3/rhcos-4.3.0-x86_64-installer-kernel
    APPEND ip=dhcp rd.neednet=1 initrd=ocp4.3/rhcos-4.3.0-x86_64-installer-initramfs.img console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.install_dev=sda coreos.inst.image_url=ftp://192.168.40.30/pub/rhcos-4.3.0-x86_64-metal.raw.gz coreos.inst.ignition_url=ftp://192.168.40.30/pub/bootstrap.ign
    LABEL label controlplane Node
    KERNEL ocp4.3/rhcos-4.3.0-x86_64-installer-kernel
    APPEND ip=dhcp rd.neednet=1 initrd=ocp4.3/rhcos-4.3.0-x86_64-installer-initramfs.img console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.install_dev=sda coreos.inst.image_url=ftp://192.168.40.30/pub/rhcos-4.3.0-x86_64-metal.raw.gz coreos.inst.ignition_url=ftp://192.168.40.30/pub/bootstrap.ign
    LABEL label worker Node
    KERNEL ocp4.3/rhcos-4.3.0-x86_64-installer-kernel
    APPEND ip=dhcp rd.neednet=1 initrd=ocp4.3/rhcos-4.3.0-x86_64-installer-initramfs.img console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.install_dev=sda coreos.inst.image_url=ftp://192.168.40.30/pub/rhcos-4.3.0-x86_64-metal.raw.gz coreos.inst.ignition_url=ftp://192.168.40.30/pub/worker.ign

### xinet.d 설정

    vi  /etc/xinetd.d/tftp
    ...
    disable                 = no
    ...

### running

    systemctl start tftp.socket
    systemctl restart xinetd.service
    systemctl enable tftp.socket
    systemctl enable xinetd.service