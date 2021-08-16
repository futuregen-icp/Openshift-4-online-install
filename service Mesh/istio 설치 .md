##  Redhat service mesh (istio)



### 사전 준비

1. Is too-system namespace 를 만들어 둔다
2. 작업을 위한 

### install 방법 

1. Elasticsearch (ECK) Operator install 
2. Red Hat OpenShift Jaeger
3. Kiali Operator
4. Red Hat OpenShift Service Mesh

### operator  설정 

**oc  apply -f ServiceMeshControlPlane.yaml -n istio-system**

```
apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: basic
  namespace: istio-system
spec:
  addons:
    grafana:
      enabled: true
    jaeger:
      install:
        storage:
          type: Memory
    kiali:
      enabled: true
    prometheus:
      enabled: true
  policy:
    type: Istiod
  profiles:
    - default
  telemetry:
    type: Istiod
  tracing:
    sampling: 10000
    type: Jaeger
  version: v2.0
```

위의 yaml file 적용후 드 생성 됨

```
[root@bastion ~]# oc get all -n istio-system
NAME                                        READY   STATUS    RESTARTS   AGE
pod/grafana-654b574f95-99cqc                2/2     Running   0          6h53m
pod/istio-egressgateway-64fb88f5cd-jf9tk    1/1     Running   0          6h53m
pod/istio-ingressgateway-5c7fccdf87-9dxls   1/1     Running   0          6h53m
pod/istiod-basic-6678fbb9b4-dv6cn           1/1     Running   0          6h54m
pod/jaeger-84fc5b99bc-ddktm                 2/2     Running   0          6h54m
pod/kiali-b4b67b965-8x9tt                   1/1     Running   0          6h50m
pod/prometheus-7d6484b755-nzxj4             3/3     Running   0          6h54m

NAME                                TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                                         AGE
service/grafana                     ClusterIP   172.30.40.247    <none>        3000/TCP                                        6h53m
service/istio-egressgateway         ClusterIP   172.30.153.185   <none>        80/TCP,443/TCP,15443/TCP                        6h53m
service/istio-ingressgateway        ClusterIP   172.30.77.158    <none>        15021/TCP,80/TCP,443/TCP,15443/TCP              6h54m
service/istiod-basic                ClusterIP   172.30.230.227   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP,853/TCP   6h54m
service/jaeger-agent                ClusterIP   None             <none>        5775/UDP,5778/TCP,6831/UDP,6832/UDP             6h54m
service/jaeger-collector            ClusterIP   172.30.43.218    <none>        9411/TCP,14250/TCP,14267/TCP,14268/TCP          6h54m
service/jaeger-collector-headless   ClusterIP   None             <none>        9411/TCP,14250/TCP,14267/TCP,14268/TCP          6h54m
service/jaeger-query                ClusterIP   172.30.45.86     <none>        443/TCP                                         6h54m
service/kiali                       ClusterIP   172.30.177.10    <none>        20001/TCP,9090/TCP                              6h52m
service/prometheus                  ClusterIP   172.30.122.92    <none>        9090/TCP                                        6h54m
service/zipkin                      ClusterIP   172.30.221.231   <none>        9411/TCP                                        6h54m

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/grafana                1/1     1            1           6h53m
deployment.apps/istio-egressgateway    1/1     1            1           6h53m
deployment.apps/istio-ingressgateway   1/1     1            1           6h54m
deployment.apps/istiod-basic           1/1     1            1           6h54m
deployment.apps/jaeger                 1/1     1            1           6h54m
deployment.apps/kiali                  1/1     1            1           6h52m
deployment.apps/prometheus             1/1     1            1           6h54m

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/grafana-654b574f95                1         1         1       6h53m
replicaset.apps/istio-egressgateway-64fb88f5cd    1         1         1       6h53m
replicaset.apps/istio-ingressgateway-5c7fccdf87   1         1         1       6h54m
replicaset.apps/istiod-basic-6678fbb9b4           1         1         1       6h54m
replicaset.apps/jaeger-84fc5b99bc                 1         1         1       6h54m
replicaset.apps/kiali-8695d8f986                  0         0         0       6h52m
replicaset.apps/kiali-b4b67b965                   1         1         1       6h50m
replicaset.apps/prometheus-7d6484b755             1         1         1       6h54m

NAME                                                 HOST/PORT                                                          PATH   SERVICES               PORT    TERMINATION          WILDCARD
route.route.openshift.io/grafana                     grafana-istio-system.apps.ocp4.test.fu.igotit.co.kr                       grafana                <all>   reencrypt/Redirect   None
route.route.openshift.io/istio-ingressgateway        istio-ingressgateway-istio-system.apps.ocp4.test.fu.igotit.co.kr          istio-ingressgateway   8080                         None
route.route.openshift.io/jaeger                      jaeger-istio-system.apps.ocp4.test.fu.igotit.co.kr                        jaeger-query           <all>   reencrypt            None
route.route.openshift.io/kb-kb-gw-ae0bdd80a690256d   kbtest.ocp4.test.fu.igotit.co.kr                                          istio-ingressgateway   http2                        None
route.route.openshift.io/kiali                       kiali-istio-system.apps.ocp4.test.fu.igotit.co.kr                         kiali                  <all>   reencrypt/Redirect   None
route.route.openshift.io/prometheus                  prometheus-istio-system.apps.ocp4.test.fu.igotit.co.kr                    prometheus             <all>   reencrypt/Redirect   None
```



**oc  apply -f ServiceMeshMemberRoll,yaml -n istio-system**

```
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  generation: 1
  namespace: istio-system
spec:
  members:
    - kb
    - test-pv

```



### 구성을 위한 프로젝트에서 설정 

**프로젝트 설정** 

```
kind: Project
apiVersion: project.openshift.io/v1
metadata:
  name: kb
  selfLink: /apis/project.openshift.io/v1/projects/kb
  uid: 889bbfb3-f950-402f-9c07-8f85b9a77587
  resourceVersion: '41702970'
  creationTimestamp: '2021-08-13T07:47:43Z'
  labels:
    istio-injection: enabled
    kiali.io/member-of: istio-system
    maistra.io/member-of: istio-system
  annotations:
    openshift.io/sa.scc.mcs: 's0:c27,c4'
    openshift.io/sa.scc.supplemental-groups: 1000710000/10000
    openshift.io/sa.scc.uid-range: 1000710000/10000
  managedFields:
    - manager: Mozilla
      operation: Update
      apiVersion: v1
      time: '2021-08-13T07:47:43Z'
      fieldsType: FieldsV1
      fieldsV1:
        'f:status':
          'f:phase': {}
    - manager: cluster-policy-controller
      operation: Update
      apiVersion: v1
      time: '2021-08-13T07:47:43Z'
      fieldsType: FieldsV1
      fieldsV1:
        'f:metadata':
          'f:annotations':
            .: {}
            'f:openshift.io/sa.scc.mcs': {}
            'f:openshift.io/sa.scc.supplemental-groups': {}
            'f:openshift.io/sa.scc.uid-range': {}
    - manager: istio-operator
      operation: Update
      apiVersion: v1
      time: '2021-08-13T08:06:26Z'
      fieldsType: FieldsV1
      fieldsV1:
        'f:metadata':
          'f:labels':
            .: {}
            'f:maistra.io/member-of': {}
    - manager: OpenAPI-Generator
      operation: Update
      apiVersion: v1
      time: '2021-08-13T08:06:54Z'
      fieldsType: FieldsV1
      fieldsV1:
        'f:metadata':
          'f:labels':
            'f:kiali.io/member-of': {}
    - manager: kiali
      operation: Update
      apiVersion: v1
      time: '2021-08-13T08:16:15Z'
      fieldsType: FieldsV1
      fieldsV1:
        'f:metadata':
          'f:labels':
            'f:istio-injection': {}
spec:
  finalizers:
    - kubernetes
status:
  phase: Active

```

label 에  "istio-injection: enabled" 내용 추가 



**deployment 생성** 

```
oc create deployment web1 --image=gcr.io/google-samples/hello-app:1.0 -n kb
oc create deployment web2 --image=gcr.io/google-samples/hello-app:1.0 -n kb
oc create deployment web3 --image=gcr.io/google-samples/hello-app:1.0 -n kb
oc create deployment web4 --image=gcr.io/google-samples/hello-app:1.0 -n kb
oc expose deployment web1 --type=ClusterIP --port=8080  -n kb
oc expose deployment web2 --type=ClusterIP --port=8080  -n kb
oc expose deployment web3 --type=ClusterIP --port=8080  -n kb
oc expose deployment web4 --type=ClusterIP --port=8080  -n kb
```

```
[root@bastion ~]# oc get all
NAME                        READY   STATUS    RESTARTS   AGE
pod/web1-7856799799-xb4zf   1/1     Running   0          7h10m
pod/web2-5b669f8984-gbgq7   1/1     Running   0          7h5m
pod/web3-6b46755d5c-nm77m   1/1     Running   0          7h5m
pod/web4-644787954b-tdpqw   1/1     Running   0          7h5m

NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/web1   ClusterIP   172.30.224.253   <none>        8080/TCP   7h10m
service/web2   ClusterIP   172.30.89.197    <none>        8080/TCP   7h4m
service/web3   ClusterIP   172.30.54.148    <none>        8080/TCP   7h4m
service/web4   ClusterIP   172.30.48.168    <none>        8080/TCP   7h4m

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/web1   1/1     1            1           7h10m
deployment.apps/web2   1/1     1            1           7h5m
deployment.apps/web3   1/1     1            1           7h5m
deployment.apps/web4   1/1     1            1           7h5m

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/web1-7856799799   1         1         1       7h10m
replicaset.apps/web2-5b669f8984   1         1         1       7h5m
replicaset.apps/web3-6b46755d5c   1         1         1       7h5m
replicaset.apps/web4-644787954b   1         1         1       7h5m
```



**deployment에 sidecar 추가**

```
kind: Deployment
apiVersion: apps/v1
metadata:
  annotations:
    deployment.kubernetes.io/revision: '2'
  selfLink: /apis/apps/v1/namespaces/kb/deployments/web1
  resourceVersion: '41764796'
  name: web1
...
  namespace: kb
  labels:
    app: web1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web1
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: web1
      annotations:
        sidecar.istio.io/inject: 'true'
    spec:
      containers:
        - name: hello-app
          image: 'gcr.io/google-samples/hello-app:1.0'
          resources: {}
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
          imagePullPolicy: IfNotPresent
      restartPolicy: Always
...

```

      annotations:
        sidecar.istio.io/inject: 'true'

해당 부분 추가 



**gateway 추가**

oc apply -f Gateway.yaml -n kb

```
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: kb-gw
  namespaces: kb
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - kbtest.ocp4.test.fu.igotit.co.kr
```



**Virualservice 추가**

oc apply -f VirtualService.yaml -n kb

```
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: kb-vs
  namespaces: kb
spec:
  hosts:
  - kbtest.ocp4.test.fu.igotit.co.kr
  gateways:
  - kb-gw
  http:
  - match:
    - uri:
        prefix: /web1
    route:
    - destination:
        host: web1
  - match:
    - uri:
        prefix: /web2
    route:
    - destination:
        host: web2
  - match:
    - uri:
        prefix: /web3
    route:
    - destination:
        host: web3
  - match:
    - uri:
        prefix: /web4
    route:
    - destination:
        host: web4
```



### 확인 방법

```
curl kbtest.ocp4.test.fu.igotit.co.kr/web1
Hello, world!
Version: 1.0.0
Hostname: web1-7cd54f55dc-lfztl
```



```
curl kbtest.ocp4.test.fu.igotit.co.kr/web2
Hello, world!
Version: 1.0.0
Hostname: web2-7cd54f55dc-lfztl
```



```
curl kbtest.ocp4.test.fu.igotit.co.kr/web3
Hello, world!
Version: 1.0.0
Hostname: web3-7cd54f55dc-lfztl
```



```
curl kbtest.ocp4.test.fu.igotit.co.kr/web4
Hello, world!
Version: 1.0.0
Hostname: web4-7cd54f55dc-lfztl
```

