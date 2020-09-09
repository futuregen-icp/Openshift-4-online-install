# Route node config

## machine node config 

### route node select 

  worker02.ocp4.igotit.co.kr
  worker03.ocp4.igotit.co.kr

### append nodeselect
oc edit node < nodename >

```
  labels:
    beta.kubernetes.io/arch: amd64
    beta.kubernetes.io/os: linux
    kubernetes.io/arch: amd64
    kubernetes.io/hostname: worker02.ocp4.igotit.co.kr
    kubernetes.io/os: linux
    node-role.kubernetes.io/infra: ""
    node-role.kubernetes.io/route: ""  <-- append route node 
    node-role.kubernetes.io/worker: ""
```

## igress operator config 

### selected project

  oc project openshift-ingress-operator
  
### edit igress operator 

```
  oc edit IngressController 
  
...  
spec:
  nodePlacement:                                          <-- append nodeselect
    nodeSelector:                                         <-- append nodeselect
      matchLabels:                                        <-- append nodeselect
        node-role.kubernetes.io/route: ""                 <-- append nodeselect
  replicas: 2
...
```

## 

### before 

```
[core@bastion ingress]$ oc get pod -A -o wide| grep  route
openshift-ingress                                  router-default-585b68dccd-5fgxs                                   1/1     Running        0          2d20h   192.168.1.172   worker02.ocp4.igotit.co.kr   <none>           <none>
openshift-ingress                                  router-default-585b68dccd-l57nx                                   1/1     Running        0          65s     192.168.1.171   worker01.ocp4.igotit.co.kr   <none>           <none> 
```

### after 

```[core@bastion ingress]$ oc get pod -A -o wide| grep  route
openshift-ingress                                  router-default-55d5dc74bb-jg4x6                                   0/1     Pending        0          1s      <none>
    <none>                       <none>           <none>
openshift-ingress                                  router-default-55d5dc74bb-x56fp                                   1/1     Running        0          17s     192.168.1.172   worker02.ocp4.igotit.co.kr   <none>           <none>
openshift-ingress                                  router-default-585b68dccd-cvpjz                                   1/1     Terminating    0          5m32s   192.168.1.173   worker03.ocp4.igotit.co.kr   <none>           <none>
openshift-ingress                                  router-default-585b68dccd-znvq9                                   1/1     Terminating    0          5m32s   192.168.1.171   worker01.ocp4.igotit.co.kr   <none>           <none>
```

```
[core@bastion ingress]$ oc get pod -A -o wide| grep  route
openshift-ingress                                  router-default-55d5dc74bb-jg4x6                                   1/1     Running        0          16m     192.168.1.173   worker03.ocp4.igotit.co.kr   <none>           <none>
openshift-ingress                                  router-default-55d5dc74bb-x56fp                                   1/1     Running        0          17m     192.168.1.172   worker02.ocp4.igotit.co.kr   <none>           <none>
```
