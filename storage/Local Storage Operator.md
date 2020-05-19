# Local Storage Operator

## operator 설치 

### 1. namespace 생성 

```
$ oc new-project local-storage
```

### 2. Optional: Allow local storage creation on master and infrastructure nodes.

```
$ oc patch ds local-storage-local-diskmaker -n local-storage -p '{"spec": {"template": {"spec": {"tolerations":[{"operator": "Exists"}]}}}}'

$ oc patch ds local-storage-local-provisioner -n local-storage -p '{"spec": {"template": {"spec": {"tolerations":[{"operator": "Exists"}]}}}}'
```

### 3-1. web console  :  operator 설치

```


  1.  Navigate to Operators → OperatorHub.

  2.  Type **Local Storage** into the filter box to locate the Local Storage Operator.

  3.  Click Install.

  4.  On the Create Operator Subscription page, select **A specific namespace on the cluster**. Select **local-storage** from the drop-down menu.

  5.  Adjust the values for the Update Channel and Approval Strategy to the desired values.

  6.   Click **Subscribe**.


```

### 3-2. cli operator 설치

1) local-storage.yaml 생성

```
  apiVersion: v1
  kind: Namespace
  metadata:
    name: local-storage
  ---
  apiVersion: operators.coreos.com/v1alpha2
  kind: OperatorGroup
  metadata:
    name: local-operator-group
    namespace: local-storage
  spec:
    targetNamespaces:
      - local-storage
  ---
  apiVersion: operators.coreos.com/v1alpha1
  kind: Subscription
  metadata:
    name: local-storage-operator
    namespace: local-storage
  spec:
    channel: "{product-version}" 
    installPlanApproval: Automatic
    name: local-storage-operator
    source: redhat-operators
    sourceNamespace: openshift-marketplace
```

2) deploy

```
$ oc apply -f local-storage.yaml
```

### 4. pod 및 cluster 버전 확인

```
[core@bastion local]$ oc -n local-storage get pods
NAME                                      READY   STATUS    RESTARTS   AGE
local-storage-operator-7cc87cfdc5-9mzk6   1/1     Running   0          23h

[core@bastion local]$ oc get csvs -n local-storage
NAME                                         DISPLAY         VERSION               REPLACES   PHASE
local-storage-operator.4.3.19-202005041055   Local Storage   4.3.19-202005041055              Succeeded
```

### 5. Local volume provisioner

```
create-cr.yaml
---------------------------
apiVersion: "local.storage.openshift.io/v1"
kind: "LocalVolume"
metadata:
  name: "local-disks"
  namespace: "local-storage"
spec:
  nodeSelector:
    nodeSelectorTerms:
    - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - worker01.ocp4.igotit.co.kr
          - worker02.ocp4.igotit.co.kr
  storageClassDevices:
    - storageClassName: "local-sc"
      volumeMode: Filesystem
      fsType: xfs
      devicePaths:
        - /dev/vdb
```

```
$ oc get all -n local-storage
NAME                                          READY   STATUS    RESTARTS   AGE
pod/local-disks-local-diskmaker-7wxfh         1/1     Running   0          23h
pod/local-disks-local-diskmaker-grwtz         1/1     Running   0          23h
pod/local-disks-local-provisioner-4nx6t       1/1     Running   0          23h
pod/local-disks-local-provisioner-twqvl       1/1     Running   0          23h
pod/local-storage-operator-7cc87cfdc5-9mzk6   1/1     Running   0          23h

NAME                             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE
service/local-storage-operator   ClusterIP   172.36.235.84   <none>        60000/TCP   23h

NAME                                           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/local-disks-local-diskmaker     2         2         2       2            2           <none>          23h
daemonset.apps/local-disks-local-provisioner   2         2         2       2            2           <none>          23h

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/local-storage-operator   1/1     1            1           23h

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/local-storage-operator-7cc87cfdc5   1         1         1       23h
```

```
$ oc get pv
NAME                     CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                                             STORAGECLASS   REASON   AGE
image-registry-storage   100Gi      RWX            Retain           Bound       openshift-image-registry/image-registry-storage                           16d
local-pv-3f8e6b34        500Gi      RWO            Delete           Available                                                     local-sc                9h
local-pv-4f878305        500Gi      RWO            Delete           Available                                                     local-sc                9h
```

### 6. test

```
test-pod.yaml
--------------------------------------
kind: Pod
apiVersion: v1
metadata:
  name: test-local-pod
spec:
  containers:
  - name: test-local-pod
    image: gcr.io/google_containers/busybox:1.24
    command:
      - "/bin/sh"
    args:
      - "-c"
      - "touch /mnt/SUCCESS && exit 0 || exit 1"
    volumeMounts:
      - name: test-local-claim
        mountPath: "/mnt"
  restartPolicy: "Never"
  volumes:
    - name: test-local-claim
      persistentVolumeClaim:
        claimName: test-local-claim
```

```
test-claim.yaml
---------------------------------------------------
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-local-claim
  annotations:
    volume.beta.kubernetes.io/storage-class: "local-sc"
spec:
  accessModes:
   - ReadWriteOnce
  volumeMode: Filesystem
  resources:
    requests:
      storage: 100Gi
```

```
$ oc create -f test-pod.yaml -f test-claim.yaml
```



