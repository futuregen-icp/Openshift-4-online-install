## Operator Hub Configuration

인터넷이 제한된 환경에서 설치된 Openshift의 경우는 OML이 Quay.io에서 원격으로 호스팅 되는  OperatorHub Source에 접근이 불가능합니다. 그렇기 때문에 인터넷이 제한된 환경에서는 필요한 Operator를 미러를 만들어 로칼 환경에서 관리가능하도록 OML을 구성합니다.



   - Disabling the default OperatorHub sources 

     ```
      $ oc patch OperatorHub cluster --type json \
         -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]''
     ```

   - Pruning an index image

        -  Prerequisites
              -  인터넷이 가능한 워크스테이션 및 서버
              -  podman verion 1.9.3 + 
              -  grpcurl : tool 설치 
              -  opm veresion 1.12.3+ (fast-4.6에서 받음)
                    -  Python3 필수 설치 
                    -  Python module :  pyyaml, jinja2, library
              -  Access to a registry that supports Docker v2-2
              -  RHEL 8+ 
        -  필수 파일 설치 

     ```
     # wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.6.35/openshift-install-linux.tar.gz
     # wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.6.35/openshift-client-linux.tar.gz
     # wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.6.35/opm-linux.tar.gz
     # wget https://github.com/fullstorydev/grpcurl/releases/download/v1.8.1/grpcurl_1.8.1_linux_x86_64.tar.gz
     
     # tar zxvfp openshift-install-linux.tar.gz -C /usr/local/bin/
     # tar zxvfp openshift-client-linux.tar.gz -C /usr/local/bin/
     # tar zxvfp opm-linux.tar.gz -C /usr/local/bin/
     # tar zxvfp grpcurl_1.8.1_linux_x86_64.tar.gz -C /usr/local/bin
     
     # yum -y install podman  skopeo wget 
     # yum -y install python3 sqlite3 vim jq
     
     # pip3 install pyyaml
     # pip3 install jinja2
     # pip3 install library
     ```

     - 사용할 이미지 registry login (registry.redhat.io, mirror 대상 registry)

       ```
       # podman login registry.redhat.io
       Username: ${USERNAME}
       Password: ${PASSWORD}
       Login Succeeded!
       
       # podman login registry.dis.ocp4.test.fu.igotit.co.kr
       Username: ${USERNAME}
       Password: ${PASSWORD}
       Login Succeeded!
       ```

       or

       Cloud.redhat.com에서. pull-secert을 다운 받아 사용 

     - Operator에 대한 인덱스 확인 

       - Source Index Image를 실행

         ```
          podman run -p 50051:50051 \
             -it registry.redhat.io/redhat/redhat-operator-index:v4.6
         ```

       - 컨테이너를 구동한 터미널 이외 별도의 터미널을 연결하여 실행 

         ```
         grpcurl -plaintext localhost:50051 api.Registry/ListPackages > packages.out
         ```

         ```
          
         cat packages.out
         {
           "name": "3scale-operator"
         }
         {
           "name": "advanced-cluster-management"
         } {
           "name": "amq-broker"
         }
         {
           "name": "amq-broker-lts"
         } {
           "name": "amq-online"
         }
         {
           "name": "amq-streams"
         }
         ....
         ```

       - 지정한 패키지 외의 인덱스는 정리 

         ```
         opm index prune -f registry.redhat.io/redhat/redhat-operator-index:v4.6 \
                         -p 3scale-operator,apicast-operator \
                         -t registry.dis.ocp4.test.fu.igotit.co.kr/olm/redhat-operator-index:v4.6
         ```

       - index image push 

         ```
         podman push registry.dis.ocp4.test.fu.igotit.co.kr/olm/redhat-operator-index:v4.6
         ```

         

   - Mirroring an Operator catalog

     ```
     oc adm catalog mirror -a /root/pull-secret-2.json \
     registry.dis.ocp4.test.fu.igotit.co.kr/olm/redhat-operator-index:v4.6 \
     registry.dis.ocp4.test.fu.igotit.co.kr --filter-by-os=linux/amd64 --insecure --manifests-only
     ```

​       다음과 같이 ${HOME}/redhat-operator-index-manifests-<random_number> 가 생성된 것이 확인되며

​       mapping.txt 내용에서 제대로 내 로컬 레지스트리 주소로 되어 있는지 확인합니다.

       ```
        --- 생략 ---
       registry.redhat.io/3scale-amp2/backend-rhel7@sha256:48b8b101be540bcd06c3d5672bcbc07da12333916ac2ed5a93ccc3c077da9195=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/backend-rhel7:7df778cc
       registry.redhat.io/3scale-amp2/system-rhel7@sha256:75d50fa5006e10574670507beb290992da992ec3dbfb1a55013894432bf94150=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/system-rhel7:93c46782
       registry.redhat.io/rhscl/postgresql-10-rhel7@sha256:de3ab628b403dc5eed986a7f392c34687bddafee7bdfccfd65cecf137ade3dfd=registry.dis.ocp4.test.fu.igotit.co.kr/rhscl/postgresql-10-rhel7:49ca41ba
       registry.redhat.io/rhscl/mysql-57-rhel7@sha256:9a781abe7581cc141e14a7e404ec34125b3e89c008b14f4e7b41e094fd3049fe=registry.dis.ocp4.test.fu.igotit.co.kr/rhscl/mysql-57-rhel7:4d9bc7b7
       registry.redhat.io/openshift4/ose-cli@sha256:353036a27e810730ce35d699dcf09141af9f8ae9e365116755016d864475c2c4=registry.dis.ocp4.test.fu.igotit.co.kr/openshift4/ose-cli:2c06d0a1
       --- 생략 ---
       ```



- Creating a catalog from an index image

  생성된 mapping.txt를 이용하여 미러링 (선택한 패키지 전체 버전으로 미러함)

  ```
  oc image mirror -a /root/pull-secret-2.json -f /root/redhat-operator-index-
  manifests/mapping.txt --insecure --filter-by-os=linux/amd64
  ```



   - Creating a catalog from an index image (일부 버전)

      registry.dis.ocp4.test.fu.igotit.co.kr/olm/redhat-operator-index:v4.6 이미지 내에 있는 database를 조회하여 

     필요한 이미지를 확인 후 미러링 함

     ```
     podman run registry.dis.ocp4.test.fu.igotit.co.kr/olm/redhat-operator-index:v4.6
     time="2021-07-12T12:32:03Z" level=info msg="Keeping server open for infinite seconds" database=/database/index.db port=50051
     time="2021-07-12T12:32:03Z" level=info msg="serving registry" database=/database/index.db port=50051
     ```

     index.db 복사 

     ```
     # podman ps 
     CONTAINER ID  IMAGE                                                 COMMAND               CREATED         STATUS             PORTS                     NAMES
     95005f26f103  docker.io/library/registry:2                          /etc/docker/regis...  47 minutes ago  Up 47 minutes ago  0.0.0.0:5000->5000/tcp    mirror-registry
     04a18dcaa59c  registry.redhat.io/redhat/redhat-operator-index:v4.6  registry serve --...  26 minutes ago  Up 26 minutes ago  0.0.0.0:50051->50051/tcp  xenodochial_shaw
     
     # podman cp 04a18dcaa59c:/database/index.db ./
     ```

     복사한 db를 이용한 채널 확인 

     ```
     # sqlite index.db
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
     ```

     

      복사한 db를 이용하여 이미지 리스트 작성 

     ```
     # for sha in $(echo "select bundlepath from operatorbundle where name like '%3scale-operator.v0.7.0%';" | sqlite3 -line index.db | grep sha256 | cut -d ":" -f2); do grep $sha mapping.txt > custom-mapping.txt ; done
     # for sha in $(echo "select * from related_image where operatorbundle_name like '3scale-operator.v0.7.0';" | sqlite3 -line index.db | grep sha256 | cut -d ":" -f2); do grep $sha mapping.txt >> custom-mapping.txt ; done
     # for sha in $(echo "select bundlepath from operatorbundle where name like '%apicast-operator.v0.4.0%';" | sqlite3 -line index.db | grep sha256 | cut -d ":" -f2); do grep $sha mapping.txt >> custom-mapping.txt ; done
     # for sha in $(echo "select * from related_image where operatorbundle_name like 'apicast-operator.v0.4.0';" | sqlite3 -line index.db | grep sha256 | cut -d ":" -f2); do grep $sha mapping.txt >> custom-mapping.txt ; done
     # for sha in $(echo "select bundlepath from operatorbundle where name like '%3scale-operator.v0.6.1%';" | sqlite3 -line index.db | grep sha256 | cut -d ":" -f2); do grep $sha mapping.txt >> custom-mapping.txt ; done
     # for sha in $(echo "select * from related_image where operatorbundle_name like '3scale-operator.v0.6.1';" | sqlite3 -line index.db | grep sha256 | cut -d ":" -f2); do grep $sha mapping.txt >> custom-mapping.txt ; done
     # for sha in $(echo "select bundlepath from operatorbundle where name like '%apicast-operator.v0.3.1%';" | sqlite3 -line index.db | grep sha256 | cut -d ":" -f2); do grep $sha mapping.txt >> custom-mapping.txt ; done
     # for sha in $(echo "select * from related_image where operatorbundle_name like 'apicast-operator.v0.3.1';" | sqlite3 -line index.db | grep sha256 | cut -d ":" -f2); do grep $sha mapping.txt >> custom-mapping.txt ; done
     # for sha in $(echo "select bundlepath from operatorbundle where name like '%3scale-operator.v0.6.0%';" | sqlite3 -line index.db | grep sha256 | cut -d ":" -f2); do grep $sha mapping.txt >> custom-mapping.txt ; done
     # for sha in $(echo "select * from related_image where operatorbundle_name like '3scale-operator.v0.6.0';" | sqlite3 -line index.db | grep sha256 | cut -d ":" -f2); do grep $sha mapping.txt >> custom-mapping.txt ; done
     # for sha in $(echo "select bundlepath from operatorbundle where name like '%apicast-operator.v0.3.0%';" | sqlite3 -line index.db | grep sha256 | cut -d ":" -f2); do grep $sha mapping.txt >> custom-mapping.txt ; done
     # for sha in $(echo "select * from related_image where operatorbundle_name like 'apicast-operator.v0.3.0';" | sqlite3 -line index.db | grep sha256 | cut -d ":" -f2); do grep $sha mapping.txt >> custom-mapping.txt ; done
     
     cat  custom-mapping.txt | sort | uniq > custom-mapping-final.txt
     ```

     ```
     registry.redhat.io/3scale-amp2/3scale-rhel7-operator-metadata@sha256:996c4b5c28ba35b640f2ccf12f49a477bdd65e69c3741f0253c850aaf14f0176=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/3scale-rhel7-operator-metadata:fbfbe873
     registry.redhat.io/3scale-amp2/3scale-rhel7-operator-metadata@sha256:d3f06246be00c7a0e8474eee22791a9b0fcd64863bcd45a19d84e5dc88bc075a=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/3scale-rhel7-operator-metadata:7c1bb4b1
     registry.redhat.io/3scale-amp2/3scale-rhel7-operator-metadata@sha256:f698cf1102a1847cba810f5be68c264223a37f6424c3e4902465111b5b74d496=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/3scale-rhel7-operator-metadata:56c6dffc
     registry.redhat.io/3scale-amp2/3scale-rhel7-operator@sha256:5a8ecc0933b6e7d0faf3d6f84e3b7fd287ee52849231e2870f7376ba96fe603c=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/3scale-rhel7-operator:b3929408
     registry.redhat.io/3scale-amp2/3scale-rhel7-operator@sha256:655062177bc53b155b87876dc1096530c365f18f9be3ceb0d32aa2d343968f9a=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/3scale-rhel7-operator:707dda79
     registry.redhat.io/3scale-amp2/3scale-rhel7-operator@sha256:6aaac50f48cb3e0461c28a7e0305bbd1cd00150772fd835f4e00fbfdcd5520d6=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/3scale-rhel7-operator:7bd518d5
     registry.redhat.io/3scale-amp2/apicast-gateway-rhel8@sha256:479b4fe71b59333733eb4e12e68724cf20d6fd16e1eb34214ace5cc43effb81c=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/apicast-gateway-rhel8:2fd88a2c
     registry.redhat.io/3scale-amp2/apicast-gateway-rhel8@sha256:59d53166fd14e52a5da46e215fbe731796accfd6b98efdbd093ee45604e8e0a9=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/apicast-gateway-rhel8:87ac0051
     registry.redhat.io/3scale-amp2/apicast-gateway-rhel8@sha256:a3a841ce413b2e050fe44a30f3b3fd82256d91e0daa81f13ecd40f97a95e68ab=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/apicast-gateway-rhel8:22a2e5a6
     registry.redhat.io/3scale-amp2/apicast-rhel7-operator-metadata@sha256:65447df0f16603ea021eaae880865ccfcb4449aab6fc2fd519da554c46987e84=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/apicast-rhel7-operator-metadata:f0fcd7b3
     registry.redhat.io/3scale-amp2/apicast-rhel7-operator-metadata@sha256:da8930f0d4a627f323166fe8506f0a31e67c96cf258c548acc1cc60b461adc7f=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/apicast-rhel7-operator-metadata:c958d179
     registry.redhat.io/3scale-amp2/apicast-rhel7-operator-metadata@sha256:f66685c272d98de6e5c32f4090fc4dc84f0c94fa05a233b4f7737a31d478b983=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/apicast-rhel7-operator-metadata:8ba4ab07
     registry.redhat.io/3scale-amp2/apicast-rhel7-operator@sha256:45d0318ce73d19a016fed8a5af0b16a5f423b423b57b515c7d3de70daadfe33b=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/apicast-rhel7-operator:f1c0ba71
     registry.redhat.io/3scale-amp2/apicast-rhel7-operator@sha256:ef5c4e42d2ce962a21ff0c61f500c6dd672d07ff7f4bfce039ca6851a0fcbef0=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/apicast-rhel7-operator:17d2347
     registry.redhat.io/3scale-amp2/apicast-rhel7-operator@sha256:f78be20adbfd93be9a5cfe49ebfffbed53f73d6c0588419d89b5230ffac3bad4=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/apicast-rhel7-operator:f1e163a5
     registry.redhat.io/3scale-amp2/backend-rhel7@sha256:48b8b101be540bcd06c3d5672bcbc07da12333916ac2ed5a93ccc3c077da9195=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/backend-rhel7:7df778cc
     registry.redhat.io/3scale-amp2/backend-rhel7@sha256:b5975297fb2bc871e2010619308d4eb59744fde96176a5611303222c326576ac=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/backend-rhel7:f9a7cd0c
     registry.redhat.io/3scale-amp2/backend-rhel7@sha256:b6db56f338d02fed95d439e0f1a88b3590de359bffdddeceb954ce5f46fda8df=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/backend-rhel7:d3e02baf
     registry.redhat.io/3scale-amp2/memcached-rhel7@sha256:2ab37b3fd0249c4c0f372dddd2210f0a004fbae1c3398350ef4bbeefc3032aa0=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/memcached-rhel7:39b24811
     registry.redhat.io/3scale-amp2/memcached-rhel7@sha256:33a333cd8ae8d1d39aa297ba61c5bdbb4f8f3ada63e84196e5d2187ec63480be=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/memcached-rhel7:68ce39ac
     registry.redhat.io/3scale-amp2/memcached-rhel7@sha256:c04749ad063f9b91de8c883ead964993f5d3e42c074569b116b78c6e2c741c6a=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/memcached-rhel7:7840929f
     registry.redhat.io/3scale-amp2/system-rhel7@sha256:431f5d4cc9f27b39f23f34d2b6748e50c2291f5de473c0f45780549ac94fbacf=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/system-rhel7:4f48d406
     registry.redhat.io/3scale-amp2/system-rhel7@sha256:75d50fa5006e10574670507beb290992da992ec3dbfb1a55013894432bf94150=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/system-rhel7:93c46782
     registry.redhat.io/3scale-amp2/system-rhel7@sha256:fa5e04c1ef2139aa728ef3197ca8ed27361350dc28c0713f8906f67f255448bc=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/system-rhel7:8eefc402
     registry.redhat.io/3scale-amp2/zync-rhel7@sha256:04add0c1e4ceaa3628939ed1e72dcc70b90ae669c831f2e9782f895959b371ed=registry.dis.test.fu.igotit.co.kr:5000/3scale-amp2/zync-rhel7:dcfbe1fe
     registry.redhat.io/3scale-amp2/zync-rhel7@sha256:7aa6069c3c885b4602a877120ea9c3be7fc237201f1d0c29dd0dff96fba21e0e=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/zync-rhel7:936dce87
     registry.redhat.io/3scale-amp2/zync-rhel7@sha256:f92c261bd19303f40eea135543b890ed805c058ede2b5cb520714273023a528d=registry.dis.ocp4.test.fu.igotit.co.kr/3scale-amp2/zync-rhel7:feb5cc3e
     registry.redhat.io/openshift4/ose-cli@sha256:353036a27e810730ce35d699dcf09141af9f8ae9e365116755016d864475c2c4=registry.dis.ocp4.test.fu.igotit.co.kr/openshift4/ose-cli:2c06d0a1
     registry.redhat.io/rhscl/mysql-57-rhel7@sha256:9a781abe7581cc141e14a7e404ec34125b3e89c008b14f4e7b41e094fd3049fe=registry.dis.ocp4.test.fu.igotit.co.kr/rhscl/mysql-57-rhel7:4d9bc7b7
     registry.redhat.io/rhscl/postgresql-10-rhel7@sha256:de3ab628b403dc5eed986a7f392c34687bddafee7bdfccfd65cecf137ade3dfd=registry.dis.ocp4.test.fu.igotit.co.kr/rhscl/postgresql-10-rhel7:49ca41ba
     registry.redhat.io/rhscl/redis-32-rhel7@sha256:a9bdf52384a222635efc0284db47d12fbde8c3d0fcb66517ba8eefad1d4e9dc9=registry.dis.ocp4.test.fu.igotit.co.kr/rhscl/redis-32-rhel7:b5c56c9a
     ```



​        추가로 필요한 이미지

```
registry.redhat.io/3scale-amp26/3scale-operator:latest=registry.ocp4.home.igotit.co.kr:5000/3scale-amp26/3scale-operator:latest

registry.redhat.io/rhscl/redis-5-rhel7@sha256:8cfa1d94f5a4e00689ed9585bbdf22c3503e47829cff37d51c90cf3a028c679c=registry.dis.ocp4.test.fu.igotit.co.kr/rhscl/redis-5-rhel7
```



- Creating a catalog from an index image

```
oc image mirror -a /root/pull-secret-2.json -f /root/redhat-operator-index-
manifests/custom-mapping-final.txt --insecure --filter-by-os=linux/amd64
```



-  Index Image와 Operator 

  ```
  tar zcvf ./operator.tar /opt/operator/data
  ```

  

- operator. 추가 

  ```
  Ex> imageContentSourcePolicy.yaml
  apiVersion: operator.openshift.io/v1alpha1
  kind: ImageContentSourcePolicy
  metadata:
    name: redhat-operator-index
  spec:
    repositoryDigestMirrors:
    - mirrors:
      - registry.dis.ocp4.test.fu.igotit.co.kr/rhscl-redis-32-rhel7
      source: registry.redhat.io/rhscl/redis-32-rhel7
  ...
  Ex> catalogSource.yaml
  apiVersion: operators.coreos.com/v1alpha1
  kind: CatalogSource
  metadata:
    name: redhat-operator-index
    namespace: openshift-marketplace
  spec:
    image: registry.dis.ocp4.test.fu.igotit.co.kr/openshift4-redhat-operator-
  index:v4.6
    sourceType: grpc
    displayName: My Operator Catalog
    publisher: RedHat
    
    
  ```

  