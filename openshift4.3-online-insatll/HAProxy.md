# HAProxy 설치 (필수)

### HAProxy 설치

    yum install haproxy -y

### selinux config

    setsebool -P haproxy_connect_any 1

### Haproxy config

    ## vi /etc/haproxy/haproxy.cfg
    #---------------------------------------------------------------------
    # Example configuration for a possible web application.  See the
    # full configuration options online.
    #
    #   http://haproxy.1wt.eu/download/1.4/doc/configuration.txt
    #
    #---------------------------------------------------------------------
    
    #---------------------------------------------------------------------
    # Global settings
    #---------------------------------------------------------------------
    global
        log         127.0.0.1 local2
    
        chroot      /var/lib/haproxy
        pidfile     /var/run/haproxy.pid
        maxconn     4000
        user        haproxy
        group       haproxy
        daemon
    
        # turn on stats unix socket
        stats socket /var/lib/haproxy/stats
    
    #---------------------------------------------------------------------
    # common defaults that all the 'listen' and 'backend' sections will
    # use if not designated in their block
    #---------------------------------------------------------------------
    defaults
        option                  dontlognull
        option forwardfor       except 127.0.0.0/8
        timeout connect         10s
        timeout client          1m
        timeout server          1m
        timeout check           10s
        maxconn                 3000
    
    #---------------------------------------------------------------------
    # main frontend which proxys to the backends
    #---------------------------------------------------------------------
    ##
    #  balancing for OCP Kubernetes API Server
    ##
    frontend openshift-api-server
        bind *:6443
        default_backend openshift-api-server
        mode tcp
        option tcplog
    
    backend openshift-api-server
        balance source
        mode tcp
        server bootstrap 192.168.40.10:6443 check
        server master1 192.168.40.101:6443 check
        server master2 192.168.40.102:6443 check
        server master3 192.168.40.103:6443 check
    ##
    # balancing for OCP Machine Config Server
    ##
    frontend machine-config-server
        bind *:22623
        default_backend machine-config-server
        mode tcp
        option tcplog
    
    backend machine-config-server
        balance source
        mode tcp
        server bootstrap 192.168.40.10:22623 check
        server master1 192.168.40.101:22623 check
        server master2 192.168.40.102:22623 check
        server master3 192.168.40.103:22623 check
    
    ##
    # balancing for OCP Ingress Insecure Port & Admin Page
    ##
    frontend ingress-http
        bind *:80
        default_backend ingress-http
        mode tcp
        option tcplog
    
    backend ingress-http
        balance source
        mode tcp
        server worker1 192.168.40.201:80 check
        server worker2 192.168.40.202:80 check
    
    ##
    # balancing for OCP Ingress Secure Port
    ##
    frontend ingress-https
        bind *:443
        default_backend ingress-https
        mode tcp
        option tcplog
    
    backend ingress-https
        balance leastconn
    #    balance source
        mode tcp
        server worker1 192.168.40.201:443 check
        server worker2 192.168.40.202:443 check
    

### running

    systemctl start haproxy
    systemctl enable haproxy