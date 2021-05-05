## s2i - template 
```
oc get template eap72-basic-s2i -o yaml
- apiVersion: v1
  kind: DeploymentConfig
...
      spec:
        containers:
        - env:
...
          - name: JAVA_OPTS
            value: ${JAVA_OPTS}
...
parameters:
...
- name: JAVA_OPTS
  value: -Dbxm.node.name=DFT1 -Dbxm.instance.name=bxmAdmin -Doracle.jdbc.autoCommitSpecCompliant=false -Djboss.modules.system.pkgs=org.jboss.byteman,org.jboss.logmanager
