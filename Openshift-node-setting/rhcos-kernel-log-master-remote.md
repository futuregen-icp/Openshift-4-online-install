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
