#!/bin/sh

NAMESPACE=openshift-ingress

for PODNAME in `oc get pods -n ${NAMESPACE} --no-headers | grep Running | awk '{print $1}'`; do
   for NODENAME in `oc get pods ${PODNAME} -n ${NAMESPACE} -o wide --no-headers -o custom-columns='NODE:{spec.nodeName}'`; do
      echo "${NAMESPACE} : ${PODNAME} : ${NODENAME} "
      ssh ${NODENAME} "sudo ps -ef | grep haproxy | grep -v sudo"
   done
done
