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

