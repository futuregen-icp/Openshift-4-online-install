## 사전 작업 

### 서브스크립션 등록

```
    subscription-manager register 
    subscription-manager refresh
    subscription-manager list --available --matches '*OpenShift*'
    subscription-manager attach --pool=**************
    subscription-manager repos \
                   --enable="rhel-7-server-rpms" \
                   --enable="rhel-7-server-extras-rpms" \
                   --enable="rhel-7-server-ansible-2.9-rpms" \
                   --enable="rhel-7-server-ose-3.11-rpms" \                                                    
                   --enable="rhel-7-server-ose-4.6-rpms"

```



### 업데이트

```
yum update -y
```



### docker engine을 대신을 container utile

```
yum -y install buildah podman
```



### util 설치

```
yum install -y net-tools procps psmisc bind-utils sysstat iptraf wget
```



### source-to-image install

```
subscription-manager repos --enable="rhel-server-rhscl-7-rpms"
yum install source-to-image
```



### jboss base build images 가져오기

```
buildah login registry.redhat.io
// eap7.2
buildah pull registry.redhat.io/jboss-eap-7/eap72-openshift
// eap 7.2 data grid
uildah pull registry.redhat.io/jboss-datagrid-7/datagrid72-openshift
```



### 이미지 내부 확인하기

```
mkdir -p /opt/s2i/build_image/jboss_eap_7.2/src
cd /opt/s2i/build_image/jboss_eap_7.2/src
podman save -o a.tar registry.redhat.io/jboss-eap-7/eap72-openshift

tar xvfp a.tar
// 이미지 레이어 순서 확인 후 압축 해제
cat cat manifest.json  

tar xvfp  22415211085ffc4824924dc64c501adaae6e210293c364da308f3d0a8f1772c5.tar
tar xvfp  063d4ba31922b81b2246deecb7b79629e0a886c977861247d59a72d8e72191bf.tar 
tar xvfp  fb736f122a76014a9a90e691b9987dc6a637281973d6d4189ec5629a87d81542.tar

rm -f 063d4ba31922b81b2246deecb7b79629e0a886c977861247d59a72d8e72191bf.tar 
rm -f 22415211085ffc4824924dc64c501adaae6e210293c364da308f3d0a8f1772c5.tar
rm -f fb736f122a76014a9a90e691b9987dc6a637281973d6d4189ec5629a87d81542.tar 
rm -f e3a06e233f32437532933e7614bd7a62c444c083850ec934146cc104a1493221.json
rm -rf 22415211085ffc4824924dc64c501adaae6e210293c364da308f3d0a8f1772c5/ 
rm -rf 8c4cdf4cf242f1ccbfb3f95a56473c8aaebb528240404a45c0a549abd380448e/ 
rm -rf da4a8ce15960d72757e4fba5c56da5b39ddc91ac3dac94ed81de57d19fdb3e46/
rm -f manifest.json

```



	### 빌드 준비 하기

**환경 만들기**

```
mkdir /opt/s2i/build_image/jboss_eap_7.2/buiild
cd /opt/s2i/build_image/jboss_eap_7.2/buiild/
mkdir -p eap72/bin/
mkdir -p eap72/standalon/configration/

cp -Rp ../src/opt/eap/standalone/configuration/standalone-openshift.xml ./eap72/standalon/configration/
cp -Rp ../src/opt/eap/bin/standalone.conf ./eap72/bin/
cp -Rp ../src/opt/eap/bin/openshift-launch.sh ./eap72/bin/
cp -Rp ../src/opt/eap/bin/launch ./eap72/bin/
cp -Rp ../src/opt/eap/bin/standalone.sh ./eap72/bin/
cp -Rp ../src/opt/run-java ./
```



**s2i 스크립트 복사**

```
  mkdir /opt/s2i/build_image/jboss_eap_7.2/buiild/usr
  ll
  cp -Rp /opt/s2i/build_image/jboss_eap_7.2/buiild/src/usr/local/s2i/ usr/s2i/
  cp -Rp /opt/s2i/build_image/jboss_eap_7.2/buiild/src/opt/jboss/ usr/jboss/
```



### build 전 참고 사항 

- JABOSS_HOME   :  /opt/eap/
- Deploy                 :  /deployments
- source 위치         :   /tmp/src