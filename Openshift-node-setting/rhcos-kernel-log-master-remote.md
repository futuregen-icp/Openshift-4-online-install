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
