# oc run 으로 서비스 구동 

## pod 생성 
### nginx 서비스  
	
    oc run nginx 
    
    // root 권한이 필요하여 구동되지 않고 Error 발생 

### 컨테이너 구동시 root 권한 허용 

[root 권한 허용시 참고](https://github.com/futuregen-icp/openshift3/blob/master/openshift%203%2C11%20job/%EC%82%AC%EC%9A%A9%EC%9E%90%EB%B3%B4%EC%95%88%EC%A0%95%EC%B1%85%EB%B0%8F%EB%B3%B4%EC%95%88%EC%BB%A8%ED%85%8D%EC%8A%A4%ED%8A%B8(role-to-user-and-securitycontext).md)

### deployment rollout 

	oc rollout latest dc nginx

## Service 등록 

    kind: Service
    apiVersion: v1
    metadata:
      name: nginx
      namespace: default
      selfLink: /api/v1/namespaces/default/services/nginx
      uid: 273d0ea6-e04d-41d3-b286-9f83b38db84d
      resourceVersion: '191152'
      creationTimestamp: '2020-05-05T11:52:24Z'
      managedFields:
        - manager: kubectl
          operation: Update
          apiVersion: v1
          time: '2020-05-05T11:52:24Z'
          fieldsType: FieldsV1
          fieldsV1:
            'f:spec':
              'f:ports':
                .: {}
                'k:{"port":80,"protocol":"TCP"}':
                  .: {}
                  'f:port': {}
                  'f:protocol': {}
                  'f:targetPort': {}
              'f:selector':
                .: {}
                'f:app': {}
              'f:sessionAffinity': {}
              'f:type': {}
    spec:
      ports:
        - name: web
          protocol: TCP
          port: 80
          targetPort: 80
      selector:
        app: nginx
      clusterIP: 10.110.247.75
      type: ClusterIP
      sessionAffinity: None
    status:
      loadBalancer: {}

## ingress 등록 

    apiVersion: networking.k8s.io/v1beta1
    kind: Ingress
    metadata:
      name: nginx
      namespace: myproject
    spec:
      rules:
        - host: nginx-myproject.ocp4.igotit.co.kr
          http:
            paths:
              - path: /
                backend:
                  serviceName: nginx
                  servicePort: 80


  ### 자원 

    [core@bastion ~]$ oc get all
    NAME                READY   STATUS    RESTARTS   AGE
    pod/nginx-3-v5s27   1/1     Running   0          96m
    
    NAME                            DESIRED   CURRENT   READY   AGE
    replicationcontroller/nginx-3   1         1         1       25h

    NAME            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
    service/nginx   ClusterIP   172.36.61.30   <none>        80/TCP    65m

    NAME                                       REVISION   DESIRED   CURRENT   TRIGGERED BY
    deploymentconfig.apps.openshift.io/nginx   4          1         0         config

    NAME                                   HOST/PORT                                PATH   SERVICES   PORT   TERMINATION   WILDCARD
    route.route.openshift.io/nginx-vbdp9   nginx-myproject.apps.ocp4.igotit.co.kr   /      nginx      80                   None
