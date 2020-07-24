# NFS - server 구성

### 방화벽 설정

    firewall-cmd --permanent --zone=public --add-service=nfs
    firewall-cmd --permanent --zone=public --add-service=portmapper
    firewall-cmd --permanent --zone=public --add-service=rpc-bind
    firewall-cmd --permanent --zone public --add-service mountd
    filewall-cmd --reload

### selinux 설정

    setsebool -P virt_use_nfs 1
    setsebool -P virt_sandbox_use_nfs 1

### disk device mount

    parted /dev/sdb
    	(parted) mklabel
    	New disk label type? gpt
    	(parted) mkpart
    	Partition name?  []? /data
    	File system type?  [ext2]? xfs
    	Start? 0
    	End? -0
    
    mkfs.xfs /dev/sdb1
    mkdir /data/nfs/registry -p
    echo "UUID=b688463c-cbaa-4676-aedc-054c461ce6b6         /data/nfs/registry               none    defaults   0 0" >> /etc/fstab
    mount -a
    
    chown nfsnobody.nfsnobody /registry -R
    chmod 777 /registry -R

### running

    systemctl start nfs rpcbind
    systemctl enable nfs rpcbind

### NFS export

    cat /etc/exports
    /data/nfs/registry *(rw,root_squash,all_squash)
    
    exportfs -rv 
    /data/nfs/registry *
