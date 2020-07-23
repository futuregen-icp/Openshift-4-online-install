# openid를 이용한 keycloak 연동

## web console을 이용하는 방법 

> openshift위에 구동되는 keycloak 또는  RHSSO는 <br> openshift에서 ca.crt를 다운 받아야 한다<br> 


	CA 파일 받는 방법
	oc get cm/router-ca -n openshift-config-managed -o jsonpath='{.data.ca\-bundle\.crt}'

	로그 확인시 
	oc -n openshift-authentication-operator logs $(oc -n openshift-authentication-operator get pods -l app=authentication-operator -o=custom-columns=NAME:.metadata.name --no-headers)
	[...]
	E1125 15:31:27.093873       1 oauth.go:69] failed to honor IDP v1.IdentityProvider{Name:"sso", 
	MappingMethod:"claim", IdentityProviderConfig:v1.IdentityProviderConfig{Type:"OpenID", 
	BasicAuth:(*v1.BasicAuthIdentityProvider)(nil), GitHub:(*v1.GitHubIdentityProvider)(nil), 
	GitLab:(*v1.GitLabIdentityProvider)(nil), Google:(*v1.GoogleIdentityProvider)(nil), 
	HTPasswd:(*v1.HTPasswdIdentityProvider)(nil), Keystone:(*v1.KeystoneIdentityProvider)(nil), 
	LDAP:(*v1.LDAPIdentityProvider)(nil), OpenID:(*v1.OpenIDIdentityProvider)(0xc010181ef0), RequestHeader:(*v1.RequestHeaderIdentityProvider)(nil)}}: 
	x509: certificate signed by unknown authority
	
	I1125 15:31:28.369400       1 status_controller.go:165] clusteroperator/authentication diff 
	{"status":{"conditions":
	[{"lastTransitionTime":"2019-11-20T10:17:18Z","message":"IdentityProviderConfigDegraded: 
	failed to apply IDP sso config: x509: certificate signed by unknown
	authority","reason":"AsExpected","status":"False","type":"Degraded"},
	{"lastTransitionTime":"2019-11-22T11:41:09Z","reason":"AsExpected","status":
	"False","type":"Progressing"},{"lastTransitionTime":"2019-10-26T16:15:59Z","reason":"AsExpected","status":
	"True","type":"Available"},{"lastTransitionTime":"2019-10-26T13:30:53Z","reason":"AsExpected","status":
	"True","type":"Upgradeable"}]}}


1. Cluster setting (left) -> Global Configuration (sub-top) -> Oauth -> add (bottom) 
2. selected OpenID connect
3. 입력 창에서  
   **Name             :  openid-ocp** <br>
   **Client ID        :  openid-ocp** <br>
                      > keycloak에서 제공하는                
                      > https://oauth-openshift.apps.<clustername\>.<basedomain\>/oauth2callback/<identiry provider name\> 앞의 도메인으로  <br>
   **Client Secret    : ec766561-d87c-449f-8f0e-4bae2c69cb7d** <br>
                    > keycloak 관리 사이트 -> Clients -> 사용할 Client ID -> Credentails<br>
                    > Client Authenticator : client and secret 선택 <br> 
   **Issuer URL       :  https://keycloak-keycloak.apps.ocp4.igotit.co.kr/auth/realms/openid-ocp** <br>
                    > keycloak 관리 사이트 -> Realm Settings  <br>
                    > Endpoint : OpenID Endpoint Configuration 클릭 <br>
                    > 새창에서 issuer url 확인 


   CA File          : 위에 설명한 방법으로 생성한 ca.crt
                      또는 제공되는 ca.crt

 ##yaml을 이용하는 방법 

**Client Secret 생성**

```
$ oc create secret generic <idp-secret --from-literal=clientSecret=ec766561-d87c-449f-8f0e-4bae2c69cb7d -n openshift-config
```

**CA 파일 configmaps 생성**

```
$ oc create configmap ca-config-map --from-file=ca.crt=/path/to/ca -n openshift-config
```

**openid connect identity provider  for openshift**

```
cat openid-keycloak.yaml

apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: openid-ocp 
    mappingMethod: claim 
    type: OpenID
    openID:
      clientID: openid-ocp 
      clientSecret: 
        name: idp-secret
      claims: 
        preferredUsername:
        - preferred_username
        name:
        - name
        email:
        - email
      issuer: https://keycloak-keycloak.apps.ocp4.igotit.co.kr/auth/realms/openid-ocp

oc apply -f openid-keycloak.yaml
```