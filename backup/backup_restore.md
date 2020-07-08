# OpenShift 4.4 badup - restrore 

## OpenShift 4.4 badup

### Master Server


	$ ssh -l core master01.ocp4.igotit.co.kr
  
### cluster backup script 실행 
	
	$ sudo -E /usr/local/bin/cluster-backup.sh ./assets/backup

	55722bfd13c0cc6b667d8f401c9b98affba61c234e79960a3044fdea91ef8770
	etcdctl version: 3.3.18
	API version: 3.3
	found latest kube-apiserver-pod: /etc/kubernetes/static-pod-resources/kube-apiserver-pod-16
	found latest kube-controller-manager-pod: /etc/kubernetes/static-pod-resources/kube-controller-manager-pod-12
	found latest kube-scheduler-pod: /etc/kubernetes/static-pod-resources/kube-scheduler-pod-6
	found latest etcd-pod: /etc/kubernetes/static-pod-resources/etcd-pod-3
	Snapshot saved at ./assets/backup/snapshot_2020-07-08_150124.db
	snapshot db and kube resources are successfully saved to ./assets/backup

### 백업 파일 설명 

	생성되는 백업 파일
	$ cd  ./assets/backup
	$ ll
	total 83008
	-rw-r--r--. 1 root root 84926496 Jul  8 15:01 snapshot_2020-07-08_150124.db
	-rw-r--r--. 1 root root    65636 Jul  8 15:01 static_kuberesources_2020-07-08_150124.tar.gz

snapshot_2020-07-08_150124.db : etcd 데이타 백업 

static_kuberesources_2020-07-08_150124.tar.gz : secret, configmaps, crt  등 정적인 데이터에 대한 백업  



## OpenShift 4.4 restore (backup data를 이용한 복구)

### Master Server

	$ ssh -l core master01.ocp4.igotit.co.kr


### 기존 설정 백업 

**etcd pod 정보 백업** 

	 sudo mv /etc/kubernetes/manifests/etcd-pod.yaml /tmp

**etcd pod 중지 확인**

	sudo crictl ps | grep etcd
	
**kubenetes api 구성 정보 백업**

	 sudo mv /etc/kubernetes/manifests/kube-apiserver-pod.yaml /tmp

**etcd data 백업**

	sudo mv /var/lib/etcd/ /tmp


### 백업을 이용한 복구

**restore 스크립트를 이용한 복구**

	sudo -E /usr/local/bin/cluster-restore.sh /home/core/backup
	...stopping kube-scheduler-pod.yaml
	...stopping kube-controller-manager-pod.yaml
	...stopping etcd-pod.yaml
	...stopping kube-apiserver-pod.yaml
	Waiting for container etcd to stop
	.complete
	Waiting for container etcdctl to stop
	.............................complete
	Waiting for container etcd-metrics to stop
	complete
	Waiting for container kube-controller-manager to stop
	complete
	Waiting for container kube-apiserver to stop
	..........................................................................................complete
	Waiting for container kube-scheduler to stop
	complete
	Moving etcd data-dir /var/lib/etcd/member to /var/lib/etcd-backup
	starting restore-etcd static pod
	starting kube-apiserver-pod.yaml
	static-pod-resources/kube-apiserver-pod-7/kube-apiserver-pod.yaml
	starting kube-controller-manager-pod.yaml
	static-pod-resources/kube-controller-manager-pod-7/kube-controller-manager-pod.yaml
	starting kube-scheduler-pod.yaml
	static-pod-resources/kube-scheduler-pod-8/kube-scheduler-pod.yaml 

**etcd pod 구동 여부 확인**

	sudo crictl ps | grep etcd
	oc get pods -n openshift-etcd | grep etcd

--처음 pending 상태에서 runnig 상태로 변경되는데  몇분 걸림--  

**etcd 디플로이먼트 생성하기**

	oc patch etcd cluster -p='{"spec": {"forceRedeploymentReason": "recovery-'"$( date --rfc-3339=ns )"'"}}' --type=merge 


reversion 확인
	
	oc get etcd -o=jsonpath='{range .items[0].status.conditions[?(@.type=="NodeInstallerProgressing")]}{.reason}{"\n"}{.message}{"\n"}
	AllNodesAtLatestRevision
	3 nodes are at revision 3

**kubeapiserver 디플로이먼트 생성하기**
	
	oc patch kubeapiserver cluster -p='{"spec": {"forceRedeploymentReason": "recovery-'"$( date --rfc-3339=ns )"'"}}' --type=merge

reversion 확인
	
	oc get kubeapiserver -o=jsonpath='{range .items[0].status.conditions[?(@.type=="NodeInstallerProgressing")]}{.reason}{"\n"}{.message}{"\n"}'
	AllNodesAtLatestRevision
	3 nodes are at revision 3

**kubecontrollermanager 디플로이먼트 생성하기**

	oc patch kubecontrollermanager cluster -p='{"spec": {"forceRedeploymentReason": "recovery-'"$( date --rfc-3339=ns )"'"}}' --type=merge

reversion 확인
	
	oc get kubecontrollermanager -o=jsonpath='{range .items[0].status.conditions[?(@.type=="NodeInstallerProgressing")]}{.reason}{"\n"}{.message}{"\n"}'
	AllNodesAtLatestRevision
	3 nodes are at revision 3

**kubescheduler 디플로이먼트 생성하기**

	oc patch kubescheduler cluster -p='{"spec": {"forceRedeploymentReason": "recovery-'"$( date --rfc-3339=ns )"'"}}' --type=merge

reversion 확인

	oc get kubescheduler -o=jsonpath='{range .items[0].status.conditions[?(@.type=="NodeInstallerProgressing")]}{.reason}{"\n"}{.message}{"\n"}'
	AllNodesAtLatestRevision
	3 nodes are at revision 3

**클러스터의 조인 상태 확인**

 	$ oc get pods -n openshift-etcd | grep etcd
	etcd-master01.ocp4.igotit.co.kr                3/3     Running     0          8d
	etcd-master02.ocp4.igotit.co.kr                3/3     Running     0          8d
	etcd-master03.ocp4.igotit.co.kr                3/3     Running     0          8d