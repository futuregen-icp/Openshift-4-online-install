# coreDNS를 이용한 upstreams 설정 

## coredns 에서 변경 가능한 설정 

> operator에서 관리를 하여 crd에 정의된 부분만 수정이 가능 <br> 
> 가능한 부분은 doamin forword upstream 설정

** 설정 방법 **

spec 부분에 수

```
oc edit dns.operator/default


apiVersion: operator.openshift.io/v1
kind: DNS
metadata:
  name: default
spec:
  servers:
  - name: testDoamin
    zones: 
      - test.holy.local
      - tests.holy.local
    forwardPlugin:
      upstreams: 
        - 192.168.1.152
  
```

## 테스트를 위한 DNS 구성 


server 192.168.1.152

```
cat /etc/dnsmasq.d/test.conf

dhcp-range=192.168.56.0,192.168.56.255,255.255.255.0,12h
address=/master01.tests.holy.local/192.168.56.201
address=/master02.tests.holy.local/192.168.56.202
address=/master03.tests.holy.local/192.168.56.203
address=/etcd-0.tests.holy.local/192.168.56.201
address=/etcd-1.tests.holy.local/192.168.56.202
address=/etcd-2.tests.holy.local/192.168.56.203
address=/bootstrap.tests.holy.local/192.168.56.200
address=/worker01.tests.holy.local/192.168.56.204
address=/worker02.tests.holy.local/192.168.56.205
server=/tests.holy.local/192.168.1.254
local=/test.holy.local/


cat /etc/hsots

127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
127.0.0.2   test.holy.local

```

## DNS 테스트 

```
11:37:08.357939 IP worker01.ocp4.igotit.co.kr.53280 > bastion.ocp4.igotit.co.kr.domain: 139+ A? b.tests.holy.local. (38)
11:37:08.358216 IP bastion.ocp4.igotit.co.kr.domain > worker01.ocp4.igotit.co.kr.53280: 139 NXDomain 0/0/0 (38)
11:37:22.150913 IP worker01.ocp4.igotit.co.kr.36541 > bastion.ocp4.igotit.co.kr.domain: 34040+ A? d.tests.holy.local. (38)
11:37:22.151072 IP bastion.ocp4.igotit.co.kr.domain > worker01.ocp4.igotit.co.kr.36541: 34040 NXDomain 0/0/0 (38)
11:37:50.104477 IP worker01.ocp4.igotit.co.kr.51049 > bastion.ocp4.igotit.co.kr.domain: 42183+ A? d.test.holy.local. (37)
11:37:50.104606 IP bastion.ocp4.igotit.co.kr.domain > worker01.ocp4.igotit.co.kr.51049: 42183 NXDomain 0/0/0 (37)


11:41:25.384269 IP worker01.ocp4.igotit.co.kr.47462 > bastion.ocp4.igotit.co.kr.domain: 8465+ A? test.hololy.local. (35)
11:41:25.384409 IP bastion.ocp4.igotit.co.kr.domain > worker01.ocp4.igotit.co.kr.47462: 8465* 1/0/0 A 127.0.0.2 (51)
11:41:25.384841 IP worker01.ocp4.igotit.co.kr.47462 > bastion.ocp4.igotit.co.kr.domain: 11501+ AAAA? test.hololy.local. (35)
11:41:25.384867 IP bastion.ocp4.igotit.co.kr.domain > worker01.ocp4.igotit.co.kr.47462: 11501 0/0/0 (35)
```

