## Use case - disable self-provisioner

- add user
```
htpasswd -bB /opt/ocp4/install-20210309/oauth/htpasswd developer developer
oc create secret generic htpass-secret --from-file=/opt/ocp4/install-20210309/oauth/htpasswd --dry-run -o yaml -n openshift-config | oc replace -f -
```

- disable self-provisioner
```
  1. oc describe clusterrolebinding.rbac self-provisioners
  2. oc patch clusterrolebinding.rbac self-provisioners -p '{"subjects": null}'
  3. oc adm policy \
    remove-cluster-role-from-group self-provisioner \
    system:authenticated:oauth
  4. oc patch clusterrolebinding.rbac self-provisioners -p '{ "metadata": { "annotations": { "rbac.authorization.kubernetes.io/autoupdate": "false" } } }'
```

- Access Project admin
  + In the Developer perspective, navigate to the Project view.
  + In the Project page, select the Project Access tab.
  + Click Add Access to add a new row of permissions to the default ones.

- enable self-provisioner
  + ※It takes a few minutes to apply.
```
oc adm policy     add-cluster-role-to-group self-provisioner     system:authenticated:oauth
oc patch clusterrolebinding.rbac self-provisioners -p '{ "metadata": { "annotations": { "rbac.authorization.kubernetes.io/autoupdate": "true" } } }'
```
