## Template Managements


- Backup templates to yaml files

  + Template lists to file
`oc get template -n openshift | awk '{print $1}' > list.txt`

  + Template yaml file to the all as 86EA
`for i in $(cat ./list.txt); do 'oc get template $i -n openshift'; done`
