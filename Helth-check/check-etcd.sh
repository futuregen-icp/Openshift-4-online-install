while (true)
do
  oc rsh -n openshift-etcd etcd-master1.oss2.fu.igotit.co.kr etcdctl endpoint status --cluster -w table >> `hostname`-etcd-health.txt
  oc rsh -n openshift-etcd etcd-master1.oss2.fu.igotit.co.kr etcdctl endpoint health --cluster -w table >> `hostname`-etcd-health.txt
  oc rsh -n openshift-etcd etcd-master1.oss2.fu.igotit.co.kr etcdctl member list >> `hostname`-etcd-health.txt
  date >> `hostname`-etcd-health.txt
  sleep 30
done
