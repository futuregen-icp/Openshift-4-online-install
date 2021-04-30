## 20210428 뱅크웨어글로벌 리뷰 요청사항
```
- OCP Template 구성 변경
기존 git Repository의 프로젝트를 Build하여 Deploy하는 것이 아닌 war 파일이 고정적으로 배포되어 git Repository에서 배포되어야할 리소스는 .par파일
ex) /deployments/bxmAdmin.war 파일이 위치하면 자동으로 deploy 되는지?
ex) /deployments/bxmApps/*.par 경로에 git Repository의 .par 파일을 위치시킨다면 BXM에 해당 경로를 applicaiton-home으로 지정가능
이외 EAP설정파일 수정내역은 아래 기술

* Framework 구성 시 JBoss 설정

1. Datasource
기존 <datasource> 설정 외 <xa-datasource> 설정 추가 필요

2. Classpath
방안 1. modules 하위 jar파일 구성 및 설정파일[module.xml] 수정 [가이드구성 내용]
방안 2. WEB-INF/lib 디렉토리 하위에 배포 [테스트 필요]

3. 기동시 JVM옵션 추가 (Framework에서 사용하는  JVM Option) ~ legacy시스템 기준으로 standardalon.sh에서 JAVA_OPT에 추가함.
* Admin
-Dbxm.node.name=DFT1
-Dbxm.instance.name=bxmAdmin
-Dlogback.configurationFile=/WEB-INF/classes/logback.xml
-Doracle.jdbc.autoCommitSpecCompliant=false
* Online
-Dbxm.node.name=DFT1
-Dbxm.instance.name=bxmOnline
-Dlog.level.layer.file=WEB-INF/classes/logLayer.properties
-Dlogback.configurationFile=/WEB-INF/classes/logback.xml
-Doracle.jdbc.autoCommitSpecCompliant=false

4. War Deploy시 압축해제 상태로 배포 되어야 함
- legacy 시스템의 설정 stanalone.xml
---------------------------
<deployments>
    <deployment name="bxmAdmin.war" runtime-name="bxmAdmin.war">
        <fs-exploded path="절대경로"/>
    </deployment>
</deployments>
----------------------------
- 현행 standalone-openshift.xml ~ /opt/eap/stanalone/deployments 경로에 war파일이 위치하면 scan하여 기동?
-----------------------------
<subsystem xmlns="urn:jboss:domain:deployment-scanner:2.0">
    <deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="5000" runtime-failure-causes-rollback="${jboss.deployment.scanner.rollback.on.failur:false}" auto-deploy-exploded="false"/>
</subsystem>
----------------------------
```

## 이형승 이사 코멘트
```
authcommit을 false로 수정하는 것도 보인데...
이거.... 주의해야하고, 반드시 확인을 해야할 것 같아요.
그리고 xa를 사용하는 것도 이유가 있을 듯 한데, 그 이유를 먼저 확인하고, 수정을 하는게 더 좋을 듯 합니다.
정말 정말 xa가 필요한지...
그리고, 요즘 가이드는 connection.setAutoCommit(false); 를 그로그램단에서, 저굥ㅇ하는게 맞을 것 같고,
우리쪽  모듈을 변경하는 것은 가이드가 아빈디ㅏ.
```

## 20210428 뱅크웨어글로벌 리뷰 요청사항 > 20210429 메일 회신
```
- OCP Template 구성 변경
기존 git Repository의 프로젝트를 Build하여 Deploy하는 것이 아닌 war 파일이 고정적으로 배포되어 git Repository에서 배포되어야할 리소스는 .par파일
ex) /deployments/bxmAdmin.war 파일이 위치하면 자동으로 deploy 되는지?
ex) /deployments/bxmApps/*.par 경로에 git Repository의 .par 파일을 위치시킨다면 BXM에 해당 경로를 applicaiton-home으로 지정가능
이외 EAP설정파일 수정내역은 아래 기술
  + 메이븐 빌드하여서 war 생성하는 것도 가능하고, git에 war파일 위치 시키키는 것 가능
  + par파일은 pv에 복사해여야 함 > git에다가 war를 배포하실지 확인 부탁 드립니다.

* Framework 구성 시 JBoss 설정

1. Datasource
기존 <datasource> 설정 외 <xa-datasource> 설정 추가 필요
  + XA 사용의 사유 확인 필요 - 레드햇의 요건으로 사유를 확인할 필요가 있다고 하네요. 확인 부탁 드립니다.

2. Classpath
방안 1. modules 하위 jar파일 구성 및 설정파일[module.xml] 수정 [가이드구성 내용]
방안 2. WEB-INF/lib 디렉토리 하위에 배포 [테스트 필요]
  + pv에 파일을 위치하는 것으로 구조를 계획하고 빌드테스트를 통해서 조치

3. 기동시 JVM옵션 추가 (Framework에서 사용하는  JVM Option) ~ legacy시스템 기준으로 standardalon.sh에서 JAVA_OPT에 추가함.
* Admin
-Dbxm.node.name=DFT1
-Dbxm.instance.name=bxmAdmin
-Dlogback.configurationFile=/WEB-INF/classes/logback.xml
-Doracle.jdbc.autoCommitSpecCompliant=false
* Online
-Dbxm.node.name=DFT1
-Dbxm.instance.name=bxmOnline
-Dlog.level.layer.file=WEB-INF/classes/logLayer.properties
-Dlogback.configurationFile=/WEB-INF/classes/logback.xml
-Doracle.jdbc.autoCommitSpecCompliant=false
  + 예제값인지? define이 되는 값으로 확인 필요 > 정확하게 확인해서 주시면 반영하는 것으로 진행하려고 합니다.
4. War Deploy시 압축해제 상태로 배포 되어야 함
- legacy 시스템의 설정 stanalone.xml
---------------------------
<deployments>
    <deployment name="bxmAdmin.war" runtime-name="bxmAdmin.war">
        <fs-exploded path="절대경로"/>
    </deployment>
</deployments>
----------------------------
- 현행 standalone-openshift.xml ~ /opt/eap/stanalone/deployments 경로에 war파일이 위치하면 scan하여 기동?
-----------------------------
<subsystem xmlns="urn:jboss:domain:deployment-scanner:2.0">
    <deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="5000" runtime-failure-causes-rollback="${jboss.deployment.scanner.rollback.on.failur:false}" auto-deploy-exploded="false"/>
</subsystem>
----------------------------
  + pv 의 파일 참고하는 것도 가능하고 war의 압축해제로 배포도 가능 합니다. 파일을 알려주시면 pv에 위치시켜서 테스트를 진행 하는 것으로 가능한가요?
```

## 20214029 메일 회신
```
안녕하세요. 박원일 입니다.
BXM 엔지니어에게 메일을 전달해서 받은 답변입니다.
전달해 드립니다.

==== 답변 내용 시작 ====
: Template구성에 대한 요건은 사이트에서 정의하는게 정확하다고 판단합니다.
Online 서비스 개발시점에서의 지속적인 변경이 발생하는 리소스는 par파일이 될 것이며, war파일은 최종배포 이후 지속적인 변경이 발생하지 않는 것으로 판단됩니다.
이에따라 지속적변경이 없는 war를 pv에 복사하고 git에 par파일을 위치시킨 후 par파일을 이미지 내부로 이동이 가능한지 문의를 드렸던 사항이며,
Admin의 경우에 개발시점에서 Admin의 UI(war), Application(par) 모두 변경이 발생하기 때문에 Inline과 Template을 다르게 구성하실지 고려하셔야할듯 합니다.
==== 답변 내용 끝 ====

```

## 20210430 구두 상의 얘기 /w 이형승I
```
퓨저젠의 fault를 일부 있다고 하면서 문제가 커지면 퓨저젠의 책임이 있다는 쪽으로 몰면서
bxm 제공하는 환경을 구성하는 가이드를 모두 검토하고 기본이미지를 만들어서 base image(template) 환경은 제공하는 일정을 주자!
그리고 다음에 그쪽에서 진행하고, 또 요구사항 확인하고 일정을 확인해서 왔다갔다 .. 계획 하면서 진행하자!

개인 견해로는 bxm 엔지니어가 지금처럼 특정 날짜에 들어와서 하루이틀 진행하는 문제가 아닌 것 같고,
bxm을 레거시 to 컨테이너 전환하는 업무 테스크가 분량이 빠져있기 때문에 발생하는 문제이며 R&R부터 잡아야 하는데 
지금과 같이 절차 또한 업무이며 , 소통이 필요하고, 그리고 또 테스트해야 하는 업무가 있습니다. 업무의 분량이 큽니다.
지금이라도 타스크를 만들어서 R&R을 가져가야 할 것 같습니다.

첫번째 테스트 환경에서 안되는 부분, 부족한 부분을 계속 환인하고 필요한 것을 요청해 주시면, 옵션을 추가하자.

```
