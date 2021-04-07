## Template Management


- Backup default templates to yaml files

  + Template lists to file
`oc get template -n openshift | awk '{print $1}' > list.txt`

  + Template yaml output to the file as the all (86 ea)
`for i in $(cat ./list.txt); do oc get template $i -n openshift -o yaml > $i.yaml ; done`


## Use case 1

- Create apps
```
oc new-app wildfly~https://github.com/jberet/intro-jberet.git
oc rollout status dc/intro-jberet
oc expose svc intro-jberet
oc new-app postgresql-ephemeral --name postgresql --param POSTGRESQL_USER=jberet --param POSTGRESQL_PASSWORD=jberet
oc rollout status dc/postgresql
```

- Run batch and verify check batch
```
curl -s -X POST -H 'Content-Type:application/json' "http://intro-jberet-jberet-lab.2886795295-80-simba02.environments.katacoda.com/intro-jberet/api/jobs/csv2db/start" | python -m json.tool
curl -s http://intro-jberet-jberet-lab.2886795295-80-simba02.environments.katacoda.com/intro-jberet/api/jobexecutions/1 | python -m json.tool
curl -s http://intro-jberet-jberet-lab.2886795295-80-simba02.environments.katacoda.com/intro-jberet/api/jobexecutions/1/stepexecutions/2 | python -m json.tool
curl -s -X POST -H 'Content-Type:application/json' "http://intro-jberet-jberet-lab.2886795295-80-simba02.environments.katacoda.com/intro-jberet/api/jobs/csv2db/start?db.host=x" | python -m json.tool
curl -s http://intro-jberet-jberet-lab.2886795295-80-simba02.environments.katacoda.com/intro-jberet/api/jobexecutions/2 | python -m json.tool
curl -s -X POST -H 'Content-Type:application/json' "http://intro-jberet-jberet-lab.2886795295-80-simba02.environments.katacoda.com/intro-jberet/api/jobexecutions/2/restart?db.host=postgresql" | python -m json.tool
curl -s http://intro-jberet-jberet-lab.2886795295-80-simba02.environments.katacoda.com/intro-jberet/api/jobexecutions/3 | python -m json.tool
curl -s -X POST -H 'Content-Type:application/json' "http://intro-jberet-jberet-lab.2886795295-80-simba02.environments.katacoda.com/intro-jberet/api/jobexecutions/2/stop" | python -m json.tool
```

- Verify check batch
```
oc get pods --selector app=postgresql
POD='oc get pods --selector app=postresql -o custom-columns=name:.metadata.name --no-headers'; echo $POD
oc rsh $POD
psql sampledb jberet
SELECT * FROM MOVIES;
```
