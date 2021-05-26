##  jboss template 설치 하기 



tag를 변경하면 다른 버전의 템플릿을 설치 할 수 있다

https://github.com/jboss-container-images/jboss-eap-7-openshift-image



### Importing Imagestreams and Templates

```
for resource in eap73-image-stream.json \
  eap73-amq-persistent-s2i.json \
  eap73-amq-s2i.json \
  eap73-basic-s2i.json \
  eap73-https-s2i.json \
  eap73-sso-s2i.json \
  eap73-third-party-db-s2i.json \
  eap73-tx-recovery-s2i.json
do
  oc replace --force -f https://raw.githubusercontent.com/jboss-container-images/jboss-eap-7-openshift-image/7.3.x/templates/${resource}
done
```



### Updating Existing Images

```
oc import-image jboss-eap73-openshift:7.3
```



#### Creating New Applications With Templates 

```
oc -n myproject new-app eap73-basic-s2i -p APPLICATION_NAME=eap73-basic-app
```



### 일부 템플릿은 secret 생성이 필요 

```
$ keytool -genkey -keyalg RSA -alias eapdemo-selfsigned -keystore keystore.jks -validity 360 -keysize 2048
$ oc secrets new eap7-app-secret keystore.jks
```



ex)

```
oc create -n myproject -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/secrets/eap-app-secret.json
oc create -n myproject -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/secrets/eap7-app-secret.json
oc create -n myproject -f https://raw.githubusercontent.com/jboss-openshift/application-templates/master/secrets/sso-app-secret.json
```

