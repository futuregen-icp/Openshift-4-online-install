cd /root/ocp-backup/backup-etcd01/
ssh core@master2.oss2.fu.igotit.co.kr "sudo rm -rf ./assets/backup/*.*"
ssh core@master2.oss2.fu.igotit.co.kr "sudo /usr/local/bin/cluster-backup.sh ./assets/backup/"
ssh core@master2.oss2.fu.igotit.co.kr "sudo chmod -R 755 ./assets/backup/"
scp -r core@master2.oss2.fu.igotit.co.kr:./assets/backup/* /root/ocp-backup/backup-etcd01/
