# Openshift 4.6 online install guide 

  ## Environments
- Bastion : Rhel 8

## Definitions
- Domain name : dslee.lab
- Servers
  - l2-10-base1    |    192.168.1.58, 172.10.20.10    | DNS, Masquerade, http, haproxy , registry | rhel 8
  - l2-11-nfs1 | 172.10.20.11 | nfs | rhel 7
  - l2-30-bootstrap | 172.10.20.30 | bootstrap 
  - l2-31-master1 | 172.10.20.31 | master 1 
  - l2-32-master2 | 172.10.20.32 | master 2 
  - l2-33-master3 | 172.10.20.33 | master 3 
  - l2-41-infra1 | 172.10.20.41 | infra 1 
  - l2-42-infra2 | 172.10.20.42 | infra 2
  - l2-51-ad1 | 172.10.20.51 | Active Directory

## Install Packages on bastion server.
``` 
yum install -y vim jq httpd-tools podman skopeo
```

## Configure DNS Server
```
yum -y install bind bind-utils
```

## Configure Masquerade
```
firewall-cmd --permanent --direct --passthrough ipv4 -t nat -I POSTROUTING -o eth0 -j MASQUERADE -s 172.10.20.0/24
firewall-cmd --zone=internal --add-masquerade --permanent
firewall-cmd --zone=public --add-masquerade --permanent

```

## /etc/named.conf

```
// 
// named.conf 
// 
// Provided by Red Hat bind package to configure the ISC BIND named(8) DNS 
// server as a caching only nameserver (as a localhost DNS resolver only). 
// 
// See /usr/share/doc/bind*/sample/ for example named configuration files. 
// 
options { 
        listen-on port 53 { any; }; 
        listen-on-v6 port 53 { any; }; 
        directory       "/var/named"; 
        dump-file       "/var/named/data/cache_dump.db"; 
        statistics-file "/var/named/data/named_stats.txt"; 
        memstatistics-file "/var/named/data/named_mem_stats.txt"; 
        secroots-file   "/var/named/data/named.secroots"; 
        recursing-file  "/var/named/data/named.recursing"; 
        allow-query     { any; }; 
        /*  
         - If you are building an AUTHORITATIVE DNS server, do NOT enable recursion. 
         - If you are building a RECURSIVE (caching) DNS server, you need to enable  
           recursion.  
         - If your recursive DNS server has a public IP address, you MUST enable access  
           control to limit queries to your legitimate users. Failing to do so will 
           cause your server to become part of large scale DNS amplification  
           attacks. Implementing BCP38 within your network would greatly 
           reduce such attack surface  
        */ 
        forward first; 
        forwarders{ 
        168.126.63.1; 
            8.8.8.8; 
        };
        recursion yes; 
        dnssec-enable yes; 
        dnssec-validation yes; 
        managed-keys-directory "/var/named/dynamic"; 
        pid-file "/run/named/named.pid"; 
        session-keyfile "/run/named/session.key"; 
        /* https://fedoraproject.org/wiki/Changes/CryptoPolicy */ 
        /* include "/etc/crypto-policies/back-ends/bind.config"; */
}; 
logging { 
        channel default_debug { 
                file "data/named.run"; 
                severity dynamic; 
        }; 
}; 
include "/etc/named.rfc1912.zones"; 
include "/etc/named.root.key";
```

## /etc/named.rfc1912.zones
```
// named.rfc1912.zones: 
// 
// Provided by Red Hat caching-nameserver package 
// 
// ISC BIND named zone configuration for zones recommended by 
// RFC 1912 section 4.1 : localhost TLDs and address zones 
// and https://tools.ietf.org/html/rfc6303 
// (c)2007 R W Franks 
// 
// See /usr/share/doc/bind*/sample/ for example named configuration files. 
// 
// Note: empty-zones-enable yes; option is default. 
// If private ranges should be forwarded, add 
// disable-empty-zone "."; into options 
// 
zone "localhost.localdomain" IN { 
        type master; 
        file "named.localhost"; 
        allow-update { none; }; 
}; 
zone "localhost" IN { 
        type master; 
        file "named.localhost"; 
        allow-update { none; }; 
}; 
zone "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa" IN { 
        type master; 
        file "named.loopback"; 
        allow-update { none; }; 
}; 
zone "1.0.0.127.in-addr.arpa" IN { 
        type master; 
        file "named.loopback"; 
        allow-update { none; }; 
}; 
zone "0.in-addr.arpa" IN { 
        type master; 
        file "named.empty"; 
        allow-update { none; }; 
}; 

zone "lab2.dslee.lab" IN {
        type master;
        file "lab2/lab2.dslee.lab";
        allow-update { none; };
};
```

## /var/named/lab2/lab2.dslee.lab
```
$TTL 300       ; 1 hour 
@             IN SOA  ns.lab2.dslee.lab. dns.lab2.dslee.lab. ( 
                                  2007040461 ; serial 
                                  7200       ; refresh (2 hours) 
                                  3600       ; retry (1 hour) 
                                  604800     ; expire (1 week) 
                                  3600       ; minimum (1 hour) 
                                 ) 
		NS      ns.lab2.dslee.lab. 
		NS      ns1.lab2.dslee.lab. 
		NS      ns2.lab2.dslee.lab. 
                IN	A	172.10.20.10

ns	IN	A	172.10.20.10
ns1	IN	A	172.10.20.10
ns2	IN	A	172.10.20.10
; 
; ocp4 start 
; 
l2-10-base1	IN	A	172.10.20.10
l2-11-nfs1	IN	A	172.10.20.11
l2-30-bootstrap	IN	A	172.10.20.30
l2-31-master1	IN	A	172.10.20.31
l2-32-master2	IN	A	172.10.20.32
l2-33-master3	IN	A	172.10.20.33
l2-41-infra1	IN	A	172.10.20.41
l2-42-infra2	IN	A	172.10.20.42
etcd-0	IN	A	172.10.20.31
etcd-1	IN	A	172.10.20.32
etcd-2	IN	A	172.10.20.33
l2-registrymirror	IN	A	172.10.20.11
api	IN	A	172.10.20.10
api-int	IN	A	172.10.20.10
*.apps		IN	A	192.168.5.10

_etcd-server-ssl._tcp   IN SRV 0 10 2380 etcd-0 
_etcd-server-ssl._tcp   IN SRV 0 10 2380 etcd-1 
_etcd-server-ssl._tcp   IN SRV 0 10 2380 etcd-2
```

## Configure HTTPD

- change port 8080

## HAPROXY

```
#--------------------------------------------------------------------- 
# common defaults that all the 'listen' and 'backend' sections will 
# use if not designated in their block 
#--------------------------------------------------------------------- 
defaults 
    timeout connect         5s 
    timeout client          30s 
    timeout server          30s 
    log                     global 
    option                  dontlognull 
frontend kubernetes_api 
    bind 0.0.0.0:6443 
    default_backend kubernetes_api 
    mode tcp 
    option tcplog 
backend kubernetes_api 
    balance source 
    mode tcp 
    server bootstrap l2-30-bootstrap.lab2.dslee.lab:6443 check 
    server master1 l2-31-master1.lab2.dslee.lab:6443 check 
    server master2 l2-32-master2.lab2.dslee.lab:6443 check 
    server master3 l2-33-master3.lab2.dslee.lab:6443 check 
frontend machine_config 
    bind 0.0.0.0:22623 
    default_backend machine_config 
    mode tcp 
    option tcplog 
backend machine_config 
    balance source 
    option tcplog 
    mode tcp 
    server bootstrap l2-30-bootstrap.lab2.dslee.lab:22623 check 
    server master1 l2-31-master1.lab2.dslee.lab:22623 check 
    server master2 l2-32-master2.lab2.dslee.lab:22623 check 
    server master3 l2-33-master3.lab2.dslee.lab:22623 check 
frontend router_https 
    bind *:443 
    default_backend router_https 
    mode tcp 
    hash-type consistent 
    option tcplog 
backend router_https 
    balance source 
    mode tcp 
    hash-type consistent 
    server infra1 l2-41-infra1.lab2.dslee.lab:443 check 
    server infra2 l2-42-infra2.lab2.dslee.lab:443 check 
frontend router_http 
    bind 0.0.0.0:80 
    default_backend router_http 
    mode tcp 
    option tcplog 
backend router_http 
    mode http 
    balance source 
    mode tcp 
    server infra1 l2-41-infra1.lab2.dslee.lab:80 check 
    server infra2 l2-42-infra2.lab2.dslee.lab:80 check

## remark
setsebool -P haproxy_connect_any=1
firewall-cmd --permanent --add-port=8080/tcp --add-port=80/tcp --add-port=22623/tcp --add-port=6443/tcp --add-port=443/tcp  --zone=internal
firewall-cmd --reload
```

## Configuring NFS server

```
+ Install Packages
rpm -qa | grep nfs-utils
yum install nfs-utils rpcbind

+ Enable the services at boot time:
systemctl enable nfs-server
systemctl enable rpcbind
systemctl enable nfs-lock
/*
In RHEL7.1 (nfs-utils-1.3.0-8.el7) enabling nfs-lock does not work (No such file or directory). it does not need to be enabled since rpc-statd.service is static. 
*/
systemctl enable nfs-idmap
/*
In RHEL7.1 (nfs-utils-1.3.0-8.el7) this does not work (No such file or directory). it does not need to be enabled since nfs-idmapd.service is static.
*/

+ Start the NFS services:
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap

+ Check the status of NFS service:
systemctl status nfs

+ Create a shared directory:
mkdir /nfs1

+ Edit /etc/exports 
/nfs1 *(rw)

+ apply
exportfs -r

+ show mount
showmount -e

+ firewall
firewall-cmd --add-service=nfs --zone=public --permanent 
firewall-cmd --add-service=mountd --zone=public --permanent 
firewall-cmd --add-service=rpc-bind --zone=public --permanent
firewall-cmd --reload

### Configuring NFS client
+ Install packages
rpm -qa | grep nfs-utils
yum install nfs-utils

+ Mount
mount -t nfs l2-11-nfs1.lab2.dslee.lab:/nfs1 /mnt
mount -t nfs -o sync l2-11-nfs1.lab2.dslee.lab:/nfs1 /mnt

+ Check 
df -h | grep nfs

+ Unmount
umount /mnt

+ apply for boot time as fstab as /etc/fstab
l2-11-nfs1.lab2.dslee.lab:/nfs1	/mnt		nfs	sync		0 0

+ Refferrence 
https://www.thegeekdiary.com/centos-rhel-7-configuring-an-nfs-server-and-nfs-client/
```

## Mirror registry (Option)

```
+ Definitions
  - name : mirrorregistry.lab2.dslee.lab
+ Install packages 
yum install -y vim jq httpd-tools podman skokepo


+ Create certifacates 
mkdir -p /opt/registry/data 
mkdir -p /opt/registry/auth 
mkdir -p /opt/registry/certs
cd /opt/registry/certs 
openssl req -newkey rsa:4096 -nodes -sha256 -keyout mirrorregistry.lab2.dslee.lab.key -x509 -days 3650 -out mirrorregistry.lab2.dslee.lab.crt 
cp /opt/registry/certs/registry.oss2.fu.igotit.co.kr.crt /etc/pki/ca-trust/source/anchors/ 
update-ca-trust

htpasswd -bBc /opt/registry/auth/htpasswd admin admin 
vi /etc/containers/registries.conf 
[registries.search] 
registries = [‘bastion.d3c.ebaykorea.com:5000', ‘registry.redhat.io']
```

## Download Install tools

```
+ Download file 
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.6.15/openshift-install-linux.tar.gz 
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.6.15/openshift-client-linux.tar.gz 
wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.6/4.6.1/rhcos-installer.x86_64.iso 

  - move /usr/bin

```
## Install-config.yaml

```
apiVersion: v1 
baseDomain: example.com  
compute: 
- hyperthreading: Enabled    
  name: worker 
  replicas: 0  
controlPlane: 
  hyperthreading: Enabled    
  name: master  
  replicas: 3  
metadata: 
  name: test  
networking: 
  clusterNetwork: 
  - cidr: 10.128.0.0/14  
    hostPrefix: 23  
  networkType: OpenShiftSDN 
  serviceNetwork:  
  - 172.30.0.0/16 
platform: 
  none: {}  
fips: false  
pullSecret: ''  
sshKey: 'ssh-ed25519 AAAA...'
```

## Install Command

```
manifest dir define : /opt/ocp4/install-20210305 
openshift-install create manifests --dir=/opt/ocp4/install-20210305 
openshift-install create ignition-configs --dir=/opt/ocp4/install-20210305

manifest dir define : /opt/ocp4/install-20210309
openshift-install create manifests --dir=/opt/ocp4/install-20210309 
sudo nmcli con up   "Wired Connection"  
sudo nmcli general hostname l2-30-bootstrap.lab2.dslee.lab  
sudo coreos-installer install /dev/sda \
  --ignition-url=http://172.10.20.10:8080/bootstrap.ign \
  --insecure-ignition \
  --append-karg "ip=172.10.20.30::172.10.20.10:255.255.255.0:l2-30-bootstrap.lab2.dslee.lab:eth0:none nameserver=172.20.30.10"
```

## Verifiy check

```
openshift-install --dir=/opt/ocp4/install-20210309 wait-for bootstrap-complete --log-level=info 
export KUBECONFIG=<installation_directory>/auth/kubeconfig
```


## Add rhel node plan

```
## Required
- rhel 7.9
- memory 8G above


## Definitions  for add role
- Domain name : dslee.lab 
- Servers 
  - l2-10-base1    |    192.168.1.58, 172.10.20.10 | rhel 8   | DNS, Masquerade, http, haproxy , registry | rhel 8 
  - l2-11-nfs1 | 172.10.20.11 | nfs | rhel 7  | bastion for add node 
  - l2-30-bootstrap | 172.10.20.30 | bootstrap  
  - l2-31-master1 | 172.10.20.31 | master 1  
  - l2-32-master2 | 172.10.20.32 | master 2  
  - l2-33-master3 | 172.10.20.33 | master 3  
  - l2-41-infra1 | 172.10.20.41 | infra 1  
  - l2-42-infra2 | 172.10.20.42 | infra 2 
  - l2-51-router1 | 172.10.20.51 | router 1 | d
  - l2-52-router2 | 172.10.20.52 | router 2 | e
  - l2-61-log1 | 172.10.20.61 | logging | d

+ Yum repolist
rhel-7-server-ansible-2.9-rpms                  
rhel-7-server-extras-rpms                                 
rhel-7-server-ose-4.6-rpms                                       
rhel-7-server-rpms

+ router firewall
firewall-cmd --permanent --add-port=9000-9999/tcp --add-port=10250-10259/tcp --add-port=10256/tcp --add-port=4789/udp --add-port=6081/udp --add-port=9000-9999/udp --add-port=30000-32767/tcp --add-port=30000-32767/udp  
firewall-cmd --permanent --add-port=80/tcp --add-port=443/tcp 
firewall-cmd --reload


+ ssh-key copy for the all add node
+ setting hostname for the all add node
+ install yum package on bastion
yum install openshift-ansible openshift-clients jq
+ setting subscription for the all add node
subscription-manager repos --disable="*"
subscription-manager repos \ 
    --enable="rhel-7-server-rpms" \ 
    --enable="rhel-7-fast-datapath-rpms" \ 
    --enable="rhel-7-server-extras-rpms" \ 
    --enable="rhel-7-server-optional-rpms" \ 
    --enable="rhel-7-server-ose-4.6-rpms"

+ vi /etc/ansible/hosts
[all:vars] 
ansible_user=root 
#ansible_become=True 
openshift_kubeconfig_path="/root/.kube/kubeconfig"

[new_workers] 
l2-51-router1.lab2.dslee.lab
l2-52-router2.lab2.dslee.lab
l2-61-log1.lab2.dslee.lab

+ action the add node
ansible-playbook -i /etc/ansible/hosts /usr/share/ansible/openshift-ansible/playbooks/scaleup.yml -k -K
```

## Configure node roles (ing)
```
- infra 설정 
  + vi infra-mcp.yaml 
apiVersion: machineconfiguration.openshift.io/v1 
kind: MachineConfigPool 
metadata: 
  name: infra 
spec: 
  machineConfigSelector: 
    matchExpressions: 
    - {key: machineconfiguration.openshift.io/role, operator: In, values: [worker,infra]} 
  nodeSelector: 
    matchLabels: 
      node-role.kubernetes.io/infra: ""
  + oc apply -f -

- routerint 설정 
  + vi router-int-mcp.yaml 
apiVersion: machineconfiguration.openshift.io/v1 
kind: MachineConfigPool 
metadata: 
  name: routerint 
spec: 
  machineConfigSelector: 
    matchExpressions: 
    - {key: machineconfiguration.openshift.io/role, operator: In, values: [worker,routerint]} 
  nodeSelector: 
    matchLabels: 
      node-role.kubernetes.io/routerint: ""

- routerpub 설정 
  + vi router-pub-mcp.yaml 
apiVersion: machineconfiguration.openshift.io/v1 
kind: MachineConfigPool 
metadata: 
  name: routerpub 
spec: 
  machineConfigSelector: 
    matchExpressions: 
    - {key: machineconfiguration.openshift.io/role, operator: In, values: [worker,routerpub]} 
  nodeSelector: 
    matchLabels: 
      node-role.kubernetes.io/routerpub: ""
```
