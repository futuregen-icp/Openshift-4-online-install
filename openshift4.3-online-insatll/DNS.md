# DNS 구성 (옵션-고객 환경에 따라 다름)-(테스트시 필수)

### DNS 설치

    # yum install bind  -y

### DNS configration

    # vi /etc/named.conf <= replace
    options {
            listen-on port 53 { ANY; };     => from localhost to ANY
            listen-on-v6 port 53 { ANY; };  => from :::1 to ANY
            directory       "/var/named";
            dump-file       "/var/named/data/cache_dump.db";
            statistics-file "/var/named/data/named_stats.txt";
            memstatistics-file "/var/named/data/named_mem_stats.txt";
            recursing-file  "/var/named/data/named.recursing";
            secroots-file   "/var/named/data/named.secroots";
            allow-query     { ANY; };       => from localhost to ANY

    #  vi /etc/named.rfc1912.zones  <= append
    zone "ocp4-1.fu.te" IN {
            type master;
            file "ocp4-1.fu.te.zone";
            allow-update { none; };
    };
    
    zone "0.40.168.192.in-addr.arpa" IN {
            type master;
            file "ocp4-1.fu.te.rr";
            allow-update { none; };
    };

    # vi /var/named/ocp4-1.fu.te.zone
    $TTL 60
    @       IN SOA  dns.ocp4-1.fu.te. root.ocp4-1.fu.te. (
                                            1       ; serial
                                            1D      ; refresh
                                            1H      ; retry
                                            1W      ; expire
                                            3H )    ; minimum
                    IN      NS      ns.ocp4-1.fu.te.;
    IN      A       192.168.40.1;
    ns              IN      A       192.168.40.1;
    bastion         IN      A       192.168.40.30
    nfs             IN      A       192.168.40.20;
    registry        IN      A       192.168.40.1;
    ;
    bootstrap       IN      A       192.168.40.10;
    ;
    master01        IN      A       192.168.40.101;
    master02        IN      A       192.168.40.102;
    master03        IN      A       192.168.40.103;
    ;
    worker01        IN      A       192.168.40.201;
    worker02        IN      A       192.168.40.202;
    ;
    api             IN      A       192.168.40.1;
    ;
    api-int         IN      A       192.168.40.1;
    ;
    etcd-0          IN      A       192.168.40.101;
    etcd-1          IN      A       192.168.40.102;
    etcd-2          IN      A       192.168.40.103;
    ;
    *.apps          IN      A       192.168.40.1;
    ;
    _etcd-server-ssl._tcp  86400 IN    SRV 0        10     2380 etcd-0
    _etcd-server-ssl._tcp  86400 IN    SRV 0        10     2380 etcd-1
    _etcd-server-ssl._tcp  86400 IN    SRV 0        10     2380 etcd-2
    ;
    

    # vi /var/named/ocp4-1.fu.te.rr
    $TTL 20
    @       IN      SOA     ns.ocp4-1.fu.te.   root (
                            2019070700      ; serial
                            3H              ; refresh (3 hours)
                            30M             ; retry (30 minutes)
                            2W              ; expiry (2 weeks)
                            1W )            ; minimum (1 week)
            IN      NS      ns.ocp4-1.fu.te.
    ;
    ; syntax is "last octet" and the host must have fqdn with trailing dot
    101      IN      PTR     master01
    102      IN      PTR     master02
    103      IN      PTR     master03
    ;
    10      IN      PTR     bootstrap
    ;
    1      IN      PTR     api.ocp4
    1      IN      PTR     api-int
    ;
    201      IN      PTR     worker01
    202      IN      PTR     worker02

### running

    systemctl start named
    systemctl enable named