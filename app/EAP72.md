## Pulling EAP 7.2 image
```
# podman login registry.redhat.io
# podman pull registry.redhat.io/jboss-eap-7/eap72-openshift:1.2-23
# podman tag registry.redhat.io/jboss-eap-7/eap72-openshift:1.2-23 registry.oss2.fu.igotit.co.kr:5000/jboss-eap-72-openshift:1.2-23
# podman push registry.oss2.fu.igotit.co.kr:5000/jboss-eap-72-openshift:1.2-23
```

## Create Project for eap demo
```
$ oc new-project eap-demo
```

## Create the templates 
```
for resource in \
  eap72-image-stream.json \
  eap72-amq-persistent-s2i.json \
  eap72-amq-s2i.json \
  eap72-basic-s2i.json \
  eap72-https-s2i.json \
  eap72-mongodb-persistent-s2i.json \
  eap72-mysql-persistent-s2i.json \
  eap72-postgresql-persistent-s2i.json \
  eap72-sso-s2i.json
do
  oc replace --force -f \
https://raw.githubusercontent.com/jboss-container-images/jboss-eap-7-openshift-image/eap72/templates/${resource}
done
```

## Create the new app
```
oc new-app --template=eap72-basic-s2i \
 -p IMAGE_STREAM_NAMESPACE=eap-demo \
 -p SOURCE_REPOSITORY_URL=https://github.com/jboss-developer/jboss-eap-quickstarts \
 -p SOURCE_REPOSITORY_REF=openshift \
 -p CONTEXT_DIR=kitchensink
```

## fix error for new app
```
oc describe buildconfig/eap-app

... error instantiating Build from BuildConfig eap-demo/eap-app (0): Error resolving ImageStreamTag jboss-eap72-openshift:1.2 in namespace eap-demo: unable to find latest tagged image


error: build error: After retrying 2 times, Pull image still failed due to error: while pulling "docker://image-registry.openshift-image-registry.svc:5000/openshift/jboss-eap72-openshift@sha256:464e00edbf44d91820b9d9e95edbe6c68e075b85158f60e3d2298d94c9ec56b0" as "image-registry.openshift-image-registry.svc:5000/openshift/jboss-eap72-openshift@sha256:464e00edbf44d91820b9d9e95edbe6c68e075b85158f60e3d2298d94c9ec56b0": Error initializing source docker://image-registry.openshift-image-registry.svc:5000/openshift/jboss-eap72-openshift@sha256:464e00edbf44d91820b9d9e95edbe6c68e075b85158f60e3d2298d94c9ec56b0: Error reading manifest sha256:464e00edbf44d91820b9d9e95edbe6c68e075b85158f60e3d2298d94c9ec56b0 in image-registry.openshift-image-registry.svc:5000/openshift/jboss-eap72-openshift: unknown: unable to pull manifest from registry.redhat.io/jboss-eap-7/eap72-openshift@sha256:464e00edbf44d91820b9d9e95edbe6c68e075b85158f60e3d2298d94c9ec56b0: Get "https://registry.redhat.io/v2/jboss-eap-7/eap72-openshift/manifests/sh...

## change image stream url..
image-registry.openshift-image-registry.svc:5000/openshift/jboss-eap72-openshift

```

## Check configuration files
```
cd /opt/eap/bin/launch # oracle-common.sh

vi /opt/eap/bin/openshift-launch.sh
 # run a jennifer agent shell 
source /opt/eap/jennifer/agent.java/jennifer-apm.sh
 # java opts configuration for runServer()
JAVA_OPTS="{JAVA_OPTS} -Dorg.jboss.as.logging.per-deployment=false -Dfile.encoding=UTF-8 -Dfile.encoding=UTF-8 -Djboss.server.log.dir=${LOG_DIR} -Dos.app.id=${OS_APP_ID}"
 # log directory configuration for hostpath on else
  LOG_DIR="/opt/eap/standalone/log"
  if [ -d "/logs" ] ; then
    LOG_DIR=/logs/${OS_APP_ID}/`hostname`
    echo "mkdir ${LOG_DIR}"
    mkdir -p ${LOG_DIR}
  else
    echo "No Persistent Volumes."
  fi

 # run oracle-common.sh on else
  source $JBOSS_HOME/bin/launch/oracle-common.sh
```

## Remove

# Create eap 7.3 with mysql

## Create key chain and create secret
```
+ Key chain file : keystore.jks
+ route path : http://eap-app-eap-demo.apps.oss2.fu.igotit.co.kr
keytool -genkey -keyalg RSA -alias eapdemo-selfsigned -keystore keystore.jks -validity 360 -keysize 2048 #pass: test1234!, created keystore.jks
oc secrets new SECRET_NAME KEYSTORE_FILENAME.jks
```
# install Openjdk 1.8 Because Using keytool.
```
# yum install java-1.8.0-openjdk
# yum install java-1.8.0-openjdk-devel
```

# Remark

## 빌더로 이미지 만들기 - 기타 솔루션 및 커스텀을 위한 이미지 구성 작업

```
# cat build_obank_jennifer.sh

#!/bin/sh

buildah build-using-dockerfile --format=docker -t openjdk18-openshift-obank:1.0 .
podman tag openjdk18-openshift-obank:1.0 dmyoprg01.dev.myopas.cloud:5000/redhat-openjdk-18/openjdk18-openshift-obank:1.0
podman tag openjdk18-openshift-obank:1.0 dmyoprg01.dev.myopas.cloud:5000/redhat-openjdk-18/openjdk18-openshift-obank:latest
podman push dmyoprg01.dev.myopas.cloud:5000/redhat-openjdk-18/openjdk18-openshift-obank:1.0
podman push dmyoprg01.dev.myopas.cloud:5000/redhat-openjdk-18/openjdk18-openshift-obank:latest
```

## Custom image using Dockerfile for EAP7 image 

```
# cat Dockerfile

FROM dmybprg01.dev.mybpas.cloud:5000/jboss-eap-7/jbosseap72-jenniferapm:1.0

USER root

ADD packages /opt/packages/
RUN yum localinstall -y /opt/packages/*
#RUN localedef -c -f EUC-KR -i ko_KR ko_KR.EUC-KR
RUN localedef -c -f UTF-8 -i ko_KR ko_KR.UTF-8
#ENV LANG ko_KR.EUC-KR

RUN mkdir -p /deployments/bxmApps/
RUN mkdir /data
ADD jdbc /opt/eap/modules/system/layers/base/com/oracle/jdbc
ADD safenet2 /opt/eap/modules/system/layers/base/safenet2/
#ADD innorules /opt/eap/moduls/syste/layers/base/innorules/
ADD jar /usr/lib/jvm/java-1.8.0-openjdk/jre/lib/security/policy/unlimited
ADD jar /usr/lib/jvm/java-1.8.0-openjdk/jre/lib/security/policy/limited/
ADD safenet /opt/safenet/
ADD launch /opt/eap/bin/launch/
ADD jvm /opt/jboss/container/java/jvm
ADD openshift-launch.sh /opt/eap/bin/
ADD standalone.conf /opt/eap/bin
ADD standalong-openshift.xml /opt/eap/standalong/configuration/
#ADD war /tmp/src/
#ADD yl-srvc.par /deployments/apps/
#ADD war/jacorb-2.3.2-redhat-2.jar /deployments/

ADD src/bxm/ /opt/eap/modules/system/layers/base/com/bxm/
ADD src/bxmspring/ /opt/eap/modules/system/layers/base/com/bxmspring/
ADD src/bxmengine/ /opt/eap/modules/system/layers/base/com/bxmengine/
#ADD src/oracle/ /opt/eap/moduls/system/layers/base/com/oracle/
#ADD src/WEB-INF/ /deployments/WEB-INF/

RUN chown -R jboss:root /opt/eap/modules/system/layers/base/com/oracle && \
chown -R jboss:root /opt/eap/modules/system/layers/base/safenet2 && \
chown -R jboss:root /opt/eap/bin/launch && \
chown -R jboss:root /opt/jboss/container/java/jvm && \
rm -rf /opt/eap/docs/examples && rm -rf /opt/eap/welcome-content && \
chown -R jboss:root /opt/safenet

RUN chown jboss:root /opt/eap/bin/openshift-launch.sh && \
chown jboss:root /opt/eap/bin/standalone.conf && \
chown jboss:root /opt/eap/standalone/configuration/standalone-openshift.xml
RUN mkdir dsleetest

USER 185
CMD ["/opt/eap/bin/openshift-launch.sh"]
```

## 이미지스트림 

```
apiVersion: image.openshift.io/v1
kind: ImageStream
metadata:
  annotatinos:
    openshift.io/display-name: Red Hat OpenJDK 8 - Open Banking
    openshift.io/provider-display-name: Red Hat, Inc.
  Name: redhat-openjdk18-openshift-obank
  namespace: openshift
spec:
  lookupPolicy:
    local: false
  tags:
  - annotations:
      description: Build and run Java applications using Maven and OpenJDK 8.
      iconClass: icon-rh-openjdk
      openshift.io/display-name: Red Hat OpenJDK 8 - Open Banking
      sampleContextDir: undertow-servlet
      sampleRepo: https://github.com/jboss-openshift/openshift-quicstarts
      supports: java:8
      tags: builder,java,openjdk,hidden
      version: "1.0"
    from
      find: DockerImage
      name: dmyoprg01.dev.myopas.cloud:5000/redhat-openjdk-18/openjdk18-openshift-obank:1.0
    importPolicy: {}
    name: "1.0"
    referencePolicy:
      type: Local
  - annotations:
      description: Build and run Java applicaations using Maven and OpenJDK 8.
      iconClass: icon-rh-openjdk
      openshift.io/display-name: Red Hat OpenJDK 9 - Open Banking
      sampleContextDir: undertow-servlet
      sampleRepo: https://github.com/jboss-openshift/openshift-quickstarts
      supports: java:8
      tags: builder,java,openjdk,hidden
      version: latest
    from
      kind: DockerImage
      name: dmyoprg01.dev.myopas.cloud:5000/redhat-openjdk-18/openjdk18-openshift-obank:latest
    importPolicy: {}
    name: latest
    referencePolicy:
      type: Local
```
