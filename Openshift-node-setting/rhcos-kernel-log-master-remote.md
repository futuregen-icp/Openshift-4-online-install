# coreos journal logs 원격에 남기기

> coreos syslog가 없어 원격 로그 남기기 힘들다 <br>
> ncat을 이용하여 외부에 로그를 남긴다.

## machineconfig를 이용하여 masternode log를 외부로 송출

```
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: rhcos-kernel-log-master
spec:
  config:
    ignition:
      config: {}
      security:
        tls: {}
      timeouts: {}
      version: 2.2.0
    networkd: {}
    passwd: {}
    systemd:
      units:
        - contents: |
            [Unit]
            Description=Sends log output to container
            After=cloudwatchlogs.service
            [Service]
            Type=simple
            Restart=always
            TimeoutStartSec=60
            RestartSec=60
            ExecStart= /usr/bin/sh -c '/usr/bin/journalctl -k -o short -f  | /usr/bin/ncat -4 -u  bastion.ocp4.igotit.co.kr 514'
            ExecStop=
            [Install]
            WantedBy=multi-user.target
          enabled: true
          command: start
          name: coreos-kernel-log.service
  osImageURL: ""
```

## rhel에서 rsyslog 이용

```
/etc/rsyslog.conf 에 아래 내용 추가 
*.crit @bastion.ocp4.igotit.co.kr

```

## rhel에서 rsyslog 이용하여 로그 수집서버 구성

> 주석을 제거하여 수집서버 구성 <br>
> 현제는 udp 포트를 이용한 서버 구성 <br>
> tcp 서버를 구성하면  ncat의 -u 옵션 제거 해야함

```
# Provides UDP syslog reception
$ModLoad imudp
$UDPServerRun 514

# Provides TCP syslog reception
#$ModLoad imtcp
#$InputTCPServerRun 514
```

##  Configuring log forwarding using the Log Forwarding API
> fluentd만 생성하고 log forwarding API 이용한  log forwarding

#### 1, ClusterLogging CR 생성
>Administration → Custom Resource Definitions
>Custom Resource Definitions 에서, ClusterLogging 클릭.
>Custom Resource Definition Overview 에서, Actions 에서 View Instances 선택 및 클릭.
>ClusterLoggings에서 ,Create ClusterLogging 클릭.
>yaml 파일 편집
```
apiVersion: "logging.openshift.io/v1"
kind: "ClusterLogging"
metadata:
  name: "instance"
  namespace: "openshift-logging"
spec:
  managementState: "Managed"
  collection:
    logs:
      type: "fluentd"
      fluentd: {}

oc create -f createcr.yaml
```
#### 2, Enable Log Forwarding API
```
oc edit ClusterLogging instance

apiVersion: "logging.openshift.io/v1"
kind: "ClusterLogging"
metadata:
  annotations:
    clusterlogging.openshift.io/logforwardingtechpreview: enabled  #<<-- add lien
  name: "instance"
  namespace: "openshift-logging"
spec:
```


#### 3, create instance for Log Forwarding
```
apiVersion: "logging.openshift.io/v1alpha1"
kind: "LogForwarding"
metadata:
  name: instance
  namespace: openshift-logging
spec:
  disableDefaultForwarding: true
  outputs:
   - name: secureforward-offcluster
     type: "forward"
     endpoint: registry.ocp44.fu.com:514
     insecure: true
  pipelines:
   - name: container-logs
     inputSource: logs.app
     outputRefs:
     - secureforward-offcluster
   - name: infra-logs
     inputSource: logs.infra
     outputRefs:
     - secureforward-offcluster
   - name: audit-logs
     inputSource: logs.audit
     outputRefs:
     - secureforward-offcluster

oc create -f createLFCR.yaml
```
#### 4, rhel에서 rsyslog 이용하여 로그 수집서버 구성

> 주석을 제거하여 수집서버 구성 <br>
> 현제는 udp 포트를 이용한 서버 구성 <br>
> tcp 서버를 구성하면  ncat의 -u 옵션 제거 해야함

```
# Provides UDP syslog reception
$ModLoad imudp
$UDPServerRun 514

# Provides TCP syslog reception
#$ModLoad imtcp
#$InputTCPServerRun 514
```
