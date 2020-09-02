# Machine Config pool 에서 오류 발생하여 정상적인 설정 적용이 안되는 경우 
> 대부분이 사용자의 실수 이며 <br>
> 할당된 machine config를 잘못 지우는 경우 주로 발생한다.

## 복구 절자 

```
1. 삭제한 machineconfig 생성 
2. 강제적용 옵션 적용 
3. annotaion patch
4. node 확인 
```

### 1. 삭제한 machineconfig 생성

```
oc create -f $mc.yaml
```

### 2. 강제적용 옵션 적용 

```
## 작업노드에서 설정 
touch /run/machine-config-daemon-force
```

### 3. annotaion patch

```
## 현상태의 문제점은 reason에 기제되어 있음 
export node_name=worker03.ocp4.igotit.co.kr
export new_value=rendered-route-cd19bf025b9d12e2b69b85db63bbf4f8

oc patch node $node_name --type merge --patch '{"metadata": {"annotations": {"machineconfiguration.openshift.io/currentConfig": "$new_value"}}}'
oc patch node $node_name  --type merge --patch '{"metadata": {"annotations": {"machineconfiguration.openshift.io/desiredConfig": "$new_value"}}}'
oc patch node $node_name  --type merge --patch '{"metadata": {"annotations": {"machineconfiguration.openshift.io/reason": ""}}}'
oc patch node $node_name  --type merge --patch '{"metadata": {"annotations": {"machineconfiguration.openshift.io/state": "Done"}}}'
```

### 4. node 확인 

```
oc edit node/$node 
Annotations:        
                    machineconfiguration.openshift.io/currentConfig: rendered-worker-36f40ba3c1038c7ce5ce54f8a840a58f
                    machineconfiguration.openshift.io/desiredConfig: rendered-worker-36f40ba3c1038c7ce5ce54f8a840a58f
                    machineconfiguration.openshift.io/reason: 
                    machineconfiguration.openshift.io/state: Done
```                    

