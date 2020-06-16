# using operator hub for ristricted network

요구사항
- A Linux workstation with unrestricted network access [1]
- oc version 4.3.5+
- podman version 1.4.4+
- Access to mirror registry that supports Docker v2-2

## Building an Operator catalog image
```
REG_CREDS=${XDG_RUNTIME_DIR}/containers/auth.json

 oc adm catalog build \
  -a ${REG_CREDS} \
  --appregistry-endpoint https://quay.io/cnr \
  --from=registry.redhat.io/openshift4/ose-operator-registry:v4.4 \
  --appregistry-org redhat-operators \
  --to=registry.openshift4.example.com/redhat-operators:v1
  ```
  
## Configuring OperatorHub for restricted networks

오퍼레이터 허브의 기능을 중지 

```
oc patch OperatorHub cluster --type json \
    -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]
```

oc adm catalog mirror
```
REG_CREDS=${XDG_RUNTIME_DIR}/containers/auth.json

 oc adm catalog mirror \
  -a ${LOCAL_SECRET_JSON} \
  registry.openshift4.example.com/redhat-operators:v1 \
  registry.openshift4.example.com
```


oc adm catalog mirror bug 인해 많은 문제가 발생하고 있어 skopeo copy --all 명령으로 다시 카피함.
```
***yum -y install buildah skopeo podman***

***[root@mirror01 operator]# skopeo copy --all docker://registry.redhat.io/openshift-service-mesh/kiali-rhel7@sha256:e1fb3df10a7f7862e8549ad29e4dad97b22719896c10fe5109cbfb3b98f56900 docker://registry.ocp4.metlife.ibm:5000/openshift-service-mesh/kiali-rhel7***
Getting image list signatures
Copying 1 of 1 images in list
Copying image sha256:325999de673a8bc0a9351ef7aa4a0529340598b6783c1d5fcf009fdfc82a7811 (1/1)
Getting image source signatures
Copying blob ec0a4551131f skipped: already exists
Copying blob b75510e9b72a skipped: already exists
Copying blob 448f7cafed66 skipped: already exists
Copying config f814d8906f done
Writing manifest to image destination
Storing signatures
Writing manifest list to image destination
Storing list signatures

***[root@mirror01 operator]# podman pull registry.ocp4.metlife.ibm:5000/openshift-service-mesh/kiali-rhel7***
Trying to pull registry.ocp4.metlife.ibm:5000/openshift-service-mesh/kiali-rhel7...
Getting image source signatures
Copying blob b75510e9b72a skipped: already exists
Copying blob ec0a4551131f [--------------------------------------] 0.0b / 0.0b
Copying blob 448f7cafed66 [--------------------------------------] 0.0b / 0.0b
Copying config f814d8906f done
Writing manifest to image destination
Storing signatures
f814d8906f9d7b0e10f3335a9c48d75e993f58ea358866fa9a93e842eb0cfa7a

***[root@mirror01 operator]# podman pull registry.ocp4.metlife.ibm:5000/openshift-service-mesh/kiali-rhel7:ec6a1539***
Trying to pull registry.ocp4.metlife.ibm:5000/openshift-service-mesh/kiali-rhel7:ec6a1539...
Getting image source signatures
Copying blob b75510e9b72a skipped: already exists
Copying blob ec0a4551131f skipped: already exists
Copying config f814d8906f done
Writing manifest to image destination
Storing signatures
f814d8906f9d7b0e10f3335a9c48d75e993f58ea358866fa9a93e842eb0cfa7a 
```
bug 추가 설명 url
```
https://www.cnblogs.com/ryanyangcs/p/13072268.html
```

Apply the manifests

```
cd /etc/docker/certs.d
oc apply -f ./redhat-operators-manifests
```

CatalogSource 정의

```
vi  catalogsource.yaml
kind: CatalogSource
metadata:
  name: my-operator-catalog
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: registry.ocp44.fu.com:5000/olm/redhat-operators:v1
  #image: <registry_host_name>:<port>/olm/redhat-operators:v1
  displayName: My Operator Catalog
  publisher: grpc
```
CatalogSource apply

```
oc create -f catalogsource.yaml
```

Verify the CatalogSource

```
# oc get pods -n openshift-marketplace
NAME READY STATUS RESTARTS AGE
my-operator-catalog-6njx6 1/1 Running 0 28s
marketplace-operator-d9f549946-96sgr 1/1 Running 0 26h

# oc get catalogsource -n openshift-marketplace
NAME DISPLAY TYPE PUBLISHER AGE
my-operator-catalog My Operator Catalog grpc 5s
```


error 정리
```
my-operator-catalog pod 에서 인증서로 인해 image pull 실패시  사용자 저의 registry의 인증서 복사 필요 함.
실패한 노에만 해당 됨
scp -r registry.ocp44.fu.com:/xxxxx/registry.ocp44.fu.com\:5000/{REGISTRY_HTTP_TLS_CERTIFICAT} worker01.ocp44.fu.com:/etc/containers/certs.d

podman login registry.ocp44.fu.com:5000 -u admin
```


