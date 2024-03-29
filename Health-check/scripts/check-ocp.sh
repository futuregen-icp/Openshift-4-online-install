ansible -i ~/hosts infra -m shell -a "getenforce"
ansible -i ~/hosts infra -m shell -a "grep ^SELINUX= /etc/selinux/config"
ansible -i ~/hosts infra -m shell -a "systemctl status NetworkManager"
ansible -i ~/hosts infra -m shell -a "cat /etc/redhat-release"
ansible -i ~/hosts infra -m shell -a "uname -r"
ansible -i ~/hosts infra -m shell -a "lscpu"
ansible -i ~/hosts infra -m shell -a "free -m"
ansible -i ~/hosts infra -m shell -a "lsblk"
ansible -i ~/hosts infra -m shell -a "hostname"
ansible -i ~/hosts infra -m shell -a "hostname -f"
ansible -i ~/hosts infra -m shell -a "systemctl get-default"
ansible -i ~/hosts infra -m shell -a "ip a sh"
ansible -i ~/hosts infra -m shell -a "timedatectl"
ansible -i ~/hosts infra -m shell -a "grep ^server /etc/chrony.conf"
ansible -i ~/hosts infra -m shell -a "chronyc sources -v"
ansible -i ~/hosts infra -m shell -a "df -h"
ansible -i ~/hosts infra -m shell -a "systemctl status kubelet"
ansible -i ~/hosts infra -m shell -a "systemctl status crio"
ansible -i ~/hosts infra -m shell -a "cat /etc/resolv.conf"
ansible -i ~/hosts nfs1.oss2.fu.igotit.co.kr -m shell -a "systemctl status nfs"
ansible -i ~/hosts app1.oss2.fu.igotit.co.kr -m shell -a "systemctl status nfs"
ansible -i ~/hosts app2.oss2.fu.igotit.co.kr -m shell -a "systemctl status nfs"
ansible -i ~/hosts app3.oss2.fu.igotit.co.kr -m shell -a "systemctl status nfs"
ansible -i ~/hosts app1.oss2.fu.igotit.co.kr -m shell -a "ls -al /log/openshift"
ansible -i ~/hosts app2.oss2.fu.igotit.co.kr -m shell -a "ls -al /log/openshift"
ansible -i ~/hosts app3.oss2.fu.igotit.co.kr -m shell -a "ls -al /log/openshift"
ansible -i ~/hosts registry.oss2.fu.igotit.co.kr -m shell -a "du -sh /registry"
ansible -i ~/hosts efk1.oss2.fu.igotit.co.kr -m shell -a "du -sh /logging-es"
ansible -i ~/hosts app1.oss2.fu.igotit.co.kr -m shell -a "du -sk /amq"
ansible -i ~/hosts app2.oss2.fu.igotit.co.kr -m shell -a "du -sk /amq"
ansible -i ~/hosts app3.oss2.fu.igotit.co.kr -m shell -a "du -sh /amq"
