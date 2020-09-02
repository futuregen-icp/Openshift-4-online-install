# L4 DSR 설정을 위해 loopback 설정을 위한 테스트 


## 0. machin config를 사용하기 위해 machin config pool 생성 

현재 노드 구성 
|NAME                        | STATUS  |  ROLES              | AGE   | VERSION        | OS    |
|----------------------------|---------|---------------------|-------|----------------|-------|
|master01.ocp4.igotit.co.kr  | Ready   | master              | 78d   | v1.18.3+002a51f| rhcos |
|master02.ocp4.igotit.co.kr  | Ready   | master              | 78d   | v1.18.3+002a51f| rhcos |
|master03.ocp4.igotit.co.kr  | Ready   | master              | 78d   | v1.18.3+002a51f| rhcos |
|worker01.ocp4.igotit.co.kr  | Ready   | infra,worker        | 78d   | v1.18.3+002a51f| rhcos |
|worker02.ocp4.igotit.co.kr  | Ready   | infra,worker        | 78d   | v1.18.3+002a51f| rhcos |
|worker03.ocp4.igotit.co.kr  | Ready   | infra,route,worker  | 78d   | v1.18.3+002a51f| rhcos |
|worker04.ocp4.igotit.co.kr  | Ready   | route,worker        | 142m  | v1.18.3+2cf11e2| rhel  |


```
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfigPool
metadata:
  name: route
spec:
  machineConfigSelector:
    matchExpressions:
      - {key: machineconfiguration.openshift.io/role, operator: In, values: [worker,route]}
  nodeSelector:
    matchLabels:
      node-role.kubernetes.io/route: ""
  paused: false
```

## 1. /etc/sysconfig/network-script/ifcfg-lo:0 생성 
> 결론부터 이야기 하자면 <br>
> rhel node는 정상 동작 하지만 coreos node는 정상동작 하지 않음 



## 2. system service 생성 (test 중 )
