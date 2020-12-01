# habor install 

## hard ware requement 
|Resource |	Minimum |	Recommended|
|:---:|:---:|:---:|
|CPU |	2 CPU |	4 CPU|
|Mem |	4 GB |	8 GB|
|Disk |	40 GB |	160 GB|

## firewall requement

|Port |	Protocol |	Description|
|:---:|:---:|:---:|
|443 |	HTTPS |	Harbor portal and core API accept HTTPS requests on this port. You can change this port in the configuration file.|
|4443 |	HTTPS |	Connections to the Docker Content Trust service for Harbor. Only required if Notary is enabled. You can change this port in the configuration file.|
|80 |	HTTP |	Harbor portal and core API accept HTTP requests on this port. You can change this port in the configuration file.|

## OS install 

CentOS 7.x or RHEL 7.x 
   
    yum update -y
    yum install -y psmisc procps net-tools sysstat iptraf wget
    yum install -y podman
	reboot

## docker 설치 

	yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

	yum install -y yum-utils

	yum-config-manager \
    		--add-repo \
    		https://download.docker.com/linux/centos/docker-ce.repo

	yum install docker-ce docker-ce-cli containerd.io

    systemctl start docker
	systemctl enable docker

## habor download
	 
	사이트 확인
	https://github.com/goharbor/harbor/releases 

	cd /opt/src
	wget https://github.com/goharbor/harbor/releases/download/v1.10.6/harbor-offline-installer-v1.10.6.tgz

## 압축 해제

	tar zxvfp harbor-offline-installer-v1.10.6.tgz


## 인증서

### 사설 root ca 생성 
	cd /opt/harbor/certs 
	
	openssl genrsa -out ca.key 4096

	openssl req -x509 -new -nodes -sha512 -days 3650 -subj "/C=CN/ST=korea/L=korea/O=image/OU=Personal/CN=test.fu.igotit.co.kr" -key ca.key -out ca.crt

### 사설 인증서 생성 
	
**요청서 생성**

	openssl genrsa -out image.test.fu.igotit.co.kr.key 4096

	openssl req -sha512 -new -days 3000 -subj "/C=CN/ST=korea/L=korea/O=image/OU=Personal CN=test.fu.igotit.co.kr" -key image.test.fu.igotit.co.kr.key -out image.test.fu.igotit.co.kr.csr

**Generate an x509 v3 extension file.**

	cat > v3.ext <<-EOF
	authorityKeyIdentifier=keyid,issuer
	basicConstraints=CA:FALSE
	keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
	extendedKeyUsage = serverAuth
	subjectAltName = @alt_names
	
	[alt_names]
	DNS.1=image.test.fu.igotit.co.kr
	DNS.2=test.fu.igotit.co.kr
	DNS.3=fu.igotit.co.kr
	EOF

	
**사설 인증서 생성**

	openssl x509 -req -sha512 -days 3650 -extfile v3.ext -CA ca.crt -CAkey ca.key -CAcreateserial -in image.test.fu.igotit.co.kr.csr -out image.test.fu.igotit.co.kr.crt

**PEM 인증서 생성**

	openssl x509 -inform PEM -in image.test.fu.igotit.co.kr.crt -out image.test.fu.igotit.co.kr.pem

### 인증서 복사
	
**contener에 복사**

	mkdir /opt/harbor/cert/

	cp -Rp image.test.fu.igotit.co.kr.crt /opt/harbor/cert/
	cp -Rp image.test.fu.igotit.co.kr.key /opt/harbor/cert/


**harbor 사용위치에 복사**

	mkdir /etc/containers/certs.d/image.test.fu.igotit.co.kr/

	cp -Rp ca.crt /etc/containers/certs.d/
	cp -Rp image.test.fu.igotit.co.kr.pem /etc/containers/certs.d/image.test.fu.igotit.co.kr/
	cp -Rp image.test.fu.igotit.co.kr.key /etc/containers/certs.d/image.test.fu.igotit.co.kr/


### 설정 파일 수정 

**harbor.yml파일에서 아래항목을 서버 상항에 맞게 수정** 


	hostname: image.test.xx.xxxxx.xx.kr

	http:
	  port: 80
	
	https:
	  port: 443
	  certificate: /opt/harbor/cert/image.test.fu.igotit.co.kr.crt
	  private_key: /opt/harbor/cert/image.test.fu.igotit.co.kr.key
	
	
	harbor_admin_password: 1Vbcjwps11
	

	database:
	  password: 1Vbcjwps11
	
	data_volume: /opt/harbor/data


### 설치 진행 

	./prepare
	prepare base dir is set to /opt/src/harbor
	Unable to find image 'goharbor/prepare:v1.10.6' locally
	v1.10.6: Pulling from goharbor/prepare
	Digest: sha256:69f82eb208b548444b997fb4f22ebc962932d76322edb699f527912e0429ffbd
	Status: Downloaded newer image for goharbor/prepare:v1.10.6
	Clearing the configuration file: /config/log/logrotate.conf
	Clearing the configuration file: /config/log/rsyslog_docker.conf
	Generated configuration file: /config/log/logrotate.conf
	Generated configuration file: /config/log/rsyslog_docker.conf
	Generated configuration file: /config/nginx/nginx.conf
	Generated configuration file: /config/core/env
	Generated configuration file: /config/core/app.conf
	Generated configuration file: /config/registry/config.yml
	Generated configuration file: /config/registryctl/env
	Generated configuration file: /config/db/env
	Generated configuration file: /config/jobservice/env
	Generated configuration file: /config/jobservice/config.yml
	Generated and saved secret to file: /secret/keys/secretkey
	Generated certificate, key file: /secret/core/private_key.pem, cert file: /secret/registry/root.crt
	Generated configuration file: /compose_location/docker-compose.yml
	Clean up the input dir


### 접속 테스트 

	https://image.test.xx.xxxxx.xx.kr