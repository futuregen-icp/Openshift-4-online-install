# haproxy  

## Overview

### haproxy의 기능 

```
TCP proxy

HTTP rerverse-proxy 

SSL terminator / initiator / offloade :  클라이언트에서 오가는 연결, 서버로 가는 연결, SNI 등 관련 설정 

HTTP normalizer :  HTTP 트래픽만 처리하도록 설정하는 경우 적용 가능 ,

HTTP fixing tool 

Content-based switch

Server load balancer : TCP, HTTP 연결에 대한 부하분산 

Traffic regulator : 다양한 지점에 대한 트래픽 비율 조절 

protection against DDoS and service abuse

observation point for network troubleshooting

HTTP compression offloader  

caching proxy : RAM cashing

FastCGI gateway 
```



### hapoxy 에서 사용할 수 없는 기능

```
기본 proxy  기능 
a data scrubber : 데이터 수정 불가 
웹서버 기능
패킷 베이스 로드밸런스  (DSR, UDP 등의 로드벌런스)
```



## ACL 기반의  분기 및 로드벨런스 구성 

아래의 예시 처럼 ACL 기반으로   frontend와 backend의 연결을 지정

 



## 설치 방법 

### CentOS, RHEL

	yum install -y haproxy

## 운영 방식

	systemctl enable haproxy 
	
	systemctl start haproxy
	systemctl stop haproxy   


### 설정 예제 

	파일 명 : 	/etc/haproxy/haprsoxy.cfg


설정 내용 

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
	    log         127.0.0.1 local2        info
	
	    chroot      /var/lib/haproxy
	    pidfile     /var/run/haproxy.pid
	    maxconn     4000
	    user        haproxy
	    group       haproxy
	    daemon
	
	    # turn on stats unix socket
	    stats socket /var/lib/haproxy/stats


	defaults
	    mode                    http
	    log                     global
	    option                  httplog
	    option                  dontlognull
	    option http-server-close
	    option forwardfor       except 127.0.0.0/8
	    option                  redispatch
	    retries                 3
	    timeout http-request    10s
	    timeout queue           1m
	    timeout connect         10s
	    timeout client          1m
	    timeout server          1m
	    timeout http-keep-alive 10s
	    timeout check           10s
	    maxconn                 3000


​	
	frontend openshift-api-server
	    bind *:8443
	    default_backend openshift-api-server
	    mode tcp
	    option tcplog
	
	backend openshift-api-server
	    balance source
	    mode tcp
	    server master01 192.168.2.11:8443 check
	    server master02 192.168.2.12:8443 check
	    server master03 192.168.2.13:8443 check
	
	frontend openshift4-api-server
	    bind *:6443
		default_backend openshift4-api-server
	    mode tcp
	    option tcplog
	
	backend openshift4-api-server
	    balance source
	    mode tcp
	    server bootstrap 192.168.3.10:6443 check
	    server master1 192.168.3.11:6443 check
	    server master2 192.168.3.12:6443 check
	    server master3 192.168.3.13:6443 check
	
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
	    server bootstrap 192.168.3.10:22623 check
	    server master1 192.168.3.11:22623 check
	    server master2 192.168.3.12:22623 check
	    server master3 192.168.3.13:22623 check
	
	##
	# balancing for OCP Ingress Insecure Port & Admin Page
	##
	frontend ingress-http
	    bind *:80
	    #acl ocp2-http hdr(host) -m reg -i ^[^\.]+\.apps\.ocp2\.fu\.igotit\.co\.kr$
	    #acl ocp3-http hdr(host) -m reg -i ^[^\.]+\.apps\.ocp3\.fu\.igotit\.co\.kr$
	    acl ocp2-http hdr_end(host) -i apps.ocp2.fu.igotit.co.kr
	    acl ocp3-http hdr_end(host) -i apps.ocp3.fu.igotit.co.kr
	    use_backend ocp2-http if ocp2-http
	    use_backend ocp3-http if ocp3-http
	    default_backend ingress-http
	    #mode tcp
	    #option tcplog
	
	backend ocp2-http
	    balance source
	    #mode tcp
	    #option tcplog
	    server infra01 192.168.2.21:80 check
	    server infra02 192.168.2.22:80 check
	
	backend ocp3-http
	    balance source
	    #mode tcp
	    #option tcplog
	    server worker1 192.168.3.21:80 check
	    server worker2 192.168.3.22:80 check
	    server worker3 192.168.3.23:80 check
	
	backend ingress-http
	    balance source
	    #mode tcp
	    #option tcplog
	    server infra01 192.168.2.21:80 check
	    server infra02 192.168.2.22:80 check


​	
	##
	# balancing for OCP Ingress Secure Port
	##
	frontend ingress-https
	    bind *:443
	    tcp-request inspect-delay 5s
	    tcp-request content accept if { req_ssl_hello_type 1 }
	    #acl ocp2-https hdr(host) -m reg -i ^[^\.]+\.apps\.ocp2\.fu\.igotit\.co\.kr$
	    #acl ocp3-https hdr(host) -m reg -i ^[^\.]+\.apps\.ocp3\.fu\.igotit\.co\.kr$
	    acl ocp2-https req_ssl_sni -m end -i apps.ocp2.fu.igotit.co.kr
	    acl ocp3-https req_ssl_sni -m end -i apps.ocp3.fu.igotit.co.kr
	    use_backend ocp2-https if ocp2-https
	    use_backend ocp3-https if ocp3-https
	    default_backend ingress-https
	    mode tcp
	    option tcplog
	
	backend ocp2-https
	    balance leastconn
	    # balance source
	    mode tcp
	    option tcplog
	    server infra01 192.168.2.21:443 check
	    server infra02 192.168.2.22:443 check


​	
	backend ocp3-https
	    balance leastconn
	    # balance source
	    mode tcp
	    option tcplog
	    server worker1 192.168.3.21:443 check
	    server worker2 192.168.3.22:443 check
	    server worker3 192.168.3.23:443 check
	
	backend ingress-https
	    balance source
	    mode tcp
	    option tcplog
	    server infra01 192.168.2.21:443 check
	    server infra02 192.168.2.22:443 check
