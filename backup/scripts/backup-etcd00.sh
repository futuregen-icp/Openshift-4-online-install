cd /root/ocp-backup/backup-etcd00/
ssh core@master1.oss2.fu.igotit.co.kr "sudo rm -rf ./assets/backup/*.*"
ssh core@master1.oss2.fu.igotit.co.kr "sudo /usr/local/bin/cluster-bakcup.sh ./assets/backup/"
ssh core@master1.oss2.fu.igotit.co.kr "sudo chmod -R 775 ./assets/backup/"
scp -r core@master1.oss2.fu.igotit.co.kr:./assets/backup/*" /root/ocp-backup/backup-etcd00/

