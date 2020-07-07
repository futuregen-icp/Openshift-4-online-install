## Automatic image pruning

overview와 alertmanager에서 "Automatic image pruning is not enabled" 관련 오류가 발생 
오류로 보기보다는 경고로 보는 것이 맞다 

내용 : 
자동 이미지 제거 기능이 활성화되어 있지 않습니다. 
클러스터를 정상 상태로 유지하려면 ImageStreams에서 더 이상 참조하지 않는 이미지를 정기적으로 정리하는 것이 좋습니다. 
이 경고를 제거하려면 이름이 'cluster'인 imagepruner.imageregistry.operator.openshift.io 리소스를 만들어 이미지 정리기를 설치하십시오. 
'suspend'필드가 'false'로 설정되어 있는지 확인하십시오.

해결

```
oc edit  imagepruner.imageregistry.operator.openshift.io
```

```
spec:
  schedule: 0 0 * * *
  suspend: false  ==>  suspend: true
```
