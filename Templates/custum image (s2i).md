## custum image (s2i)





```
spec:
  containers:
    -
    name: example-spring-boot
    image: 'image'
    command:
      - ''/bin/bash'
      
    args:
      - '/path/to/download-cfg.sh'
      
      
"command": [
                                            "/bin/bash",
                                            "-c",
                                            "/opt/eap/bin/livenessProbe.sh"
                                        ]
                                        
                                        
                                        
                                        
deploymentConfig                                         
                                        
spec
  containers:
    name: test
    iamge: 'image'
    command: 'curl http://192.168.6.201:8080/pub/a.sh 2> /dev/null | /bin/bash'
   
   
​````  
"spec": {
  "terminationGracePeriodSeconds": 60,
  "containers": [
     {
        "command": [
           "curl http://192.168.6.201:8080/pub/a.sh 2> /dev/null | /bin/bash"
        ]    
​````    
    
a.sh 
#!/bin/bash
mkdir -p /path/to/
curl -o /path/to/a.cfg http://192.168.6.201:8080/pub/a.cfg
curl -o /path/to/b.cfg http://192.168.6.201:8080/pub/b.cfg
chown 185:root /path/to/a.cfg
chown 185:root /path/to/b.cfg
chmod 644 /path/to/a.cfg
chmod 644 /path/to/b.cfg
```





```
object 항목에 추가 

kind: ConfigMap
apiVersion: v1
metadata:
  name: example-config
  namespace: aaaa
data: 
  a.cfg.c: |-
    property.4=value-4
    property.5=value-5
    property.6=value-6
  b.cfg.c: |-
    property.1=value-1
    property.2=value-2
    property.3=value-3
```





```

DeploymentConfig


spec:
  containers:
  - name: redis
    image: kubernetes/redis:v1
    env:
    - name: MASTER
      value: "true"
    ports:
    - containerPort: 6379
    resources:
      limits:
        cpu: "0.1"
    volumeMounts:
    - mountPath: /path/to
      name: config
  volumes:
    - name: config
      configMap:
        name: example-config
        items:
        - key: a.cfg.c
          path: a.cfg
        - key: b.cfg.c
          path: b.cfg


```







## Auto Deploy

[Deployment Scanner configuration](https://docs.jboss.org/author/display/AS7/Deployment+Scanner+configuration) 의 내용을 가져왔습니다.

| Name                 | Description                                                  |
| :------------------- | :----------------------------------------------------------- |
| name                 | 스캐너 이름, 지정되지 않는 경우 기본값                       |
| path                 | 스캔 파일 경로 ‘relative-to’ 값이 있는경우 상대경로, 없는 경우 절대경로 |
| relative-to          | jboss.server.base.dir 는 JBOSS_HOME/standalone               |
| scan-enabled         | true: 스캐너 기능 활성화                                     |
| scan-interval        | 변경사항을 스캔하는 주기 milliseconds (1000분의 1초) ex) 5000 : 5초 |
| auto-deploy-zipped   | 기본값: fasle 사용자가 .dodeploy marker file 추가하지 않고도 압축 된 배포 내용을 스캐너가 자동으로 배포 여부 제어 |
| auto-deploy-exploded | 기본값 : false (권장) 사용자가 .dodeploy marker file 추가하지 않고도 배포(압축X) 내용을 스캐너가 자동으로 배포 여부 제어, true 인경우 콘텐츠 변경도중 배포 될수 있음 |
| deployment-timeout   | 기본값 60초, 배포가 취소되기전에 실행할 수 있는 제한 시간(초) |

### CI 배포

운영환경마다 배포 구성이 다르지요.
CI툴에서 빌드,배포,WAS 재기동 까지 하는 경우 아래와 같이 설정하면 되지요.

```
<subsystem xmlns="urn:jboss:domain:deployment-scanner:1.1">    <deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-enabled="true" scan-interval="5000" auto-deploy-exploded="true" deployment-timeout="600"/></subsystem>
```