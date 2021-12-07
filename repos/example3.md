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

## Planned scenarios
- Remove only 3 infra node as infra3.oss2.fu.igotit.co.kr
- Configure new server for yum repository (!!!! Required big time because download yum file as package file)
- Add 1 node as router1,app1,app2
- Change haproxy from worker1, worker2 to router1
- Delete 2 node as worker1, worker2 
- Add efk node and configure openshift logging feature. 


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

## Definitions
```
- VM Name
  + lab1-repo1
  + lab1-router1
  + lab1-app1
  + lab1-app2
- Hostname | IP
  + repo1.oss2.fu.igotit.co.kr | 192.168.5.151
  + router1.oss2.fu.igotit.co.kr | 192.168.5.141
  + app1.oss2.fu.igotit.co.kr | 192.168.5.131
  + app2.oss2.fu.igotit.co.kr | 192.168.5.132
- DNS record
  + repo1   IN  A 192.168.5.151
  + router1		IN	A	192.168.5.141
  + app1		IN	A	192.168.5.131
  + app2		IN	A	192.168.5.132

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

## Configure repos host server 
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

subscription-manager repos --enable="rhel-7-fast-datapath-rpms" \
  --enable="rhel-7-server-optional-rpms"


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
rhel-7-server-ansible-2.9-rpms \
rhel-7-server-ose-4.6-rpms \
rhel-7-server-fast-datapath-rpms \
rhel-7-server-optional-rpms 
do
  reposync --gpgcheck -lm --repoid=${repo} --download_path=/var/www/html/repos
  createrepo -v /var/www/html/repos/${repo} -o /var/www/html/repos/${repo}
done
---------------

chmod -R +r /var/www/html/repos
restorecon -vR /var/www/html

----------
    --enable="rhel-7-server-rpms" \
    --enable="rhel-7-fast-datapath-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-optional-rpms" \
    --enable="rhel-7-server-ose-4.6-rpms"
-----------

```

## Example planned storage partition for app node
```
/dev/mapper/rootvg-lv_root	5G	/
/dev/mapper/rootvg-lv_usr	10G	/usr
/dev/sda1/  1G /boot
/dev/mapper/rootvg-lv_var	256G	/var
/dev/mapper/rootvg-lv_home	5G	/home
/dev/mapper/rootvg-lv-tmp	5G	/tmp
/dev/mapper/rootvg-lv-log	300G	/log
/dev/mapper/datavg-lv_sw	20G	/sw
```
## Configure ssh key copy for router1,app1,app2 servers
## Configure repo for client server and run yum update for router1, app1, app2
```
cat /etc/yum.repods.d/ocp4-6.repo

[rhel-7-server-rpms]
name=rhel-7-server-rpms
baseurl=http://192.168.5.151/repos/rhel-7-server-rpms
enabled=1
gpgcheck=0
[rhel-7-server-extras-rpms]
name=rhel-7-server-extras-rpms
baseurl=http://192.168.5.151/repos/rhel-7-server-extras-rpms
enabled=1
gpgcheck=0
[rhel-7-server-ansible-2.9-rpms]
name=rhel-7-server-ansible-2.9-rpms
baseurl=http://192.168.5.151/repos/rhel-7-server-ansible-2.9-rpms
enabled=1
gpgcheck=0
[rhel-7-server-ose-4.6-rpms]
name=rhel-7-server-ose-4.6-rpms
baseurl=http://192.168.5.151/repos/rhel-7-server-ose-4.6-rpms
enabled=1
gpgcheck=0
[rhel-7-fast-datapath-rpms]
name=rhel-7-fast-datapath-rpms
baseurl=http://192.168.5.151/repos/rhel-7-fast-datapath-rpms
enabled=1
gpgcheck=0
[rhel-7-server-optional-rpms]
name=rhel-7-server-optional-rpms
baseurl=http://192.168.5.151/repos/rhel-7-server-optional-rpms
enabled=1
gpgcheck=0
```

## Install packages on server as run ansible playbook
```
yum install openshift-ansible openshift-clients jq
```

## Run playboot for scaleup
```
cd /usr/share/ansible/openshift-ansible
ansible-playbook -i /root/hosts playbooks/scaleup.yml
```

## Configure machine config pool for router node
```
[root@l2-10-base1 infra]# vi infra-mcp.yaml 
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfigPool
metadata:
  name: router
spec:
  machineConfigSelector:
    matchExpressions:
    - key: machineconfiguration.openshift.io/role
      operator: In
      values:
      - worker
      - router
  nodeSelector:
    matchLabels:
      node-role.kubernetes.io/router: ""
```

## Ingresscontroller patch for router pods
```
oc patch ingresscontroller default -n openshift-ingress-operator --type=merge --patch='{"spec":{"nodePlacement":{"nodeSelector":{"matchLabels":{"node-role.kubernetes.io/router":""}}}}}'
```


