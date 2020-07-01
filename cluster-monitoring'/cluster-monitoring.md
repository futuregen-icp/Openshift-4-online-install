#  cluster monitoring 

## 스토리자 사용량 책정 하기 

### Capacity Planning for Cluster Monitoring Operator

| Number of Nodes | Number of Pods | Prometheus storage growth per day | Prometheus storage growth per 15 days | RAM Space (per scale size) | Network (per tsdb chunk) |
| :-------------- | :------------- | :-------------------------------- | :------------------------------------ | :------------------------- | :----------------------- |
| 50              | 1800           | 6.3GB                             | 94GB                                  | 6GB                        | 16MB                     |
| 100             | 3600           | 13GB                              | 195GB                                 | 10GB                       | 26MB                     |
| 150             | 5400           | 19GB                              | 283GB                                 | 12GB                       | 36MB                     |
| 200             | 7200           | 23GB                              | 375GB                                 | 14GB                       | 46MB                     |



## Prometheus 설정하기 

**Recommendations for OpenShift Container Platform**

- Use at least three infrastructure (infra) nodes.
- Use at least three **openshift-container-storage** nodes with non-volatile memory express (NVMe) drives.

**cluster-monitoring-config.yml** 생성

```
apiVersion: v1
kind: ConfigMap
data:
  config.yaml: |
    prometheusOperator:
      baseImage: quay.io/coreos/prometheus-operator
      prometheusConfigReloaderBaseImage: quay.io/coreos/prometheus-config-reloader
      configReloaderBaseImage: quay.io/coreos/configmap-reload
      nodeSelector:
        node-role.kubernetes.io/infra: ""
    prometheusK8s:
      retention: {{PROMETHEUS_RETENTION_PERIOD}} 
      baseImage: openshift/prometheus
      nodeSelector:
        node-role.kubernetes.io/infra: ""
      volumeClaimTemplate:
        spec:
          storageClassName: gp2
          resources:
            requests:
              storage: {{PROMETHEUS_STORAGE_SIZE}} 
    alertmanagerMain:
      baseImage: openshift/prometheus-alertmanager
      nodeSelector:
        node-role.kubernetes.io/infra: ""
      volumeClaimTemplate:
        spec:
          storageClassName: gp2
          resources:
            requests:
              storage: {{ALERTMANAGER_STORAGE_SIZE}} 
    nodeExporter:
      baseImage: openshift/prometheus-node-exporter
    kubeRbacProxy:
      baseImage: quay.io/coreos/kube-rbac-proxy
    kubeStateMetrics:
      baseImage: quay.io/coreos/kube-state-metrics
      nodeSelector:
        node-role.kubernetes.io/infra: ""
    grafana:
      baseImage: grafana/grafana
      nodeSelector:
        node-role.kubernetes.io/infra: ""
    auth:
      baseImage: openshift/oauth-proxy
    k8sPrometheusAdapter:
      nodeSelector:
        node-role.kubernetes.io/infra: ""
metadata:
  name: cluster-monitoring-config
namespace: openshift-monitoring
```

| PROMETHEUS_RETENTION_PERIOD | A typical value is `PROMETHEUS_RETENTION_PERIOD=15d`. <br/>Units are measured in time using one of these suffixes: s, m, h, d. |
| --------------------------- | ------------------------------------------------------------ |
| `PROMETHEUS_STORAGE_SIZE    | `PROMETHEUS_STORAGE_SIZE=2000Gi`. <br>Storage values can be a plain integer or as a fixed-point integer using one of these suffixes: E, P, T, G, M, K. You can also use the power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. |
| `ALERTMANAGER_STORAGE_SIZE  | A typical value is `ALERTMANAGER_STORAGE_SIZE=20Gi`. <br/>Storage values can be a plain integer or as a fixed-point integer using one of these suffixes: E, P, T, G, M, K. You can also use the power-of-two equivalents: Ei, Pi, Ti, Gi, Mi, Ki. |



### configmap 적용 하기 

```
oc create -f cluster-monitoring-config.yml
```

