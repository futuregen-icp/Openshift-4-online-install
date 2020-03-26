# IP Masquerade 설정(옵션)-(restricted natework 필수)

## IP Masquerade

### ip forword를 위한 kernel 설정

    sysctl -w net.ipv4.ip_forward=1
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/ip_forward.conf

### 인터페이스 설정

    firewall-cmd --set-default-zone=external
    firewall-cmd --permanent --zone=internal --add-interface=ens224

### ip Masquerade 설정

    firewall-cmd --permanent --direct --passthrough ipv4 -t nat -I POSTROUTING -o ens192 -j MASQUERADE -s 192.168.40.0/24
    firewall-cmd --reload