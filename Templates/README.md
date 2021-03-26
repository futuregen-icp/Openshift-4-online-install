## Template Management


- Backup default templates to yaml files

  + Template lists to file
`oc get template -n openshift | awk '{print $1}' > list.txt`

  + Template yaml output to the file as the all (86 ea)
`for i in $(cat ./list.txt); do 'oc get template $i -n openshift'; done`
