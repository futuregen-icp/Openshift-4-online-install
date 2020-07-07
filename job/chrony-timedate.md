# Openshift Time zone 설정 작업 

> 해당 작업은  machineconfig를 이용하여 
> 설정한다

## chrony 설정을 base64로 인코딩 

```
cat << EOF | base64
    pool 2.rhel.pool.ntp.org iburst
    driftfile /var/lib/chrony/drift
    makestep 1.0 3
    rtcsync
    keyfile /etc/chrony.keys
    leapsectz right/ROK
    logdir /var/log/chrony
EOF
    
ICAgIHBvb2wgMi5yaGVsLnBvb2wubnRwLm9yZyBpYnVyc3QKICAgIGRyaWZ0ZmlsZSAvdmFyL2xp
Yi9jaHJvbnkvZHJpZnQKICAgIG1ha2VzdGVwIDEuMCAzCiAgICBydGNzeW5jCiAgICBrZXlmaWxl
IC9ldGMvY2hyb255LmtleXMKICAgIGxlYXBzZWN0eiByaWdodC9ST0sKICAgIGxvZ2RpciAvdmFy
L2xvZy9jaHJvbnkK
```

## mechinconfig 생성 

### master

```
$ cat << EOF > ./99-masters-chrony-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: masters-chrony-configuration
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
          source: data:text/plain;charset=utf-8;base64,ICAgIHBvb2wgMi5yaGVsLnBvb2wubnRwLm9yZyBpYnVyc3QKICAgIGRyaWZ0ZmlsZSAvdmFyL2xpYi9jaHJvbnkvZHJpZnQKICAgIG1ha2VzdGVwIDEuMCAzCiAgICBydGNzeW5jCiAgICBrZXlmaWxlIC9ldGMvY2hyb255LmtleXMKICAgIGxlYXBzZWN0eiByaWdodC9ST0sKICAgIGxvZ2RpciAvdmFyL2xvZy9jaHJvbnkK
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/chrony.conf
  osImageURL: ""
EOF
```

### worker

```
$ cat << EOF > ./99-workers-chrony-configuration.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: workers-chrony-configuration
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
          source: data:text/plain;charset=utf-8;base64,ICAgIHBvb2wgMi5yaGVsLnBvb2wubnRwLm9yZyBpYnVyc3QKICAgIGRyaWZ0ZmlsZSAvdmFyL2xpYi9jaHJvbnkvZHJpZnQKICAgIG1ha2VzdGVwIDEuMCAzCiAgICBydGNzeW5jCiAgICBrZXlmaWxlIC9ldGMvY2hyb255LmtleXMKICAgIGxlYXBzZWN0eiByaWdodC9ST0sKICAgIGxvZ2RpciAvdmFyL2xvZy9jaHJvbnkK
          verification: {}
        filesystem: root
        mode: 420
        path: /etc/chrony.conf
  osImageURL: ""
EOF
```

## 기존의 chrony 설정 백업 

## 설정 적용 

```
oc apply -f  ./99-masters-chrony-configuration.yaml
oc apply -f  ./99-workers-chrony-configuration.yaml
```



```
sudo timedatectl set-timezone 'Asia/Seoul'
```
