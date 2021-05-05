a.sh
```
#!/bin/bash

PARNAME="addd.par"
WARNAME="SampleWebApp.war"
CONFIG_FILE="standalone-openshift.xml"

## war unpack 
rm -f /opt/eap/standalone/deployments/$WARNAME

mkdir /opt/eap/standalone/deploy
cp -Rp /tmp/src/$WARNAME /opt/eap/standalone/deploy/
cd /opt/eap/standalone/deploy
unzip /opt/eap/standalone/deploy/$WARNAME
mv /opt/eap/standalone/deploy/$WARNAME /home/jboss/

ln -s /opt/eap/standalone/deploy /opt/eap/standalone/deployments/$WARNAME

## par deploy
cp -Rp /tmp/src/$PARNAME  /opt/eap/standalone/deployments/
```


standalone-openshift.xml
```
<deployment-scanner path="deployments" relative-to="jboss.server.base.dir" scan-interval="5000" auto-deploy-exploded="true" runtime-failure-causes-rollback="${jboss.deployment.scanner.rollback.on.failure:false}"/>
```

참고
```
deployment="<deployments><deployment name=\"${WARNAME}\" runtime-name=\"${WARNAME}\"><fs-exploded path=\"/opt/eap/standalone/deployments/$WARNAME\"/></deployment></deployments>"
sed -i "s|<!-- ##DEPLOYMENT_BINDING## -->|${deployment}|" /opt/eap/standalone/configuration/${CONFIG_FILE}
```

```
curl https://raw.githubusercontent.com/locli/test/main/SampleWebApp.war -o SampleWebApp.war
curl https://raw.githubusercontent.com/locli/test/main/addd.par -o addd.par      
```

openshift-lancher.sh (최상단)
```
source $JBOSS_HOME/bin/launch/a.sh
```
  curl http://localhost:8080/SampleWebApp
