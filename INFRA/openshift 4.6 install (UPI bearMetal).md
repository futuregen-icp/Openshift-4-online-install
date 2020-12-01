# openshift 4.6 install  (UPI bearMetal) 

---

## requerment

### H/W
|Machine|Operating System|vCPU|Virtual RAM|Storage|amount|
|:---:|:---:|:---:|:---:|:---:|:---:|
|Bootstrap|RHCOS|4|16 GB|120 GB|1|
|Control plane|RHCOS|4|16 GB|120 GB|3|
|Compute|RHCOS or RHEL 7.6|2|8 GB|120 GB|2|

### DNS
|Port|Back-end machines (pool members)|Internal|External|Description|
|:---:|:---:|:---:|:---:|:---:|
|6443/tcp|bootstrap & control palne| ○ | △ |Kubernetes API server| 
|22623/tcp|bootstrap & control palne| ○ |  |Kubernetes API server| 
|80/tcp|A node that can be routed among nodes| ○ | ○ |ingress service|
|443/tcp|A node that can be routed among nodes| ○ | ○ |ingress service|

### firewall policy

**machine to machine** 
|Protocol|Port|Description|
|:---:|:---:|:---:|
|ICMP|N/A|Network reachability tests|
|TCP|9000-9999|Host level services, including the node exporter on ports 9100-9101 and the Cluster Version Operator on port 9099.|
|TCP|10250-10259|The default ports that Kubernetes reserves|
|TCP|10256|openshift-sdn|
|UDP|4789|VXLAN and Geneve|
|UDP|6081|VXLAN and Geneve|
|UDP|9000-9999|Host level services, including the node exporter on ports 9100-9101.|
|TCP/UDP|30000-32767|Kubernetes NodePort|

**Control plane to machine**
|Protocol|Port|Description|
|:---:|:---:|:---:|
|TCP|2379-2380|etcd server, peer, and metrics ports|
|TCP|6443|Kubernetes API|

**DNS Recode**

|Recode|name|target|etc|
|:---:|:---:|:---:|
|A|api|lb|k8s api|
|A|api-int|lb|k8s api|
|A|apps|lb|route|
|A|bootstrap|IP|server|
|A|master|IP|server|
|A|worker|IP|server|

## bastion 구성 

### Subscription 등록(전체 서버. disconnect 환경인 경우 외부 연결되는 서버에만)

	subscription-manager register --username=***** --password=******
	subscription-manager refresh
	subscription-manager list --available --matches '*OpenShift*'
	subscription-manager attach --pool=8a85f99c707807c801709f913ded7153
	subscription-manager repos     --enable="rhel-7-server-rpms"     \
    	                           --enable="rhel-7-server-extras-rpms"     \
    	                           --enable="rhel-7-server-ose-4.6-rpms"     \
    	                           --enable="rhel-7-server-ansible-2.9-rpms"

### repo server 구성 (테스트시 bastion또는 gate서버에 설정)  

	sudo yum -y install yum-utils createrepo docker git vsftpd

### repo 동기화 및 구성

	for repo in rhel-7-server-rpms rhel-7-server-extras-rpms rhel-7-server-ansible-2.9-rpms rhel-7-server-ose-4.6-rpms
	do
  		reposync --gpgcheck -lm --repoid=${repo} --download_path=/var/ftp/pub/repos
  		createrepo -v /var/ftp/pub/repos/${repo} -o /var/ftp/pub/repos${repo}
	done

### ftp 구동 
	
	systemctl enable vsftpd
	systemctl start vsftpd

### 설치에 필요한 파일 다운
 
	wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux.tar.gz
	wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz
	wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-installer.x86_64.iso
	wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-metal.x86_64.raw.gz

	tar zxvfp openshift-install-linux.tar.gz
	rm -f README.txt 
	mv openshift-install /usr/local/bin/
	chown core.core /usr/local/bin/openshift-install
	chmod 750 /usr/local/bin/openshift-install

	tar zxvfp openshift-client-linux.tar.gz
	rm -f README.txt
	mv kubectl /usr/local/bin/
	mv oc /usr/local/bin/
	chown core.core /usr/local/bin/kubectl
	chown core.core /usr/local/bin/oc
	chmod 750 /usr/local/bin/kubectl
	chmod 750 /usr/local/bin/oc

### pull secrets 구성 

**pull secrets down**

	https://cloud.redhat.com/openshift/install/metal/user-provisioned pull-secret download
	cd /opt/ocp4.3/pull
	cat ./pull-secret.text | jq .  > pull-secret.json

**mirror registry 구성시 추가 부분**

	mirror-registry 등록 (online 환경에서는 옵션)

	echo -n 'admin:admin' | base64 -w0  # admin:admin ( mirror registry 접속 계정 )
	**YWRtaW46YWRtaW4=**

	vi pull-secret.json  (아래 부부분 추가)
	    	}**,
	    	"registry.ocp4-1.fu.te" {
      		"auth": "YWRtaW46YWRtaW4=",
      		"email": "jaesuk.lee@futuregen.co.kr"
    		}**
  		}
	}

**podman login을 위한 config 설정**

	# bastion과 mirror registry 가 구동되는 서버에 설정 
	mkdir /home/core/.docker
	cp -Rp path/to/pull-secret.json /home/core/.docker/config.json


**ssh key 생성**
	
	ssh-keygen -t rsa -b 4096 -N ''

	eval "$(ssh-agent -s)"
		Agent pid 6020
	
	ssh-add
		Identity added: /home/core/.ssh/id_rsa (/home/core/.ssh/id_rsa)


## 설지 사전 작업 
	
### 인스톨 컨피그 생성 

	Path : /home/core/ocp46/intall/

	filename install-config.yaml
	
 	
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
	pullSecret: '{"auths": ...}' 
	sshKey: 'ssh-ed25519 AAAA...' 

### ignition 파일 생성 

	openshift-install create manifests --dir=/home/core/ocp46/install/

	**# cluster-scheduler-02-config 수정  control-plane에 사용자 파드 배포되지않게** 
	vi /home/core/ocp46/install/manifests/cluster-scheduler-02-config.yml
	...
	spec:
  	mastersSchedulable: false
  	policy:
	...


	openshift-install create ignition-configs --dir=/home/core/ocp46/install/

	**# ignition 파일 복사**
	sudo cp -Rp  /home/core/ocp46/install/*.ign /var/ftp/pub/ign/


### 인증 파일 연결 

	export KUBECONFIG=/home/core/ocp46/install/auth/kubeconfig

 
### ignition 파일 Customizing

**filetranspile 설치**

	yum install -y python3
	python3.6 -m pip install python-magic
	python3.6 -m pip install pyyaml
	python3.6 -m pip install file-magic  

	git clone https://github.com/ashcrow/filetranspiler.git

**추가 설정 (chrony, network)**

사전 

	path : /home/core/ocp46/ign
	file copy : cp -Rp  /home/core/ocp46/install/*.ign /home/core/ocp46/ign/


시간 설정 

	cat chrony.conf

	server 0.rhel.pool.ntp.org iburst
	server 1.rhel.pool.ntp.org iburst
	server 2.rhel.pool.ntp.org iburst
	server 3.rhel.pool.ntp.org iburst
	driftfile /var/lib/chrony/drift
	makestep 1.0 3
	rtcsync
	logdir /var/log/chrony

네트워크 설정

	cat ifcfg-ens192

	TYPE=Ethernet
	PROXY_METHOD=none
	BROWSER_ONLY=no
	BOOTPROTO=static
	NETMASK=255.255.255.0
	GATEWAY=192.168.6.1
	DEFROUTE=yes
	IPV4_FAILURE_FATAL=no
	NAME=ens192
	DEVICE=ens192
	ONBOOT=yes
	DOMAIN=test.fu.igotit.co.kr
	DNS1=192.168.6.1

**설치 노드 fake root 생성**

	cat make_conf.sh

	#!/bin/bash
	
	export BASE_DOM=test.fu.igotit.co.kr
	
	for server in master01 master02 master03 worker01 worker02
  	do
	    mkdir -p ${server}/etc/sysconfig/network-scripts
	    cp ./chrony.conf ${server}/etc
	    cp ./ifcfg-ens192 ${server}/etc/sysconfig/network-scripts
	
	cat <<EOF  >>${server}/etc/hostname
	${server}.${BASE_DOM}
	EOF
	
	done

	-----------------------------------------------------

	sh  make_conf.sh


**설치 노드별 아이피 생성**

	cat ifcfg-config.sh

	#!/bin/bash
	sed -i '5 i\IPADDR=192.168.6.211' ./master01/etc/sysconfig/network-scripts/ifcfg-ens192
	sed -i '5 i\IPADDR=192.168.6.212' ./master02/etc/sysconfig/network-scripts/ifcfg-ens192
	sed -i '5 i\IPADDR=192.168.6.213' ./master03/etc/sysconfig/network-scripts/ifcfg-ens192
	sed -i '5 i\IPADDR=192.168.6.221' ./worker01/etc/sysconfig/network-scripts/ifcfg-ens192
	sed -i '5 i\IPADDR=192.168.6.222' ./worker02/etc/sysconfig/network-scripts/ifcfg-ens192

	-----------------------------------------------------

	sh  ifcfg-config.sh


**filetranspile install**


	path : /home/core/ocp46/ign

	git clone https://github.com/ashcrow/filetranspiler.git

	sudo yum install python3*
	sudo python3.6 -m pip install python-magic
	sudo python3.6 -m pip install pyyaml
	sudo python3.6 -m pip install file-magic
	

**노드별 ignition 파일 생성**

    cat ignition.sh

	#!/bin/bash
	./filetranspiler/filetranspile -i /home/core/ocp46/ign/bootstrap.ign -f /home/core/ocp46/ign/bootstrap -o /home/core/ocp46/ign/ign/bts1.ign --format=yaml
	./filetranspiler/filetranspile -i /home/core/ocp46/ign/master.ign -f /home/core/ocp46/ign/master01 -o /home/core/ocp46/ign/ign/mst1.ign --format=yaml
	./filetranspiler/filetranspile -i /home/core/ocp46/ign/master.ign -f /home/core/ocp46/ign/master02 -o /home/core/ocp46/ign/ign/mst2.ign --format=yaml
	./filetranspiler/filetranspile -i /home/core/ocp46/ign/master.ign -f /home/core/ocp46/ign/master03 -o /home/core/ocp46/ign/ign/mst3.ign --format=yaml
	./filetranspiler/filetranspile -i /home/core/ocp46/ign/worker.ign -f /home/core/ocp46/ign/worker01 -o /home/core/ocp46/ign/ign/wk1.ign  --format=yaml
	./filetranspiler/filetranspile -i /home/core/ocp46/ign/worker.ign -f /home/core/ocp46/ign/worker02 -o /home/core/ocp46/ign/ign/wk2.ign  --format=yaml


