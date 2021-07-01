#  disconnected custom operator hub 구성 하기 



## 전체 operator 구성  

### catalog build

```
oc adm catalog build --appregistry-org redhat-operators \
--from=registry.redhat.io/openshift4/ose-operator-registry:v4.6 \
--to=registry.dis.test.fu.igotit.co.kr:5000/olm/redhat-operators:v1 \
--insecure -a /root/.docker/config.json
```



### catalog mirror

```
oc adm catalog mirror registry.dis.test.fu.igotit.co.kr:5000/olm/redhat-operators:v1 \
registry.dis.test.fu.igotit.co.kr:5000 -a /root/.docker/config.json
```

```
manifests-redhat-operators-xxxxxxxx 디렉토리 생성됨 
cd manifests-redhat-operators-xxxxxxxx

아래의 파일이 존재함 
catalogSource.yaml              # custum operator hub 
imageContentSourcePolicy.yaml   # image에 대한 정책 
mapper.txt                      # 매핑 정보 
```



### operator. 구성 

```
oc apply -f imageContentSourcePolicy.yaml
oc apply -f catalogSource.yaml  
```



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





### https://github.com/arvin-a/openshift-disconnected-operators.git 이용하여 구성 

소스 가져오기 

```
git clone https://github.com/arvin-a/openshift-disconnected-operators.git
cd openshift-disconnected-operators
```

미러링할 오퍼레이터 설정

```
vi offline_operators_list
3scale-operator
apicast-operator
```

 필요한 이미지 pulling

```
podman pull quay.io/openshift/origin-operator-registry:4.6
podman tag quay.io/openshift/origin-operator-registry:4.6 quay.io/openshift/origin-operator-registry:latest
```

미러링 

```
python3 mirror-operator-catalogue.py --catalog-version 1.0.0 \
 --registry-olm registry.dis.test.fu.igotit.co.kr:5000 \
 --registry-catalog registry.dis.test.fu.igotit.co.kr:5000 --operator-file ./offline_operators_list \
--icsp-scope=namespace --authfile /root/.docker/config.json
```

추가적으로 필요한 이미지 미러링 

```
## additional request 
oc image mirror -a /root/.docker/config.json registry.redhat.io/rhscl/redis-5-rhel7@sha256:8cfa1d94f5a4e00689ed9585bbdf22c3503e47829cff37d51c90cf3a028c679c=registry.dis.test.fu.igotit.co.kr:5000/rhscl/redis-5-rhel7
```

operator hub.구성 

```
cd publish
oc apply -f olm-icsp.yaml           # image에 대한 정책 
oc apply -f rh-catalog-source.yaml  # custum operator hub
```

