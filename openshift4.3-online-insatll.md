# openshift4.3-online-insatll

This wiki is built in Notion. Here are all the tips you need to contribute.

# openshift4.3-online-install

## 필수 사항 구성

  [장비 구성 최소 사양  및 필수 구성 요소(클릭)](openshift4.3-online-insatll/Untitled.csv)

  **서브 스크립션 등록** 
  subscription-manager register --username=locli5427 --password=Hellena1^^
  subscription-manager refresh
  subscription-manager list --available --matches '*OpenShift*'
  subscription-manager attach --pool=8a85f99c707807c801709f913ded7153
  yum install openshift-ansible openshift-clients jq
  subscription-manager repos     \
      --enable="rhel-7-server-rpms"      \
      --enable="rhel-7-server-extras-rpms"      \
      --enable="rhel-7-server-ansible-2.8-rpms"      \
      --enable="rhel-7-server-ose-4.3-rpms"
  yum install openshift-ansible openshift-clients jq
  subscription-manager list
  subscription-manager status

### 사전 확인 사항

clusterName : ocp4-1 , baseDoamain : fu.te

### 사전 필수 명령어 설치

    yum install procps psmisc net-tools iptraf podman -y

# 설치 절차

## pre install

- **gateway  설치**

    [ firewall 설정(필수)](openshift4.3-online-insatll/firewall.md)

    [IP Masquerade 설정(옵션)-(restricted natework 필수)](openshift4.3-online-insatll/IP%20Masquerade%20restricted%20natework.md)

    [DHCP 설치(옵션)](openshift4.3-online-insatll/DHCP.md)

    [HAProxy 설치 (필수)](openshift4.3-online-insatll/HAProxy.md)

    [DNS 구성 (옵션-고객 환경에 따라 다름)-(테스트시 필수)](openshift4.3-online-insatll/DNS.md)

- **bootstrap 설치**

    [mirror registry 구성 (옵션)-(restricted natework 필수)](openshift4.3-online-insatll/mirror%20registry%20restricted%20natework.md)

    [TFTP 구성 (옵션)-(PXE 부팅 사용시)]openshift4.3-online-insatll/TFTP%20PXE.md)

    [ftp 설치 (필수)](openshift4.3-online-insatll/ftp.md)

    [firewall 설정(필수)](openshift4.3-online-insatll/firewall%201.md)

    [ssh 인증키 생성 ](openshift4.3-online-insatll/ssh.md)

- **nfs 설치**

    [NFS - server 구성](openshift4.3-online-insatll/NFS%20server.md)

- **준비 사항**

    [Pullsecerts](openshift4.3-online-insatll/Pullsecerts.md)

    [install 파일 구성](openshift4.3-online-insatll/install.md)

## Install

### online - install - bastion

    **# 생성한 인스톨 파일 복사**
    su - core
    cd  /opt/ocp4.3/
    cp -Rp install-config.yaml  /opt/ocp4.3/install-`date +%Y%m%d$h`/
    
    **# manifests 생성** 
    ./openshift-install create manifests --dir=/opt/ocp4.3/install-`date +%Y%m%d$h`/
    INFO Consuming Install Config from target directory
    WARNING Making control-plane schedulable by setting MastersSchedulable to true for Scheduler cluster settings
    
    **# cluster-scheduler-02-config 수정  control-plane에 사용자 파드 배포되지않게** 
    vi /opt/ocp4.3/install-`date +%Y%m%d$h`/manifests/cluster-scheduler-02-config.yml
    ...
    spec:
      mastersSchedulable: false
      policy:
    ...
    
    **# ignition 파일 생성**
    ./openshift-install create ignition-configs --dir=/opt/ocp4.3/install-`date +%Y%m%d$h`/
    
    **# kubeconfig 경로 설정**
    export KUBECONFIG=/opt/ocp4.3/install-`date +%Y%m%d$h`/auth/kubeconfig
    
    **# ignition 파일 복사**
    sudo cp -Rp  /opt/ocp4.3/install-`date +%Y%m%d$h`/*.ign /var/ftp/pub/

### online - install - bootstrap node

    https://cloud.redhat.com/openshift/install/metal/user-provisioned 
    **사이트에서 다운받은 Red Hat Enterprise Linux CoreOS (RHCOS) iso 파일로 부팅** 
    
    부팅 화면에서 
    tab 입력후 
    
    **# DHCP 구성시** 
    coreos.inst=yes
    	coreos.inst.install_dev=sda 
    	coreos.inst.image_url=ftp://192.168.40.30/pub/rhcos-4.3.0-x86_64-metal.raw.gz
    	coreos.inst.ignition_url=ftp://192.168.40.30/pub/bootstrap.ign
    
    **# DHCP 미구성시** 
    coreos.inst=yes
    	coreos.inst.install_dev=sda 
    	coreos.inst.image_url=ftp://192.168.40.30/pub/rhcos-4.3.0-x86_64-metal.raw.gz
    	coreos.inst.ignition_url=ftp://192.168.40.30/pub/bootstrap.ign 
    	ip=192.168.40.10::192.168.40.1:255.2555.255.0:bootstrap.ocp4-1.fu.te:ens192:none nameserver=192.168.40.1

### online - install - bastion

    su - core
    cd /opt/ocp4.3/
    openshift-install --dir=/opt/ocp4.3/install-`date +%Y%m%d$h`/ bootstrap-complete --log-level=info
    INFO Waiting up to 30m0s for the Kubernetes API at https://api.ocp4.fu.te:6443...
    
    # bootstrap에 접속 
    ssh 192.168.40.10
    접속 화면에 나타나는 명령로 확인 중 etcd 접속 문제 메세지 확인되면 master node install 진행 

### online - install - master

    https://cloud.redhat.com/openshift/install/metal/user-provisioned 
    **사이트에서 다운받은 Red Hat Enterprise Linux CoreOS (RHCOS) iso 파일로 부팅** 
    
    부팅 화면에서 
    tab 입력후 
    
    **# DHCP 구성시** 
      coreos.inst=yes
    	coreos.inst.install_dev=sda 
    	coreos.inst.image_url=ftp://192.168.40.30/pub/rhcos-4.3.0-x86_64-metal.raw.gz
    	coreos.inst.ignition_url=ftp://192.168.40.30/pub/master.ign 
    
    **# DHCP 미구성시** 
      coreos.inst=yes
    	coreos.inst.install_dev=sda 
    	coreos.inst.image_url=ftp://192.168.40.30/pub/rhcos-4.3.0-x86_64-metal.raw.gz
    	coreos.inst.ignition_url=ftp://192.168.40.30/pub/master.ign 
    	ip=192.168.40.101::192.168.40.1:255.2555.255.0:master01.ocp4-1.fu.te:ens192:none nameserver=192.168.40.1
    	ip=192.168.40.102::192.168.40.1:255.2555.255.0:master02.ocp4-1.fu.te:ens192:none nameserver=192.168.40.1
    	ip=192.168.40.103::192.168.40.1:255.2555.255.0:master03.ocp4-1.fu.te:ens192:none nameserver=192.168.40.1

### online - install - worker

    https://cloud.redhat.com/openshift/install/metal/user-provisioned 
    **사이트에서 다운받은 Red Hat Enterprise Linux CoreOS (RHCOS) iso 파일로 부팅** 
    
    부팅 화면에서 
    tab 입력후 
    
    **# DHCP 구성시** 
    coreos.inst=yes
    	coreos.inst.install_dev=sda 
    	coreos.inst.image_url=ftp://192.168.40.30/pub/rhcos-4.3.0-x86_64-metal.raw.gz
    	coreos.inst.ignition_url=ftp://192.168.40.30/pub/worker.ign 
    
    **# DHCP 미구성시**
    coreos.inst=yes
    	coreos.inst.install_dev=sda 
    	coreos.inst.image_url=ftp://192.168.40.30/pub/rhcos-4.3.0-x86_64-metal.raw.gz
    	coreos.inst.ignition_url=ftp://192.168.40.30/pub/worker.ign 
    	ip=192.168.40.201::192.168.40.1:255.2555.255.0:worker01.ocp4-1.fu.te:ens192:none nameserver=192.168.40.1
    	ip=192.168.40.202::192.168.40.1:255.2555.255.0:worker02.ocp4-1.fu.te:ens192:none nameserver=192.168.40.1

### online - install - bastion - complete

    $ openshift-install --dir=/install_dir/ocp4.3 wait-for bootstrap-complete --log-level=info
    INFO Waiting up to 30m0s for the Kubernetes API at https://api.ocp4.fu.te:6443...
    INFO API v1.16.2 up
    INFO Waiting up to 30m0s for bootstrapping to complete...
    INFO It is now safe to remove the bootstrap resources

## Post-Install

### node 확인

    $ oc get nodes
    NAME                    STATUS   ROLES    AGE   VERSION
    master01.ocp4-1.fu.te   Ready    master   16m   v1.16.2
    master02.ocp4-1.fu.te   Ready    master   16m   v1.16.2
    master03.ocp4-1.fu.te   Ready    master   16m   v1.16.2
    
    $ oc get csr
    NAME        AGE     REQUESTOR                                                                   CONDITION
    csr-bcs6j   17m     system:node:master01.ocp4-1.fu.te                                           Approved,Issued
    csr-d7xvd   5m50s   system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
    csr-kjttj   17m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Approved,Issued
    csr-md5h6   16m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Approved,Issued
    csr-mdccn   17m     system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Approved,Issued
    csr-qvb7p   16m     system:node:master02.ocp4-1.fu.te                                           Approved,Issued
    csr-t9c97   16m     system:node:master03.ocp4-1.fu.te                                           Approved,Issued
    csr-x6l92   3m5s    system:serviceaccount:openshift-machine-config-operator:node-bootstrapper   Pending
    
    $ oc adm certificate approve csr-d7xvd
    certificatesigningrequest.certificates.k8s.io/csr-d7xvd approved
    $ oc adm certificate approve csr-x6l92
    certificatesigningrequest.certificates.k8s.io/csr-x6l92 approved
    
    $ oc get nodes
    NAME                    STATUS     ROLES    AGE   VERSION
    master01.ocp4-1.fu.te   Ready      master   18m   v1.16.2
    master02.ocp4-1.fu.te   Ready      master   17m   v1.16.2
    master03.ocp4-1.fu.te   Ready      master   17m   v1.16.2
    worker01.ocp4-1.fu.te   NotReady   worker   3s    v1.16.2
    worker02.ocp4-1.fu.te   NotReady   worker   1s    v1.16.2
    
    $ oc get csr -ojson | jq -r '.items[] | select(.status == {} ) | .metadata.name' | xargs oc adm certificate approve
    certificatesigningrequest.certificates.k8s.io/csr-pn8hg approved
    certificatesigningrequest.certificates.k8s.io/csr-qm88r approved
    
    $ oc get nodes
    NAME                    STATUS   ROLES    AGE   VERSION
    master01.ocp4-1.fu.te   Ready    master   19m   v1.16.2
    master02.ocp4-1.fu.te   Ready    master   18m   v1.16.2
    master03.ocp4-1.fu.te   Ready    master   18m   v1.16.2
    worker01.ocp4-1.fu.te   Ready    worker   73s   v1.16.2
    worker02.ocp4-1.fu.te   Ready    worker   71s   v1.16.2

### private registry pv 설정

    nfs를 이용한 pv 생성 
    vi storage/pv-image-registry.yaml
    apiVersion: v1
    kind: PersistentVolume
    metadata:
      name: "image-registry-storage"
    spec:
      accessModes:
      - ReadWriteMany
      capacity:
        storage: 100Gi
      nfs:
        path: /registry
        server: 192.168.40.20
      persistentVolumeReclaimPolicy: Retain
    
    $ oc create -f storage/pv-image-registry.yaml
    
    $ oc edit configs.imageregistry.operator.openshift.io/cluster
    ...
    managementState: Managed (이전값 : Removed )
    ...
    storage:
        pvc:
          claim:
    ...
    storage:
        pvc:
          claim:
    ...

    $ watch -n5 oc get clusteroperators
    NAME                                       VERSION   AVAILABLE   PROGRESSING   DEGRADED   SINCE
    authentication                             4.3.5     True        False         False      21h
    cloud-credential                           4.3.5     True        False         False      22h
    cluster-autoscaler                         4.3.5     True        False         False      21h
    console                                    4.3.5     True        False         False      21h
    dns                                        4.3.5     True        False         False      21h
    image-registry                             4.3.5     True        False         False      20h
    ingress                                    4.3.5     True        False         False      21h
    insights                                   4.3.5     True        False         False      22h
    kube-apiserver                             4.3.5     True        False         False      21h
    kube-controller-manager                    4.3.5     True        False         False      21h
    kube-scheduler                             4.3.5     True        False         False      21h
    machine-api                                4.3.5     True        False         False      21h
    machine-config                             4.3.5     True        False         False      21h
    marketplace                                4.3.5     True        False         False      21h
    monitoring                                 4.3.5     True        False         False      3h22m
    network                                    4.3.5     True        False         False      21h
    node-tuning                                4.3.5     True        False         False      21h
    openshift-apiserver                        4.3.5     True        False         False      21h
    openshift-controller-manager               4.3.5     True        False         False      21h
    openshift-samples                          4.3.5     True        False         False      21h
    operator-lifecycle-manager                 4.3.5     True        False         False      21h
    operator-lifecycle-manager-catalog         4.3.5     True        False         False      21h
    operator-lifecycle-manager-packageserver   4.3.5     True        False         False      3h16m
    service-ca                                 4.3.5     True        False         False      21h
    service-catalog-apiserver                  4.3.5     True        False         False      21h
    service-catalog-controller-manager         4.3.5     True        False         False      21h
    storage                                    4.3.5     True        False         False      21h

확인
1. webconsole url  : https://console-openshift-console.ocp4-1.fu.te
2. webconsole 접속 계정 : kubeadmin
3. webconsole  접속 페스워드 : /opt/ocp4.3/install-`date +%Y%m%d$h`/auth/kubeadmin-password   파일에 저장되어 있음
