

# nfs automatic provisioner

## provisioner download

### 1. nfs server 설정 

### 2. Provisioner file 다운받기

[download link](https://github.com/kubernetes-incubator/external-storage/tree/master/nfs-client)

```
   git clone https://github.com/kubernetes-incubator/external-storage.git

  unzip master.zip

  cd  external-storage/**nfs-client**/
```

### 3. Set the subject of the RBAC objects to the current namespace where the provisioner is being deployed

```

$ oc new-project nfs-storage
$ NAMESPACE=`oc project -q`
$ sed -i'' "s/namespace:.*/namespace: $NAMESPACE/g" ./deploy/rbac.yaml
$ oc create -f deploy/rbac.yaml
$ oc adm policy add-scc-to-user hostmount-anyuid system:serviceaccount:$NAMESPACE:nfs-client-provisioner
```

### 4. nfs provisioner 설정

```
deploy/deployment.yaml
--------------------------------------------
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nfs-client-provisioner
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nfs-client-provisioner
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: nfs-client-provisioner
    spec:
      serviceAccountName: nfs-client-provisioner
      containers:
        - name: nfs-client-provisioner
          image: quay.io/external_storage/nfs-client-provisioner:latest
          volumeMounts:
            - name: nfs-client-root
              mountPath: /persistentvolumes
          env:
            - name: PROVISIONER_NAME
              value: fuseim.pri/ifs
            - name: NFS_SERVER
              value: <YOUR NFS SERVER HOSTNAME>
            - name: NFS_PATH
              value: /path/to
      volumes:
        - name: nfs-client-root
          nfs:
            server: <YOUR NFS SERVER HOSTNAME>
            path: /path/to
```

```
deploy/class.yaml
------------------------------------
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-nfs-storage
provisioner: fuseim.pri/ifs # or choose another name, must match deployment's env PROVISIONER_NAME'
parameters:
  archiveOnDelete: "false" # When set to "false" your PVs will not be archived
                           # by the provisioner upon deletion of the PVC.
```

```
oc apply -f deploy/deployment.yaml   ## provisioner deploy
oc apply -f deploy/class.yaml        ## storage class create
```

### 5. Finally, test your environment!

```
## test deploy 
$ oc create -f deploy/test-claim.yaml -f deploy/test-pod.yaml

## delete test pod & pvc 
$ oc delete -f deploy/test-pod.yaml -f deploy/test-claim.yaml
```

### 6. Deploying your own PersistentVolumeClaims

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-claim
  annotations:
    volume.beta.kubernetes.io/storage-class: "managed-nfs-storage"
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 1Mi
```





