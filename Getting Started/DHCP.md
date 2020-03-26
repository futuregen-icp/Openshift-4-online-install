# DHCP 설치(옵션)

### DHCP 설치

    yum install dhcp -y

## dhcp configuration

    ## 특정 인터페이스로 DHCP 서버스
    echo "DHCPARGS=ens224" >> /etc/sysconfig/dhcpd
    
    # vi /etc/dhcp/dhcpd.conf
    ddns-update-style interim;
    ignore client-updates;
    authoritative;
    allow booting;
    allow bootp;
    allow unknown-clients;
    
    default-lease-time 600;
    max-lease-time 7200;
    
    subnet 192.168.40.0 netmask 255.255.255.0
    {
        option routers 192.168.40.1;
        option subnet-mask 255.255.255.0;
        option domain-search "ocp4-1.fu.te";
        option domain-name-servers 192.168.40.1;
        option ntp-servers time.bora.net;
        filename "pxelinux.0";
        next-server 192.168.20.30;
        range 192.168.40.10 192.168.40.250;
    
        host ocp43.boot{
        hardware ethernet      00:50:56:89:60:2b;
        fixed-address 192.168.40.10;
        option host-name "bootstrap.ocp4-1.fu.te";
        }
    
       host ocp43.bastion{
        hardware ethernet 00:50:56:89:c1:e1;
        fixed-address 192.168.40.30;
        option host-name "bastion.ocp4-1.fu.te";
        }
    
        host ocp43.master1{
        hardware ethernet 00:50:56:89:de:4f;
        fixed-address 192.168.40.101;
        option host-name "master01.ocp4-1.fu.te";
        }
    
        host ocp43.master2{
        hardware ethernet 00:50:56:89:0c:69;
        fixed-address 192.168.40.102;
        option host-name "master02.ocp4-1.fu.te";
        }
    
        host ocp43.master3{
        hardware ethernet 00:50:56:89:8c:12;
        fixed-address 192.168.40.103;
        option host-name "master03.ocp4-1.fu.te";
        }
    
        host ocp43.node1{
        hardware ethernet 00:50:56:89:75:79;
        fixed-address 192.168.40.201;
        option host-name "worker01.ocp4-1.fu.te";
        }
    
        host ocp43.node2{
        hardware ethernet 00:50:56:89:af:71;
        fixed-address 192.168.40.202;
        option host-name "worker02.ocp4-1.fu.te";
        }
    
        host ocp43.nfs1{
        hardware ethernet 00:50:56:89:85:3c;
        fixed-address 192.168.40.20;
        option host-name "nfs.ocp4.fu.te";
        }
    }

### running

    systemctl start dhcpd
    systemctl enable dhcpd