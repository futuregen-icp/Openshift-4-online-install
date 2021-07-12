#  disconnected custom operator hub 구성 하기 



##  일부 operator 만 구성 



### 공통 적용 사항 

1.  RHEL 8 설치 
2. python3 및 모듈 설치  (pyyaml, jinja2 library)

3. docker registry 구성 필요 

   

### opm 명령을 이용하는 구성 

```
wget https://github.com/fullstorydev/grpcurl/releases/download/v1.8.1/grpcurl_1.8.1_linux_x86_64.tar.gz
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/fast-4.6/opm-linux.tar.gz
(https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest-4.6/?extIdCarryOver=true&sc _cid=701f2000001Css5AAC)
```



Container에 정리 할 Source Index Image

```
 podman run -p 50051:50051 -it registry.redhat.io/redhat/redhat-operator-index:v4.6
```

새터미널에서 색인 확인

```
grpcurl -plaintext localhost:50051 api.Registry/ListPackages > packages.out

 
cat packages.out
{
  "name": "3scale-operator"
}
{
  "name": "advanced-cluster-management"
} {
  "name": "amq-broker"
}
...
```

인덱스 정리 

```
opm index prune -f registry.redhat.io/redhat/redhat-operator-index:v4.6 -p 3scale-
operator apicast-operator -t registry.dis.test.fu.igotit.co.kr:5000/mirror-olm/redhat-
operator-index:v4.6
```

인덱스 이미지 push

```
podman push registry.dis.test.fu.igotit.co.kr:5000/mirror-olm/redhat-operator-index:v4.6
```

혹시 ca 관련 에러 발생시 

```
export GODEBUG=x509ignoreCN=0
```

manifests 생성 

```
oc adm catalog mirror -a /root/.docker/config.json registry.dis.test.fu.igotit.co.kr:5000/mirror-olm/redhat-operator-index:v4.6 registry.dis.test.fu.igotit.co.kr:5000 --filter-by-os=linux/amd64 --insecure --manifests-only
```

```
manifests-redhat-operators-xxxxxxxx 디렉토리 생성됨 
cd manifests-redhat-operators-xxxxxxxx

아래의 파일이 존재함 
catalogSource.yaml              # custum operator hub 
imageContentSourcePolicy.yaml   # image에 대한 정책 
mapper.txt                      # 매핑 정보 
```

operator mirroring 

```
oc image mirror -a /root/.docker/config.json -f mapping.txt --filter-by-os=linux/amd64 --insecure
```

operator hub 구성 

```
oc apply -f imageContentSourcePolicy.yaml
oc apply -f catalogSource.yaml  
```



## 일부 필요한 operator 선별법

번들로 포함되는 operator-metadata, related_image를 조회한 결과

```
sqlite> select * from channel where package_name like '%scale%' ;
threescale-2.9|3scale-operator|3scale-operator.v0.6.1
threescale-2.6|3scale-operator|3scale-operator.v0.3.0
threescale-2.10|3scale-operator|3scale-operator.v0.7.0
threescale-2.7|3scale-operator|3scale-operator.v0.4.2
threescale-2.8|3scale-operator|3scale-operator.v0.5.5
4.6|vertical-pod-autoscaler|verticalpodautoscaler.4.6.0-202106090722
sqlite>
sqlite> select * from channel where package_name like '%api%' ;
fuse-apicurito-7.7.x|fuse-apicurito|apicuritooperator.v7.7.1
fuse-apicurito-7.8.x|fuse-apicurito|fuse-apicurito.v7.8.0
threescale-2.8|apicast-operator|apicast-operator.v0.2.4
threescale-2.9|apicast-operator|apicast-operator.v0.3.1
threescale-2.10|apicast-operator|apicast-operator.v0.4.0
sqlite>
sqlite> select name,bundlepath from operatorbundle where name like '%3scale-operator.v0.6%';
3scale-operator.v0.6.0|registry.redhat.io/3scale-amp2/3scale-rhel7-operator-metadata@sha256:996c4b5c28ba35b640f2ccf12f49a477bdd65e69c3741f0253c850aaf14f0176
3scale-operator.v0.6.1|registry.redhat.io/3scale-amp2/3scale-rhel7-operator-metadata@sha256:d3f06246be00c7a0e8474eee22791a9b0fcd64863bcd45a19d84e5dc88bc075a
sqlite>
sqlite> select name,bundlepath from operatorbundle where name like '%apicast-operator.v0.3%';
apicast-operator.v0.3.0|registry.redhat.io/3scale-amp2/apicast-rhel7-operator-metadata@sha256:f66685c272d98de6e5c32f4090fc4dc84f0c94fa05a233b4f7737a31d478b983
apicast-operator.v0.3.1|registry.redhat.io/3scale-amp2/apicast-rhel7-operator-metadata@sha256:da8930f0d4a627f323166fe8506f0a31e67c96cf258c548acc1cc60b461adc7f
sqlite>
sqlite> select * from related_image where operatorbundle_name like '3scale-operator.v0.6.0' ;
registry.redhat.io/3scale-amp2/system-rhel7@sha256:fa5e04c1ef2139aa728ef3197ca8ed27361350dc28c0713f8906f67f255448bc|3scale-operator.v0.6.0
registry.redhat.io/3scale-amp2/3scale-rhel7-operator@sha256:6aaac50f48cb3e0461c28a7e0305bbd1cd00150772fd835f4e00fbfdcd5520d6|3scale-operator.v0.6.0
registry.redhat.io/3scale-amp2/zync-rhel7@sha256:7aa6069c3c885b4602a877120ea9c3be7fc237201f1d0c29dd0dff96fba21e0e|3scale-operator.v0.6.0
registry.redhat.io/3scale-amp2/memcached-rhel7@sha256:2ab37b3fd0249c4c0f372dddd2210f0a004fbae1c3398350ef4bbeefc3032aa0|3scale-operator.v0.6.0
|3scale-operator.v0.6.0
registry.redhat.io/openshift4/ose-cli@sha256:353036a27e810730ce35d699dcf09141af9f8ae9e365116755016d864475c2c4|3scale-operator.v0.6.0
registry.redhat.io/3scale-amp2/apicast-gateway-rhel8@sha256:59d53166fd14e52a5da46e215fbe731796accfd6b98efdbd093ee45604e8e0a9|3scale-operator.v0.6.0
registry.redhat.io/3scale-amp2/backend-rhel7@sha256:b6db56f338d02fed95d439e0f1a88b3590de359bffdddeceb954ce5f46fda8df|3scale-operator.v0.6.0
sqlite>
sqlite> select * from related_image where operatorbundle_name like '3scale-operator.v0.6.1';
registry.redhat.io/3scale-amp2/3scale-rhel7-operator@sha256:5a8ecc0933b6e7d0faf3d6f84e3b7fd287ee52849231e2870f7376ba96fe603c|3scale-operator.v0.6.1
registry.redhat.io/rhscl/redis-32-rhel7@sha256:a9bdf52384a222635efc0284db47d12fbde8c3d0fcb66517ba8eefad1d4e9dc9|3scale-operator.v0.6.1
registry.redhat.io/3scale-amp2/memcached-rhel7@sha256:33a333cd8ae8d1d39aa297ba61c5bdbb4f8f3ada63e84196e5d2187ec63480be|3scale-operator.v0.6.1
registry.redhat.io/3scale-amp2/zync-rhel7@sha256:04add0c1e4ceaa3628939ed1e72dcc70b90ae669c831f2e9782f895959b371ed|3scale-operator.v0.6.1
registry.redhat.io/3scale-amp2/backend-rhel7@sha256:48b8b101be540bcd06c3d5672bcbc07da12333916ac2ed5a93ccc3c077da9195|3scale-operator.v0.6.1
registry.redhat.io/3scale-amp2/system-rhel7@sha256:75d50fa5006e10574670507beb290992da992ec3dbfb1a55013894432bf94150|3scale-operator.v0.6.1
registry.redhat.io/rhscl/mysql-57-rhel7@sha256:9a781abe7581cc141e14a7e404ec34125b3e89c008b14f4e7b41e094fd3049fe|3scale-operator.v0.6.1
registry.redhat.io/rhscl/postgresql-10-rhel7@sha256:de3ab628b403dc5eed986a7f392c34687bddafee7bdfccfd65cecf137ade3dfd|3scale-operator.v0.6.1
registry.redhat.io/openshift4/ose-cli@sha256:353036a27e810730ce35d699dcf09141af9f8ae9e365116755016d864475c2c4|3scale-operator.v0.6.1
registry.redhat.io/3scale-amp2/apicast-gateway-rhel8@sha256:a3a841ce413b2e050fe44a30f3b3fd82256d91e0daa81f13ecd40f97a95e68ab|3scale-operator.v0.6.1
sqlite>
sqlite> select * from related_image where operatorbundle_name like 'apicast-operator.v0.3.1' ;
registry.redhat.io/3scale-amp2/apicast-rhel7-operator@sha256:45d0318ce73d19a016fed8a5af0b16a5f423b423b57b515c7d3de70daadfe33b|apicast-operator.v0.3.1
registry.redhat.io/3scale-amp2/apicast-gateway-rhel8@sha256:a3a841ce413b2e050fe44a30f3b3fd82256d91e0daa81f13ecd40f97a95e68ab|apicast-operator.v0.3.1
```

**위의 내용으로 확인된 이미지 목록 입니다**

```
registry.redhat.io/3scale-amp26/3scale-operator:latest
registry.redhat.io/3scale-amp2/3scale-rhel7-operator-metadata@sha256:996c4b5c28ba35b640f2ccf12f49a477bdd65e69c3741f0253c850aaf14f0176
registry.redhat.io/3scale-amp2/3scale-rhel7-operator-metadata@sha256:d3f06246be00c7a0e8474eee22791a9b0fcd64863bcd45a19d84e5dc88bc075a
registry.redhat.io/3scale-amp2/backend-rhel7@sha256:b6db56f338d02fed95d439e0f1a88b3590de359bffdddeceb954ce5f46fda8df
registry.redhat.io/3scale-amp2/3scale-rhel7-operator@sha256:5a8ecc0933b6e7d0faf3d6f84e3b7fd287ee52849231e2870f7376ba96fe603c
registry.redhat.io/rhscl/redis-32-rhel7@sha256:a9bdf52384a222635efc0284db47d12fbde8c3d0fcb66517ba8eefad1d4e9dc9
registry.redhat.io/3scale-amp2/memcached-rhel7@sha256:33a333cd8ae8d1d39aa297ba61c5bdbb4f8f3ada63e84196e5d2187ec63480be
registry.redhat.io/3scale-amp2/zync-rhel7@sha256:04add0c1e4ceaa3628939ed1e72dcc70b90ae669c831f2e9782f895959b371ed
registry.redhat.io/3scale-amp2/backend-rhel7@sha256:48b8b101be540bcd06c3d5672bcbc07da12333916ac2ed5a93ccc3c077da9195
registry.redhat.io/3scale-amp2/system-rhel7@sha256:75d50fa5006e10574670507beb290992da992ec3dbfb1a55013894432bf94150
registry.redhat.io/rhscl/postgresql-10-rhel7@sha256:de3ab628b403dc5eed986a7f392c34687bddafee7bdfccfd65cecf137ade3dfd
registry.redhat.io/rhscl/mysql-57-rhel7@sha256:9a781abe7581cc141e14a7e404ec34125b3e89c008b14f4e7b41e094fd3049fe
registry.redhat.io/openshift4/ose-cli@sha256:353036a27e810730ce35d699dcf09141af9f8ae9e365116755016d864475c2c4
registry.redhat.io/3scale-amp2/apicast-rhel7-operator-metadata@sha256:f66685c272d98de6e5c32f4090fc4dc84f0c94fa05a233b4f7737a31d478b983
registry.redhat.io/3scale-amp2/apicast-rhel7-operator-metadata@sha256:da8930f0d4a627f323166fe8506f0a31e67c96cf258c548acc1cc60b461adc7f
registry.redhat.io/3scale-amp2/apicast-rhel7-operator@sha256:f78be20adbfd93be9a5cfe49ebfffbed53f73d6c0588419d89b5230ffac3bad4
registry.redhat.io/3scale-amp2/apicast-gateway-rhel8@sha256:59d53166fd14e52a5da46e215fbe731796accfd6b98efdbd093ee45604e8e0a9
registry.redhat.io/3scale-amp2/apicast-rhel7-operator@sha256:45d0318ce73d19a016fed8a5af0b16a5f423b423b57b515c7d3de70daadfe33b
registry.redhat.io/3scale-amp2/apicast-gateway-rhel8@sha256:a3a841ce413b2e050fe44a30f3b3fd82256d91e0daa81f13ecd40f97a95e68ab
registry.redhat.io/rhscl/redis-5-rhel7@sha256:8cfa1d94f5a4e00689ed9585bbdf22c3503e47829cff37d51c90cf3a028c679c
```

위의 내용으로 구성한 mapping 정보

```
registry.redhat.io/3scale-amp26/3scale-operator:latest=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp26/3scale-operator:latest
registry.redhat.io/3scale-amp2/3scale-rhel7-operator-metadata@sha256:996c4b5c28ba35b640f2ccf12f49a477bdd65e69c3741f0253c850aaf14f0176=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/3scale-rhel7-operator-metadata:fbfbe873
registry.redhat.io/3scale-amp2/3scale-rhel7-operator-metadata@sha256:d3f06246be00c7a0e8474eee22791a9b0fcd64863bcd45a19d84e5dc88bc075a=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/3scale-rhel7-operator-metadata:7c1bb4b1
registry.redhat.io/3scale-amp2/backend-rhel7@sha256:b6db56f338d02fed95d439e0f1a88b3590de359bffdddeceb954ce5f46fda8df=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/backend-rhel7:d3e02baf
registry.redhat.io/3scale-amp2/3scale-rhel7-operator@sha256:5a8ecc0933b6e7d0faf3d6f84e3b7fd287ee52849231e2870f7376ba96fe603c=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/3scale-rhel7-operator:b3929408
registry.redhat.io/rhscl/redis-32-rhel7@sha256:a9bdf52384a222635efc0284db47d12fbde8c3d0fcb66517ba8eefad1d4e9dc9=registry.dis.test.fu.igotit.co.kr:5000/rhscl/redis-32-rhel7:b5c56c9a
registry.redhat.io/3scale-amp2/memcached-rhel7@sha256:33a333cd8ae8d1d39aa297ba61c5bdbb4f8f3ada63e84196e5d2187ec63480be=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/memcached-rhel7:68ce39ac
registry.redhat.io/3scale-amp2/zync-rhel7@sha256:04add0c1e4ceaa3628939ed1e72dcc70b90ae669c831f2e9782f895959b371ed=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/zync-rhel7:dcfbe1fe
registry.redhat.io/3scale-amp2/backend-rhel7@sha256:48b8b101be540bcd06c3d5672bcbc07da12333916ac2ed5a93ccc3c077da9195=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/backend-rhel7:7df778cc
registry.redhat.io/3scale-amp2/system-rhel7@sha256:75d50fa5006e10574670507beb290992da992ec3dbfb1a55013894432bf94150=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/system-rhel7:93c46782
registry.redhat.io/rhscl/postgresql-10-rhel7@sha256:de3ab628b403dc5eed986a7f392c34687bddafee7bdfccfd65cecf137ade3dfd=registry.dis.test.fu.igotit.co.kr:5000/rhscl/postgresql-10-rhel7:49ca41ba
registry.redhat.io/rhscl/mysql-57-rhel7@sha256:9a781abe7581cc141e14a7e404ec34125b3e89c008b14f4e7b41e094fd3049fe=registry.dis.test.fu.igotit.co.kr:5000/rhscl/mysql-57-rhel7:4d9bc7b7
registry.redhat.io/openshift4/ose-cli@sha256:353036a27e810730ce35d699dcf09141af9f8ae9e365116755016d864475c2c4=registry.dis.test.fu.igotit.co.kr:5000/openshift4/ose-cli:2c06d0a1
registry.redhat.io/3scale-amp2/apicast-rhel7-operator-metadata@sha256:f66685c272d98de6e5c32f4090fc4dc84f0c94fa05a233b4f7737a31d478b983=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/apicast-rhel7-operator-metadata:8ba4ab07
registry.redhat.io/3scale-amp2/apicast-rhel7-operator-metadata@sha256:da8930f0d4a627f323166fe8506f0a31e67c96cf258c548acc1cc60b461adc7f=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/apicast-rhel7-operator-metadata:c958d179
registry.redhat.io/3scale-amp2/apicast-rhel7-operator@sha256:f78be20adbfd93be9a5cfe49ebfffbed53f73d6c0588419d89b5230ffac3bad4=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/apicast-rhel7-operator:f1e163a5
registry.redhat.io/3scale-amp2/apicast-gateway-rhel8@sha256:59d53166fd14e52a5da46e215fbe731796accfd6b98efdbd093ee45604e8e0a9=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/apicast-gateway-rhel8:87ac0051
registry.redhat.io/3scale-amp2/apicast-rhel7-operator@sha256:45d0318ce73d19a016fed8a5af0b16a5f423b423b57b515c7d3de70daadfe33b=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/apicast-rhel7-operator:f1c0ba71
registry.redhat.io/3scale-amp2/apicast-gateway-rhel8@sha256:a3a841ce413b2e050fe44a30f3b3fd82256d91e0daa81f13ecd40f97a95e68ab=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/apicast-gateway-rhel8:22a2e5a6
registry.redhat.io/rhscl/redis-5-rhel7@sha256:8cfa1d94f5a4e00689ed9585bbdf22c3503e47829cff37d51c90cf3a028c679c=registry.dis.test.fu.igotit.co.kr:5000/rhscl/redis-5-rhel7

```

