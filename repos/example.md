## AS-IS
```
[root@lab1-bastion playbooks]# oc get nodes
NAME                           STATUS   ROLES          AGE    VERSION
infra1.oss2.fu.igotit.co.kr    Ready    infra,worker   263d   v1.19.0+2f3101c
infra2.oss2.fu.igotit.co.kr    Ready    infra,worker   263d   v1.19.0+2f3101c
infra3.oss2.fu.igotit.co.kr    Ready    infra,worker   263d   v1.19.0+2f3101c
master1.oss2.fu.igotit.co.kr   Ready    master         280d   v1.19.0+1833054
master2.oss2.fu.igotit.co.kr   Ready    master         280d   v1.19.0+1833054
master3.oss2.fu.igotit.co.kr   Ready    master         280d   v1.19.0+1833054
worker1.oss2.fu.igotit.co.kr   Ready    worker         279d   v1.19.0+1833054
worker2.oss2.fu.igotit.co.kr   Ready    worker         279d   v1.19.0+1833054
```

## Planed
- Remove only 3 infra node.
- add 2 node as router1, router2
- change haproxy from worker1, worker2 to router1, router2
- delete 2 node as worker1, worker2 


## remove worker node 
```
$ oc adm cordon <node_name>
$ oc adm drain <node_name> --force --delete-local-data --ignore-daemonsets
$ oc delete node <node_name>
```

## DNS Record
```
master1		IN	A	192.168.5.101
master2		IN	A	192.168.5.102
master3		IN	A	192.168.5.103
worker1		IN	A	192.168.5.111
worker2		IN	A	192.168.5.112
infra1		IN	A	192.168.5.121
infra2		IN	A	192.168.5.122
infra3		IN	A	192.168.5.123

#planed
router1	IN	A	192.168.5.121
repository	IN	A	192.168.5.200
```
## Remove infra3 node
```
$ oc adm cordon infra3.oss2.fu.igotit.co.kr
$ oc adm drain infra3.oss2.fu.igotit.co.kr --force --delete-local-data --ignore-daemonsets
$ oc delete node infra3.oss2.fu.igotit.co.kr
```
## Delete DNS record
## Delete infra3 node vm
## Create lab1-router1 vm

## Create repository
```
# Definitions
- VM Name: lab1-repo1
- Hostname: repo1.oss2.fu.igotit.co.kr
- IP: 192.168.5.151
```
## Add dns record
## Create VM and OS installations
## Configure IP, Hostname


## Checking yum list for add node
```
+ Yum repolist
rhel-7-server-ansible-2.9-rpms                  
rhel-7-server-extras-rpms                                 
rhel-7-server-ose-4.6-rpms                                       
rhel-7-server-rpms
```

## Configure Repos Server 
```
# Configure subscribe
subsciprtion-manager register
subscription-manager refresh
subscription-manager list --available --matches '*Openshift*' #8a85f99672f210990172f306b0ca6a2c
subscription-manager attach --pool=
subscription-manager repos --list
subscription-manager repos --disable="*"
subscription-manager repos     --enable="rhel-7-server-rpms"     \
                               --enable="rhel-7-server-extras-rpms"     \
                               --enable="rhel-7-server-ose-4.6-rpms"     \
                               --enable="rhel-7-server-ansible-2.9-rpms"

# Install packages
sudo yum -y install yum-utils createrepo docker git vsftpd

# Update yum package
yum update

# Reboot

# Syn Repo

# apache install
yum -y install httpd 
systemctl enalbe httpd
systemctl start httpd
iptables -I INPUT -m state --state NEW -p tcp -m tcp --dport 80 -j ACCEPT;
iptables-save > /etc/sysconfig/iptables;
firewall-cmd --permanent --add-service=http;
firewall-cmd --reload;
#/

mkdir -p /var/www/html/repos
nohup ./repos.sh & (session close 시)
--------------
#!/bin/sh
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

for repo in \
rhel-7-server-rpms \
rhel-7-server-extras-rpms \
rhel-7-server-ansible-2.6-rpms \
rhel-7-server-ose-4.6-rpms
do
  reposync --gpgcheck -lm --repoid=${repo} --download_path=/var/www/html/repos
  createrepo -v /var/www/html/repos/${repo} -o /var/www/html/repos/${repo}
done
---------------

chmod -R +r /var/www/html/repos
restorecon -vR /var/www/html


```
