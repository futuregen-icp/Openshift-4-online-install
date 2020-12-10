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

