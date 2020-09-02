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

### loopback 설정을 위한 이더넷 설정과 ARP stom을 막기 위한 설정 

```
## /etc/sysconfig/network-script/ifcfg-lo:0
cat << EOF | base64
DEVICE="lo:0"
ONBOOT=yes
BOOTPROTO=none
IPADDR="192.168.1.175"
NETMASK="255.255.255.255"
EOF

## /etc/sysctl.d/99-loopback-dsr.conf
cat << EOF | base64
## L4 DSR arp ston 
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
net.ipv4.conf.lo.arp_ignore = 1
net.ipv4.conf.lo.arp_announce = 2
EOF

```

### machingconfig 설정 

```
cat << EOF > ./99-route-loopback-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: route
  name: route-loopback-configuration
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
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,REVWSUNFPSJsbzowIgpPTkJPT1Q9eWVzCkJPT1RQUk9UTz1ub25lCklQQUREUj0iMTkyLjE2OC4xLjE3NSIKTkVUTUFTSz0iMjU1LjI1NS4yNTUuMjU1Igo=
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/sysconfig/network-scripts/ifcfg-lo:0
      - contents:
          source: data:text/plain;charset=utf-8;base64,IyMgTDQgRFNSIGFycCBzdG9uIApuZXQuaXB2NC5jb25mLmFsbC5hcnBfaWdub3JlID0gMQpuZXQuaXB2NC5jb25mLmFsbC5hcnBfYW5ub3VuY2UgPSAyCm5ldC5pcHY0LmNvbmYubG8uYXJwX2lnbm9yZSA9IDEKbmV0LmlwdjQuY29uZi5sby5hcnBfYW5ub3VuY2UgPSAyCg==
          verification: {}
        filesystem: root
        mode: 420
        path:  /etc/sysctl.d/99-dsr-loopback.conf
  osImageURL: ""
EOF
```

## 2. system service 생성 (test 중 )

### ip addr add 192.168.1.175/32 dev lo  서비스로 구동 

```
cat << EOF > ./99-route-loopback-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: route
  name: route-loopback-configuration
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
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,IyMgTDQgRFNSIGFycCBzdG9uIApuZXQuaXB2NC5jb25mLmFsbC5hcnBfaWdub3JlID0gMQpuZXQuaXB2NC5jb25mLmFsbC5hcnBfYW5ub3VuY2UgPSAyCm5ldC5pcHY0LmNvbmYubG8uYXJwX2lnbm9yZSA9IDEKbmV0LmlwdjQuY29uZi5sby5hcnBfYW5ub3VuY2UgPSAyCg==
          verification: {}
        filesystem: root
        mode: 420
        path:  /etc/sysctl.d/99-dsr-loopback.conf
    systemd:
      units:
        - contents: |
            [Unit]
            Description=loopback
            Wants=rpc-statd.service network-online.target 
            After=network-online.target crio.service

            [Service]
            Type=notify
            ExecStart=/usr/sbin/ip addr add 192.168.1.175/32 dev lo

            Restart=always
            RestartSec=10
            [Install]
            WantedBy=multi-user.target
          enabled: true
          name: loopbackAdd.service
  osImageURL: ""
EOF
```

### rhcos, rhel 모두 잘되는 것으로 확인 
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet 192.168.1.175/32 scope global lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever

```

## 의문 
> 재부팅시에는 문제되니 않지만 <br>
> 네크워크가 재시작되면 ?
