FROM registry.redhat.io/jboss-eap-7/eap72-openshift

RUN mkdir /opt/eap/bxmAdmin/ ; \
    mkdir /opt/eap/serviceEndpoint/ ; \
    mkdir /opt/eap/modules/system/layers/base/
    cp -Rp /opt/eap/standalone/ /opt/eap/bxmAdmin/ ; \
    cp -Rp /opt/eap/standalone/ /opt/eap/serviceEndpoint/ ; \
    rm -f /opt/eap/bxmAdmin/deployments
    rm -f /opt/eap/serviceEndpoint/deployments
    mkdir /opt/eap/bxmAdmin/deployments/
    mkdir /opt/eap/serviceEndpoint/deployments/

COPY extensions/ /extensions/

RUN rm -f /opt/eap/bxmAdmin/onfiguration/standalone-openshift.xml ; \
    rm -f /opt/eap/serviceEndpoint/onfiguration/standalone-openshift.xml ; \ 
    cp -dRp /extensions/deployconf/bxmAdmin/configuration/standalone-openshift.xml /opt/eap/bxmAdmin/onfiguration/standalone-openshift.xml ; \
    cp -dRp /extensions/deployconf/serviceEndpoint/configuration/standalone-openshift.xml /opt/eap/serviceEndpoint/onfiguration/standalone-openshift.xml ; \
    cp -dRp /extensions/modules/ /opt/eap/modules/ ; \
    rm -f /opt/eap/bin/openshift-launch.sh ; \
    cp -dRp /extensions/binconf/ /opt/eap/bin/ ; \
    cp -dRp /extensions/bxmmodules/ /opt/eap/modules/system/layers/base/
    cp -dRp /extensions/deploy/bxmAdmin.war /opt/eap/bxmAdmin/deployments/ ; \
    cp -dRp /extensions/deploy/serviceEndpoint.war /opt/eap/serviceEndpoint/deployments/ ; \
    cp -dRp /extensions/deploy/*.par /opt/eap/bxmAdmin/deployments/




COPY configuration /configuration
COPY extensions/ /extensions
COPY extensions/modules /modules

RUN cd /extensions && ./install.sh /extensions




