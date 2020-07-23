# keycloak 설정 

## realm 설정 
keycloak 관리페이지 접속 이후 <br>
add realm을 클릭하여 openid를 이용할 realm을 생성 

![](image/01-realm.png)

**issuer주소를 복사**<br>
OpenID Endpoint Configuration을 클릭하면 issuer주소를 확인 가능하다

![](image/02-realm.png)

## client 설정 
### client 생성
keycloak 관리페이지 접속 이후 <br>
create을 클릭<br>
 
![](image/01-client.png)
<br>
<br>
### client 설정 
keycloak 관리페이지 접속 이후 <br>
openid-ocp 클릭<br>

![](image/02-client.png)

###Credential값을 clipboard에 복사<br>
**Client Authenticator : Client ID and Secret**

![](image/03-client.png)
