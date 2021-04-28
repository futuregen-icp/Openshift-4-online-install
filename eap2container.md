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
