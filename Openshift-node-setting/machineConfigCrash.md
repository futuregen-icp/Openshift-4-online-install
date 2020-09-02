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

### 진단 방법 
** machine config operater 정보 수집 **

```
# oc describe clusteroperator machine-config
# oc describe machineconfig -n openshift-machine-config-operator
# oc get machineconfigpool -n openshift-machine-config-operator
# oc describe machineconfigpool the-failing-pool -n openshift-machine-config-operator
# oc describe node
```

** 로그 수짐 **

```
# for POD in $(oc get po -l k8s-app=machine-config-daemon -o name | awk -F '/' '{print $2 }'); do oc logs $POD > $POD.log; done

namespaces/openshift-machine-config-operator/pods/machine-config-daemon-lrcsq/machine-config-daemon/machine-config-daemon/logs/current.log:2020-04-06T21:09:14.588375761-04:00 E0407 01:09:14.588272 3997140 writer.go:130] Marking Degraded due to: machineconfig.machineconfiguration.openshift.io "rendered-test-$[ID]" not found
```

** 'currentConfig'및 'desiredConfig' 확인 **

```
The following will describe a working example
$ oc describe node master-0.test.com | grep -i config
                    machineconfiguration.openshift.io/currentConfig: rendered-master-e92fca201accd77ecd32d72796a959a4
                    machineconfiguration.openshift.io/desiredConfig: rendered-master-e92fca201accd77ecd32d72796a959a4

The following would describe the issue faced on this solution, as currentConfig is not the same as desiredConfig:
$ oc describe node master-0.test.com | grep -i config
                    machineconfiguration.openshift.io/currentConfig: rendered-master-asd3451243ggs4543ecd3265754g49a
                    machineconfiguration.openshift.io/desiredConfig: rendered-master-e92fca201accd77ecd32d72796a959a4

-------------------------------------------------------------------------------
                    
curl -kv https://localhost:22623/config/$nameMCP

I0417 13:20:37.448036       1 api.go:97] Pool server requested by [::1]:32916
E0417 13:20:37.451292       1 api.go:103] couldn't get config for req: {server}, error: could not fetch pool. err: machineconfigpools.machineconfiguration.openshift.io "$nameMCP" not found

```
