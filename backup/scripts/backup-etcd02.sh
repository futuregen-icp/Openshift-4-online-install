cd /root/ocp-backup/backup-etcd02/
ssh core@master3.oss2.fu.igotit.co.kr "sudo rm -rf ./assets/backup/*.*"
ssh core@master3.oss2.fu.igotit.co.kr "sudo /usr/local/bin/cluster-backup.sh ./assets/backup/"
ssh core@master3.oss2.fu.igotit.co.kr "sudo chmod -R 753 ./assets/bakcup/"
scp -r core@master3.oss2.fu.igotit.co.kr:./assets/backup/* /root/ocp-bakcup/backup-etcd01/
