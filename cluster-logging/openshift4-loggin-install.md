# Deploying cluster logging

----

## web console에서 설치 

### 설치 순서
> ***1. Elasticsearch Operator 설치*** <br>
> ***2. Cluster Logging Operator 설치*** <br>
> ***3. cluster logging instance 설치*** <br>
> **설치 순서 준수** 

**1. Elasticsearch Operator 설치**

** 웹콘솔 설치시 rbac 문제로 Elasticsearch 에서 문제 발생 **

1. 웹 콘솔에서  Operators → OperatorHub로 이동  
2. Elasticsearch Operator 선택 후 install 진행 (설치 화면의 설명 문서 읽어 볼 것 )  
3. intall mode 에서 All namespaces on the cluster 선택 (기본값)  
4. openshift-operators-redhat 네임스페이스를 이용하여 설치     
5. 웹 콘솔에서 Operators → Installed Operators로 이동 
6. Operator리스트에서 Elasticsearch Operator의 항목중 status 가 successed 로 변경된것을 
   확인하고 다음 단계로 넘어간다 

**2. Cluster Logging Operatort 설치**

1. 웹 콘솔에서  Operators → OperatorHub로 이동
2. cluster logging 선택 후 install 진행 (설치 화면의 설명 문서 읽어 볼 것 )
3. intall mode 에서 A specific namespace on the cluster 선택 
4. Operator recommended namespace 선택 : openshift-logging 네임스페이스에 설치
5. Enable operator recommended cluster monitoring on this namespace  checkbox 선택
6. Operator리스트에서 Elasticsearch Operator의 항목중 status 가 successed 로 변경된것을 <br> 
   workload → pod에서 cluster-logging-operator가 있는지 확인  


**3. cluster logging instance**

1. 웹 콘솔에서  Administration → Custom Resource Definitions으로 이동
2. Custom Resource Definitions페이지에서 ClusterLogging 버튼 클릭
3. Custom Resource Definition Overview페이지에서 우측 상단의 action 설렉트 메뉴에서 View Instances선택
4. ClusterLogging에서 Create ClusterLogging클릭 
5. yaml을 작성한다

    
    <pre>
    apiVersion: "logging.openshift.io/v1"
    kind: "ClusterLogging"
    metadata:
      name: "instance" 
      namespace: "openshift-logging"
    spec:
      managementState: "Managed"  
      logStore:
        type: "elasticsearch"  
        elasticsearch:
          nodeCount: 3 
          storage:
            storageClassName: "<storage-class-name>" 
            size: 200G
          redundancyPolicy: "SingleRedundancy"
      visualization:
        type: "kibana"  
        kibana:
          replicas: 1
      curation:
        type: "curator"  
        curator:
          schedule: "30 3 * * *"
      collection:
        logs:
          type: "fluentd"  
          fluentd: {}
    </pre>


<br>
----
## cli를 이용하여 설치

### 설치 순서
>***1. Elasticsearch Operator 네임스페이스 생성***<br>
>***2.  Cluster Logging Operator 네임스페이스 생성***<br> 
>***3. Elasticsearch Operator를 위한 object 생성***<br>
>***4. Cluster Logging Operator를 위한 object 생성***<br>
>***5. Cluster Logging instance 생성***<br>
>***6. Cluster Logging instance 확인***<br>
>**설치 순서 준수**


**1. Elasticsearch Operator 네임스페이스 생성**
  
    $ cat eo-namespace.yaml 

    apiVersion: v1
    kind: Namespace
    metadata:
      name: openshift-operators-redhat 
      annotations:
        openshift.io/node-selector: ""
      labels:
        openshift.io/cluster-monitoring: "true"

    $ oc create -f cat eo-namespace.yaml 

**2.  Cluster Logging Operator 네임스페이스 생성**

    $ cat clo-namespace.yaml
    
    apiVersion: v1
    kind: Namespace
    metadata:
      name: openshift-logging
      annotations:
        openshift.io/node-selector: ""
      labels:
        openshift.io/cluster-monitoring: "true"

    $ oc create -f clo-namespace.yaml

**3. Elasticsearch Operator를 위한 object 생성**

>  Operator Group object 생성  

    $ cat eo-og.yaml

    apiVersion: operators.coreos.com/v1
    kind: OperatorGroup
    metadata:
      name: openshift-operators-redhat
      namespace: openshift-operators-redhat 
    spec: {}

    $ oc create -f eo-og.yaml

> Subscription objec 생성

    $ cat eo-sub.yaml

    apiVersion: operators.coreos.com/v1alpha1
    kind: Subscription
    metadata:
      name: "elasticsearch-operator"
      namespace: "openshift-operators-redhat" 
    spec:
      channel: "4.4" 
      installPlanApproval: "Automatic"
      source: "redhat-operators" 
      sourceNamespace: "openshift-marketplace"
      name: "elasticsearch-operator"

    $ oc create -f eo-sub.yaml


> Operator installation 확인 하기 

    $ oc get csv --all-namespaces

    NAMESPACE                                               NAME                                        DISPLAY                  VERSION              REPLACES   PHASE
    default                                                 elasticsearch-operator.4.4.0-202005270305   Elasticsearch Operator   4.4.0-202005270305              Succeeded
    hs-test                                                 elasticsearch-operator.4.4.0-202005270305   Elasticsearch Operator   4.4.0-202005270305              Succeeded
    keycloak                                                elasticsearch-operator.4.4.0-202005270305   Elasticsearch Operator   4.4.0-202005270305              Succeeded
    kube-node-lease                                         elasticsearch-operator.4.4.0-202005270305   Elasticsearch Operator   4.4.0-202005270305              Succeeded
    kube-public                                             elasticsearch-operator.4.4.0-202005270305   Elasticsearch Operator   4.4.0-202005270305              Succeeded
    kube-system                                             elasticsearch-operator.4.4.0-202005270305   Elasticsearch Operator   4.4.0-202005270305              Succeeded
    ldap                                                    elasticsearch-operator.4.4.0-202005270305   Elasticsearch Operator   4.4.0-202005270305              Succeeded
    local-storage                                           elasticsearch-operator.4.4.0-202005270305   Elasticsearch Operator   4.4.0-202005270305              Succeeded
    local-storage                                           local-storage-operator.4.4.0-202005252114   Local Storage            4.4.0-202005252114              Succeeded
    nfs                                                     elasticsearch-operator.4.4.0-202005270305   Elasticsearch Operator   4.4.0-202005270305              Succeeded
    openshift-apiserver-operator                            elasticsearch-operator.4.4.0-202005270305   Elasticsearch Operator   4.4.0-202005270305              Succeeded
    openshift-apiserver                                     elasticsearch-operator.4.4.0-202005270305   Elasticsearch Operator   4.4.0-202005270305              Succeeded
    ...

**4. Cluster Logging Operator를 위한 object 생성**

>  Operator Group object 생성

    $ cat clo-og.yaml

    apiVersion: operators.coreos.com/v1
    kind: OperatorGroup
    metadata:
      name: cluster-logging
      namespace: openshift-logging 
    spec:
      targetNamespaces:
      - openshift-logging 

    $ oc create -f clo-og.yaml
  
> Subscription objec 생성

    $ cat clo-sub.yaml

    apiVersion: operators.coreos.com/v1alpha1
    kind: Subscription
    metadata:
      name: cluster-logging
      namespace: openshift-logging
    spec:
      channel: "4.4"
      name: cluster-logging
      source: redhat-operators
      sourceNamespace: openshift-marketplace

    $ oc create -f clo-sub.yaml

> Operator installation 확인 하기 


    $oc get csv -n openshift-logging

    NAME                                        DISPLAY                  VERSION              REPLACES   PHASE
    clusterlogging.4.4.0-202005270305           Cluster Logging          4.4.0-202005270305              Succeeded
    elasticsearch-operator.4.4.0-202005270305   Elasticsearch Operator   4.4.0-202005270305              Succeeded
    

**5. Cluster Logging instance 생성**

    cat clo-instance.yaml

    apiVersion: "logging.openshift.io/v1"
    kind: "ClusterLogging"
    metadata:
      name: "instance" 
      namespace: "openshift-logging"
    spec:
      managementState: "Managed"  
      logStore:
        type: "elasticsearch"  
        elasticsearch:
          nodeCount: 3 
          storage:
            storageClassName: "<storage-class-name>" 
            size: 200G
          redundancyPolicy: "SingleRedundancy"
      visualization:
        type: "kibana"  
        kibana:
          replicas: 1
      curation:
        type: "curator"  
        curator:
          schedule: "30 3 * * *"
      collection:
        logs:
          type: "fluentd"  
          fluentd: {}

    $ oc create -f clo-instance.yaml

**6. Cluster Logging instance 확인**

    $ oc get pods -n openshift-logging

    NAME                                            READY   STATUS      RESTARTS   AGE
    cluster-logging-operator-6c44c8cbb6-jm4bz       1/1     Running     0          5h40m
    curator-1591241400-44fzc                        0/1     Completed   0          126m
    elasticsearch-cdm-j2ep2o2l-1-5d855fd957-nk75v   2/2     Running     0          5h40m
    elasticsearch-cdm-j2ep2o2l-2-6946bc9b55-cgdvb   2/2     Running     0          5h39m
    fluentd-2rw96                                   1/1     Running     0          5h40m
    fluentd-74g7k                                   1/1     Running     0          5h40m
    fluentd-8hwc7                                   1/1     Running     0          5h40m
    fluentd-b47jb                                   1/1     Running     0          5h40m
    fluentd-sgmtz                                   1/1     Running     0          5h40m
    kibana-59c675f98b-76v5m                         2/2     Running     0          5h40m

<br><br>
----
## cluster logging instents 생성시 설정 커스트 마이징 하는 법 

### cpu momory 설정 
    spec:
      logStore:
        elasticsearch:
          resources:
            limits:
              cpu:
              memory:
            requests:
              cpu: 1
              memory: 16Gi
          type: "elasticsearch"
      collection:
        logs:
          fluentd:
            resources:
              limits:
                cpu:
                memory:
              requests:
                cpu:
                memory:
            type: "fluentd"
      visualization:
        kibana:
          resources:
            limits:
              cpu:
              memory:
            requests:
              cpu:
              memory:
         type: kibana
      curation:
        curator:
          resources:
            limits:
              memory: 200Mi
            requests:
              cpu: 200m
              memory: 200Mi
          type: "curator"

설정 설명 

          resources:
            limits:          -> 최대로 사용가능한 자원 할당량  
              cpu:
              memory:
            requests:        -> 구동시 할당할 자원 할당량  
              cpu: 1
              memory: 16Gi

### Elasticsearch storage 설정 

      spec:
        logStore:
          type: "elasticsearch"
          elasticsearch:
            nodeCount: 3
            storage:
              storageClassName: "gp2"
              size: "200G"

nodeCount : Elasticsearch 설치 노드 수 <br> 
storage   : 스토리지 설정 empty 설정 지원함  &nbsp;&nbsp;&nbsp;  ex) storage: {} <br>

**참고** 
> redundancyPolicy : 데이터 중복 저장에 대한 정 <br>
> FullRedundancy : 샤드는 모든 노드에 걸처 중복 저장 됨 <br> 
> MultipleRedundancy : 샤드는 전체노드 수의 절반의 수량 만큼 중복 저장 <br> 
> SingleRedundancy : 샤드는 하나의 사본 생성 <br> 
> ZeroRedundancy : 중복저장 없이 샤드 됨  <br>