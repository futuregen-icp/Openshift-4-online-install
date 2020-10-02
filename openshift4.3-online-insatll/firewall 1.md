# firewall 설정(필수)

    firewall-cmd --permanent --zone=public --add-service=ftp
    firewall-cmd --permanent --zone=public --add-service=dns
    firewall-cmd --permanent --zone=public --add-service=tftp
    firewall-cmd --permanent --zone=public --add-service=ssh
    firewall-cmd --permanent --zone=public --add-service=dhcp
    firewall-cmd --permanent --zone=public --add-service=proxy-dhcp
    
    firewall-cmd --permanent --zone=public  --add-port=53/tcp
    firewall-cmd --permanent --zone=public --add-port=80/tcp
    firewall-cmd --permanent --zone=public --add-port=443/tcp
    firewall-cmd --permanent --zone=public --add-port=6443/tcp
    firewall-cmd --permanent --zone=public --add-port=8443/tcp
    firewall-cmd --permanent --zone=public --add-port=10256/tcp
    firewall-cmd --permanent --zone=public --add-port=2379-2380/tcp
    firewall-cmd --permanent --zone=public --add-port=9000-9999/tcp
    firewall-cmd --permanent --zone=public --add-port=10249-10259/tcp
    firewall-cmd --permanent --zone=public --add-port=22623/tcp
    firewall-cmd --permanent --zone=public --add-port=5000/tcp
    
    firewall-cmd --permanent --zone=public --add-port=53/udp
    firewall-cmd --permanent --zone=public --add-port=4789/udp
    firewall-cmd --permanent --zone=public --add-port=6081/udp
    firewall-cmd --permanent --zone=public --add-port=9000-9999/udp
    firewall-cmd --permanent --zone=public --add-port=30000-32767/udp
    
    firewall-cmd --reload
