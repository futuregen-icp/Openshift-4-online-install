## identity provider ( htpassed )

### ID / PASSWORD 생성 

```
## htpasswd -c -B -b </path/to/users.htpasswd> <user_name> <password>

## 계정 설정 파일 초기화 및 최초 설정 
$ htpasswd -c -B -b /opt/install/oauth/htpasswd  admin_id  admin_passwd

## 계정 설정 추가
$ htpasswd -B -b /opt/install/oauth/htpasswd  admin_id2  admin_passwd2


cat /opt/install/oauth/htpasswd
admin_id:$2y$05$2rC0vqw9tZD5gIEkDHPa5O/o5A3VJQx.uiA0mQ/Ocnbuw4ARsmx3O
admin_id2:$2y$05$o9gPRHsKMCjGsYhW2sKc1ePdu2Fp0zzSCkrgbuyB6.OYESe62KCXm

```

### secret 생성 

```
oc create secret generic htpass-secret --from-file=htpasswd=/opt/install/oauth/htpasswd -n openshift-config
```


### CR 생성 

```
cat /opt/install/oauth/htpasswd.cr.yaml
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: ADMINS                    =>     identityProviders에서 디스플레이될 이름  
    mappingMethod: claim 
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret         =>     생성한 secret 파일 
```

### CR 파일 적용 

```
oc apply -f /opt/install/oauth/htpasswd.cr.yaml
````

### 사용자 권한 

```
 oc adm policy add-cluster-role-to-user cluster-admin admin_id
 oc adm policy add-role-to-user admin admin_id
```

## 계정 업데이트 

### secret 에서 htpasswd 파일 생성 

```
oc get secret htpass-secret -ojsonpath={.data.htpasswd} -n openshift-config | base64 -d > /opt/install/oauth/htpasswd
```

### 계정 정보 업데이트 

**신규 사용자 **

```
$ htpasswd -bB /opt/install/oauth/htpasswd admin_id2 admin_passwd2
Adding password for user admin_id2
To remove an existing user:
```

**사용자 제거 **

```
$ htpasswd -D /opt/install/oauth/htpasswd admin_id1
Deleting password for user admin_id1
```

### Secret 내용 갱신 

```
$ oc create secret generic htpass-secret --from-file=htpasswd=users.htpasswd --dry-run -o yaml -n openshift-config | oc replace -f -
```

## 사용자 제거시 추가 작업 

**사용자 삭제

```
 oc delete user admin_id1 **
```

**사용자를 위한 identity provider 링크 제거 **

```
oc delete identity ADMINS:admin_id1
```




## 생성 스크립트 
```
#!/bin/bash

OCPUSER="admins"
OCPPASS="dlfmsdkcla"
OCPIDPF="users.htpasswd"
OCPIDPN="admons"

htpasswd -c -B -b $OCPIDPF $OCPUSER $OCPPASS
oc create secret generic ${OCPIDPN}-htpass-secret --from-file=htpasswd=users.htpasswd -n openshift-config

cat <<EOF> ${OCPIDPN}-CR.yaml
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: ${OCPIDPN}
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: ${OCPIDPN}-htpass-secret
EOF

oc apply -f  ${OCPIDPN}-CR.yaml


oc adm policy add-cluster-role-to-user cluster-admin ${OCPIDPN}
oc adm policy add-role-to-user admin ${OCPIDPN}

```
