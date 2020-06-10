


> 

## 1. 시스템 requirements
**provisioning server**

     - ansible 실행 가능한 서버
     - kubeconfig 파일
     - worker node에 대한 ssh 접근 권한

**worker node**

     - Base OS: [RHEL 7.6]   
       Only RHEL 7.6 is supported in OpenShift
     - NetworkManager 1.0 or later
     - 1 vCPU.
     - Minimum 8 GB RAM.
     - 20GB hard disk

## 2. 사전 준비

**provisioning server**

    subscription-manager register --username=qingsong1989 --password=<password>
    subscription-manager refresh
    subscription-manager list --available --matches '*OpenShift*'
    subscription-manager attach --pool=<pool_id>
    
    # repositories 등록
    subscription-manager repos \
    --enable="rhel-7-server-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-ansible-2.8-rpms" \
    --enable="rhel-7-server-ose-4.4-rpms"
    
    #ansible oc jq 설치
    yum install openshift-ansible openshift-clients jq

**worker node**

    subscription-manager register --username=qingsong1989 --password=<password>
    subscription-manager refresh
    subscription-manager list --available --matches '*OpenShift*'
    subscription-manager attach --pool=<pool_id>
    
    # clear repositories
    subscription-manager repos --disable="*"
    
    # repositories 등록
    subscription-manager repos \
    --enable="rhel-7-server-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-ose-4.4-rpms"
    
    # repositories 확인
    [root@worker02 ~]# yum repolist
    -----------------------------------
    Loaded plugins: product-id, search-disabled-repos, subscription-manager
    repo id                                        repo name                                                       status
    rhel-7-server-extras-rpms/x86_64               Red Hat Enterprise Linux 7 Server - Extras (RPMs)                1,285
    rhel-7-server-ose-4.4-rpms/x86_64              Red Hat OpenShift Container Platform 4.4 (RPMs)                    118
    rhel-7-server-rpms/7Server/x86_64              Red Hat Enterprise Linux 7 Server (RPMs)                        29,118
    -----------------------------------
    
    #방화벽 오픈 
    systemctl disable --now firewalld.service


   
## 노드 추가 잡억 실행


**provisioning server 에서 실행**

    #kubeconfig 파일 복사
    scp bastion:/opt/ocp4.4/install-`date +%Y%m%d`/auth/kubeconfig /root/.kube/
    
    #inventory 파일 생성
    vi /root/inventory/hosts/inventory.yaml
    --------------------------
    [all:vars]
    ansible_user=root
    #ansible_become=True
    
    openshift_kubeconfig_path="~/.kube/kubeconfig"
    
    [workers]
    worker01.ocp44.fu.com
    
    [new_workers]
    worker02.ocp44.fu.com
    #mycluster-rhel7-3.example.com (다중 노드 추가 시)
    -------------------------
    #ssh key 복사
    ssh-copy-id root@worker02.ocp44.fu.com
    
    #ansible playbook 실행
    ansible-playbook -i /root/inventory/hosts playbooks/scaleup.yml



