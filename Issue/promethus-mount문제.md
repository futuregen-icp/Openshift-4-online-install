# Prometheus pods stuck in ContainerCreating state with Error: Unable to mount volumes



문제 

pormethus  ContainerCreating 에러

```
Unable to mount volumes for pod "prometheus-k8s-0_openshift-monitoring(XXXXX-XXX-XXX-XXXXXXX)": timeout expired waiting for volumes to attach or mount for pod "openshift-monitoring"/"prometheus-k8s-0". list of unmounted volumes=[secret-kube-etcd-client-certs]. list of unattached volumes=[prometheus-k8s-db config config-out prometheus-k8s-rulefiles-0 secret-kube-etcd-client-certs secret-prometheus-k8s-tls secret-prometheus-k8s-proxy secret-prometheus-k8s-htpasswd prometheus-k8s-token-hwc6m]
```

 

해결 

etcd 모니터링이 필요하지 않다면 해당 부분

```
$ oc -n openshift-monitoring edit configmap cluster-monitoring-config
...
data:
  config.yaml: |+
    ...
    etcd: ---------------------------> Remove complete etcd configuration 
      targets:
        selector:
          openshift.io/component: etcd
          openshift.io/control-plane: "true"
     .....
```

etcd 모니터링이 필요한 경우 [document](https://docs.openshift.com/container-platform/3.11/install_config/prometheus_cluster_monitoring.html#configuring-etcd-monitoring_prometheus-cluster-monitoring)



진단 단계

```
$ oc -n openshift-monitoring get servicemonitor
NAME                  AGE
alertmanager          35m
etcd                  1m   <----------------------- Shows etcd monitoring is enabled
kube-apiserver        36m
kube-controllers      36m
kube-state-metrics    34m
kubelet               36m
node-exporter         34m
prometheus            36m
prometheus-operator   37m
```



````
$ oc get events -n openshift-monitoring
....
1m          5m           10        prometheus-k8s-1.166ee7b7ceb74c5c           Pod                                                         Warning   FailedMount              kubelet, infra-0.example.redhat.com   MountVolume.SetUp failed for volume "secret-kube-etcd-client-certs" : secrets "kube-etcd-client-certs" not found
1m          3m           2         prometheus-k8s-1.166ee7d41317e86c           Pod                                                         Warning   FailedMount              kubelet, infra-0.example..redhat.com   Unable to mount volumes for pod "prometheus-k8s-1_openshift-monitoring(XXXXXX-XXX-XX-XX-XXXXXX)": timeout expired waiting for volumes to attach or mount for pod "openshift-monitoring"/"prometheus-k8s-1". list of unmounted volumes=[secret-kube-etcd-client-certs]. list of unattached volumes=[config config-out prometheus-k8s-rulefiles-0 secret-kube-etcd-client-certs secret-prometheus-k8s-tls secret-prometheus-k8s-proxy secret-prometheus-k8s-htpasswd prometheus-k8s-db prometheus-k8s-token-khlv4]
````

