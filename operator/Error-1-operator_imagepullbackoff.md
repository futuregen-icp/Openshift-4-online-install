## 이슈
```
[root@lab1-bastion containers]# oc get pods -n openshift-marketplace
NAME                                    READY   STATUS             RESTARTS   AGE
marketplace-operator-779d46b7c4-5zrfd   1/1     Running            0          24h
my-operator-catalog-fhbg8               0/1     ImagePullBackOff   0          16h
```

## 체크사항


```
[root@lab1-bastion containers]# oc describe pod my-operator-catalog-fhbg8 
Name:         my-operator-catalog-fhbg8
Namespace:    openshift-marketplace
Priority:     0
Node:         efk1.oss2.fu.igotit.co.kr/192.168.5.161
Start Time:   Wed, 15 Dec 2021 03:39:50 -0500
Labels:       olm.catalogSource=my-operator-catalog
Annotations:  k8s.v1.cni.cncf.io/network-status:
                [{
                    "name": "",
                    "interface": "eth0",
                    "ips": [
                        "10.130.4.7"
                    ],
                    "default": true,
                    "dns": {}
                }]
              k8s.v1.cni.cncf.io/networks-status:
                [{
                    "name": "",
                    "interface": "eth0",
                    "ips": [
                        "10.130.4.7"
                    ],
                    "default": true,
                    "dns": {}
                }]
              openshift.io/scc: anyuid
Status:       Pending
IP:           10.130.4.7
IPs:
  IP:  10.130.4.7
Containers:
  registry-server:
    Container ID:   
    Image:          registry.oss2.fu.igotit.co.kr:5000/olm/redhat-operators:v1
    Image ID:       
    Port:           50051/TCP
    Host Port:      0/TCP
    State:          Waiting
      Reason:       ImagePullBackOff
    Ready:          False
    Restart Count:  0
    Requests:
      cpu:        10m
      memory:     50Mi
    Liveness:     exec [grpc_health_probe -addr=:50051] delay=10s timeout=1s period=10s #success=1 #failure=3
    Readiness:    exec [grpc_health_probe -addr=:50051] delay=5s timeout=5s period=10s #success=1 #failure=3
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-r4bl7 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
Volumes:
  default-token-r4bl7:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-r4bl7
    Optional:    false
QoS Class:       Burstable
Node-Selectors:  kubernetes.io/os=linux
Tolerations:     node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                 node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason   Age                     From     Message
  ----     ------   ----                    ----     -------
  Normal   Pulling  94m (x174 over 15h)     kubelet  Pulling image "registry.oss2.fu.igotit.co.kr:5000/olm/redhat-operators:v1"
  Normal   BackOff  9m6s (x4208 over 15h)   kubelet  Back-off pulling image "registry.oss2.fu.igotit.co.kr:5000/olm/redhat-operators:v1"
  Warning  Failed   4m14s (x4230 over 15h)  kubelet  Error: ImagePullBackOff
```

마스터 노드에서 이미지 풀을 해보기
```
[root@master1 core]# crictl pull registry.oss2.fu.igotit.co.kr:5000/olm/redhat-operators:v1
FATA[0000] pulling image: rpc error: code = Unknown desc = Error reading manifest v1 in registry.oss2.fu.igotit.co.kr:5000/olm/redhat-operators: unauthorized: authentication required 
```
미리 레지스트리  신뢰된 레지스트리로 등록 여부 체크
```
$ oc patch image.config.openshift.io/cluster 
oc edit image.config.openshift.io/cluster
>> additionalTrustedCA: 
         name: registry-cas

$ oc create configmap registry-cas -n openshift-config \
--from-file=myregistry.corp.com..5000=/etc/docker/certs.d/myregistry.corp.com:5000/ca.crt \
--from-file=otherregistry.com=/etc/docker/certs.d/otherregistry.com/ca.crt

oc edit configmap registry-cas -n openshift-config
>> check certificate as registry.oss2.fu.igotit.co.kr..5000:

```
## 해결 
: 글로벌 클러스터 풀 시크릿 업데이트 (파드가 리스케줄링 되는 시점에 적용 됨)
```
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson=/opt/ocp4.6/pull/pull-secret-20211208.json
```

## Refer 
- https://access.redhat.com/solutions/5671401
- https://docs.openshift.com/container-platform/4.6/registry/configuring_registry_storage/configuring-registry-storage-baremetal.html #registry
- https://docs.openshift.com/container-platform/4.5/openshift_images/managing_images/using-image-pull-secrets.html # Update pull secret
