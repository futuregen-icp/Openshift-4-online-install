# GlusterFS 구축 - single node

This wiki is built in Notion. Here are all the tips you need to contribute.

# Openshift 테스트를 위한 GlusterFS  구축

## 정보

IP : 10.0.0.118
SPEC  :  core : 2 
             memory : 8GB
             Disk  : OS : 160GB
                        Data1 : 500GB
                        Data2 : 500GB

## 설치 방법

### 사전 구성

    ## gluster repo 등록 
    yum install centos-release-gluster
    Loaded plugins: fastestmirror, langpacks
    Loading mirror speeds from cached hostfile
     * base: mirror.navercorp.com
     * extras: mirror.navercorp.com
     * updates: mirror.navercorp.com
    Resolving Dependencies
    --> Running transaction check
    ---> Package centos-release-gluster7.noarch 0:1.0-2.el7.centos will be installed
    --> Processing Dependency: centos-release-storage-common for package: centos-release-gluster7-1.0-2.el7.centos.noarch
    --> Running transaction check
    ---> Package centos-release-storage-common.noarch 0:2-2.el7.centos will be installed
    --> Finished Dependency Resolution
    
    Dependencies Resolved
    
    =====================================================================================================================================================================================
     Package                                                   Arch                               Version                                       Repository                          Size
    =====================================================================================================================================================================================
    Installing:
     centos-release-gluster7                                   noarch                             1.0-2.el7.centos                              extras                             5.2 k
    Installing for dependencies:
     centos-release-storage-common                             noarch                             2-2.el7.centos                                extras                             5.1 k
    
    Transaction Summary
    =====================================================================================================================================================================================
    Install  1 Package (+1 Dependent package)
    
    Total download size: 10 k
    Installed size: 2.4 k
    Is this ok [y/d/N]: y
    Downloading packages:
    (1/2): centos-release-gluster7-1.0-2.el7.centos.noarch.rpm                                                                                                    | 5.2 kB  00:00:00
    (2/2): centos-release-storage-common-2-2.el7.centos.noarch.rpm                                                                                                | 5.1 kB  00:00:00
    -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    Total                                                                                                                                                 73 kB/s |  10 kB  00:00:00
    Running transaction check
    Running transaction test
    Transaction test succeeded
    Running transaction
      Installing : centos-release-storage-common-2-2.el7.centos.noarch                                                                                                               1/2
      Installing : centos-release-gluster7-1.0-2.el7.centos.noarch                                                                                                                   2/2
      Verifying  : centos-release-gluster7-1.0-2.el7.centos.noarch                                                                                                                   1/2
      Verifying  : centos-release-storage-common-2-2.el7.centos.noarch                                                                                                               2/2
    
    Installed:
      centos-release-gluster7.noarch 0:1.0-2.el7.centos
    
    Dependency Installed:
      centos-release-storage-common.noarch 0:2-2.el7.centos
    
    Complete!
    [root@gluster01 ~]#

    # 디스크 설정 
    parted  /dev/sdb
    parted  /dev/sdc
    GNU Parted 3.1
    Using /dev/sdb
    Welcome to GNU Parted! Type 'help' to view a list of commands.
    (parted) p
    Model: VMware Virtual disk (scsi)
    Disk /dev/sdb: 537GB
    Sector size (logical/physical): 512B/512B
    Partition Table: gpt
    Disk Flags:
    
    Number  Start   End    Size   File system  Name   Flags
     1      17.4kB  537GB  537GB               data1
    
    (parted) q
    
    

    # LVM 설정 
    **pvcreate /dev/sdb1**
      Physical volume "/dev/sdb1" successfully created.
    **pvcreate /dev/sdc1**
      Physical volume "/dev/sdc1" successfully created.
    
    **vgcreate gdata1 /dev/sdb1**
      Volume group "gdata1" successfully created
    **vgcreate gdata2 /dev/sdc1**
      Volume group "gdata2" successfully created
    
    **lvcreate  -L 250G -n data1 -v gdata1**
        Archiving volume group "gdata1" metadata (seqno 1).
        Creating logical volume data1
        Creating volume group backup "/etc/lvm/backup/gdata1" (seqno 2).
        Activating logical volume gdata1/data1.
        activation/volume_list configuration setting not defined: Checking only host tags for gdata1/data1.
        Creating gdata1-data1
        Loading table for gdata1-data1 (253:2).
        Resuming gdata1-data1 (253:2).
        Wiping known signatures on logical volume "gdata1/data1"
        Initializing 4.00 KiB of logical volume "gdata1/data1" with value 0.
      Logical volume "data1" created.
    **lvcreate  -L 250G -n data2 -v gdata2**
        Archiving volume group "gdata2" metadata (seqno 1).
        Creating logical volume data2
        Creating volume group backup "/etc/lvm/backup/gdata2" (seqno 2).
        Activating logical volume gdata2/data2.
        activation/volume_list configuration setting not defined: Checking only host tags for gdata2/data2.
        Creating gdata2-data2
        Loading table for gdata2-data2 (253:3).
        Resuming gdata2-data2 (253:3).
        Wiping known signatures on logical volume "gdata2/data2"
        Initializing 4.00 KiB of logical volume "gdata2/data2" with value 0.
      Logical volume "data2" created.
    
    **mkfs.xfs /dev/mapper/gdata1-data1
    mkfs.xfs /dev/mapper/gdata2-data2
    
    mount /dev/gdata1/data1 /gluster01/data1/
    mount /dev/gdata1/data2 /gluster01/data2**
    
    # blkid
    /dev/mapper/centos-root: UUID="1625e3bf-5954-47b7-800d-6619955ee132" TYPE="xfs"
    /dev/sda2: UUID="VfnqvZ-dNGj-wBST-90Q5-DlGR-N9Oq-eXmydj" TYPE="LVM2_member"
    /dev/sda1: UUID="eab26850-f53c-4bfb-94a3-41cda8809255" TYPE="xfs"
    /dev/sdb1: UUID="OfLBcY-SZUf-k57H-t3cv-tz7E-3UTh-dbhNUg" TYPE="LVM2_member" PARTLABEL="data1" PARTUUID="beb94d74-3d76-4dd8-8787-943a68f54a7c"
    /dev/sdc1: UUID="TqREiR-cuDp-t22p-60Xs-i7EI-hkpY-xWczXs" TYPE="LVM2_member" PARTLABEL="date2" PARTUUID="7372572f-bce7-4bd5-9ec3-8f19afd6522f"
    /dev/mapper/centos-swap: UUID="57111180-d0ff-4253-a5d4-fcd2a1d463ae" TYPE="swap"
    **/dev/mapper/gdata1-data1: UUID="8f6a6e5d-6310-4f8e-b287-6f7f6870131c" TYPE="xfs"
    /dev/mapper/gdata2-data2: UUID="4efb0091-59de-4bbf-98bb-38eca5f3bfc5" TYPE="xfs"
    
    ## fstab추가 
    UUID=8f6a6e5d-6310-4f8e-b287-6f7f6870131c       /gluster01/data1        xfs     defaluts        0 0
    UUID=4efb0091-59de-4bbf-98bb-38eca5f3bfc5       /gluster01/data2        xfs     defaluts        0 0**

## Gluster 설치 및 구성

### Gluster 설치

    # **yum install gluster***
    ....
    Dependencies Resolved
    =====================================================================================================================================================================================
     Package                                                     Arch                           Version                                    Repository                               Size
    =====================================================================================================================================================================================
    Installing:
     gluster-block                                               x86_64                         0.3-2.el7                                  centos-gluster7                          85 k
     glusterfs                                                   x86_64                         7.4-1.el7                                  centos-gluster7                         639 k
     glusterfs-api                                               x86_64                         7.4-1.el7                                  centos-gluster7                         113 k
     glusterfs-api-devel                                         x86_64                         7.4-1.el7                                  centos-gluster7                          50 k
     glusterfs-cli                                               x86_64                         7.4-1.el7                                  centos-gluster7                         198 k
     glusterfs-client-xlators                                    x86_64                         7.4-1.el7                                  centos-gluster7                         850 k
     glusterfs-cloudsync-plugins                                 x86_64                         7.4-1.el7                                  centos-gluster7                          51 k
     glusterfs-coreutils                                         x86_64                         0.2.0-1.el7                                centos-gluster7                          58 k
     glusterfs-devel                                             x86_64                         7.4-1.el7                                  centos-gluster7                         176 k
     glusterfs-events                                            x86_64                         7.4-1.el7                                  centos-gluster7                          67 k
     glusterfs-extra-xlators                                     x86_64                         7.4-1.el7                                  centos-gluster7                          63 k
     glusterfs-fuse                                              x86_64                         7.4-1.el7                                  centos-gluster7                         156 k
     glusterfs-geo-replication                                   x86_64                         7.4-1.el7                                  centos-gluster7                         216 k
     glusterfs-libs                                              x86_64                         7.4-1.el7                                  centos-gluster7                         425 k
     glusterfs-rdma                                              x86_64                         7.4-1.el7                                  centos-gluster7                          68 k
     glusterfs-resource-agents                                   noarch                         7.4-1.el7                                  centos-gluster7                          38 k
     glusterfs-server                                            x86_64                         7.4-1.el7                                  centos-gluster7                         1.3 M
     glusterfs-thin-arbiter                                      x86_64                         7.4-1.el7                                  centos-gluster7                          50 k
    Installing for dependencies:
     cifs-utils                                                  x86_64                         6.2-10.el7                                 base                                     85 k
     cups-libs                                                   x86_64                         1:1.6.3-40.el7                             base                                    358 k
     gssproxy                                                    x86_64                         0.7.0-26.el7                               base                                    110 k
     keyutils                                                    x86_64                         1.5.8-3.el7                                base                                     54 k
     libacl-devel                                                x86_64                         2.2.51-14.el7                              base                                     72 k
     libattr-devel                                               x86_64                         2.4.46-13.el7                              base                                     35 k
     libbasicobjects                                             x86_64                         0.1.1-32.el7                               base                                     26 k
     libcollection                                               x86_64                         0.7.0-32.el7                               base                                     42 k
     libevent                                                    x86_64                         2.0.21-4.el7                               base                                    214 k
     libibverbs                                                  x86_64                         22.1-3.el7                                 base                                    267 k
     libini_config                                               x86_64                         1.3.1-32.el7                               base                                     64 k
     libldb                                                      x86_64                         1.4.2-1.el7                                base                                    144 k
     libnfsidmap                                                 x86_64                         0.25-19.el7                                base                                     50 k
     libpath_utils                                               x86_64                         0.2.1-32.el7                               base                                     28 k
     librdmacm                                                   x86_64                         22.1-3.el7                                 base                                     63 k
     libref_array                                                x86_64                         0.1.5-32.el7                               base                                     27 k
     libtalloc                                                   x86_64                         2.1.14-1.el7                               base                                     32 k
     libtcmu                                                     x86_64                         1.3.0-0.2rc4.el7                           centos-gluster7                          41 k
     libtdb                                                      x86_64                         1.3.16-1.el7                               base                                     48 k
     libtevent                                                   x86_64                         0.9.37-1.el7                               base                                     40 k
     libuuid-devel                                               x86_64                         2.23.2-61.el7_7.1                          updates                                  92 k
     libverto-libevent                                           x86_64                         0.2.5-4.el7                                base                                    8.9 k
     libwbclient                                                 x86_64                         4.9.1-10.el7_7                             updates                                 111 k
     nfs-utils                                                   x86_64                         1:1.3.0-0.65.el7                           base                                    412 k
     pyparsing                                                   noarch                         1.5.6-9.el7                                base                                     94 k
     python-backports                                            x86_64                         1.0-8.el7                                  base                                    5.8 k
     python-backports-ssl_match_hostname                         noarch                         3.5.0.1-1.el7                              base                                     13 k
     python-configshell                                          noarch                         1:1.1.fb25-1.el7                           base                                     68 k
     python-ethtool                                              x86_64                         0.8-8.el7                                  base                                     34 k
     python-ipaddress                                            noarch                         1.0.16-2.el7                               base                                     34 k
     python-kmod                                                 x86_64                         0.9-4.el7                                  base                                     57 k
     python-prettytable                                          noarch                         0.7.2-3.el7                                base                                     37 k
     python-requests                                             noarch                         2.6.0-9.el7_7                              updates                                  94 k
     python-rtslib                                               noarch                         2.1.fb69-3.el7                             base                                    102 k
     python-urllib3                                              noarch                         1.10.2-7.el7                               base                                    103 k
     python-urwid                                                x86_64                         1.1.1-3.el7                                base                                    654 k
     python2-gluster                                             x86_64                         7.4-1.el7                                  centos-gluster7                          42 k
     rdma-core                                                   x86_64                         22.1-3.el7                                 base                                     50 k
     resource-agents                                             x86_64                         4.1.1-30.el7_7.7                           updates                                 453 k
     samba-client-libs                                           x86_64                         4.9.1-10.el7_7                             updates                                 4.9 M
     samba-common                                                noarch                         4.9.1-10.el7_7                             updates                                 210 k
     samba-common-libs                                           x86_64                         4.9.1-10.el7_7                             updates                                 171 k
     targetcli                                                   noarch                         2.1.fb49-1.el7                             base                                     68 k
     tcmu-runner                                                 x86_64                         1.3.0-0.2rc4.el7                           centos-gluster7                          66 k
     tcmu-runner-handler-glfs                                    x86_64                         1.3.0-0.2rc4.el7                           centos-gluster7                          12 k
     userspace-rcu                                               x86_64                         0.10.0-3.el7                               centos-gluster7                          93 k
    Updating for dependencies:
     libblkid                                                    x86_64                         2.23.2-61.el7_7.1                          updates                                 181 k
     libmount                                                    x86_64                         2.23.2-61.el7_7.1                          updates                                 183 k
     libsmartcols                                                x86_64                         2.23.2-61.el7_7.1                          updates                                 141 k
     libuuid                                                     x86_64                         2.23.2-61.el7_7.1                          updates                                  83 k
     util-linux                                                  x86_64                         2.23.2-61.el7_7.1                          updates                                 2.0 M
    
    Transaction Summary
    =====================================================================================================================================================================================
    Install  18 Packages (+46 Dependent packages)
    Upgrade              (  5 Dependent packages)
    ...

### Gluster 실행

    # **systemctl start glusterd**
    # **systemctl enable glusterd**
    # **systemctl status glusterd**
    ● glusterd.service - GlusterFS, a clustered file-system server
       Loaded: loaded (/usr/lib/systemd/system/glusterd.service; enabled; vendor preset: enabled)
       Active: active (running) since Mon 2020-03-30 10:30:30 KST; 36min ago
         Docs: man:glusterd(8)
     Main PID: 17355 (glusterd)
       CGroup: /system.slice/glusterd.service
               ├─17355 /usr/sbin/glusterd -p /var/run/glusterd.pid --log-level INFO
               └─17684 /usr/sbin/glusterfsd -s gluster01 --volfile-id distributed-volume.gluster01.gluster01-data1-distvol -p /var/run/gluster/vols/distributed-volume/gluster01-glust...
    
    Mar 30 10:30:29 gluster01 systemd[1]: Starting GlusterFS, a clustered file-system server...
    Mar 30 10:30:30 gluster01 systemd[1]: Started GlusterFS, a clustered file-system server.

### Gluster 설정

    ## volume 생성 (단순 볼륨 생성 : 볼륨 이름 ㅣ **distributed-volume** )
    **gluster volume create distributed-volume gluster01:/gluster01/data1/distvol**
    	volume create: distributed-volume: success: please start the volume to access data
    
    ## gluster 볼륨 확인 
    **gluster volume info**
    	Volume Name: distributed-volume
    	Type: Distribute
    	Volume ID: 1a02b3d0-fbf0-42a9-bab1-985dbbde0b7e
    	Status: Created
    	Snapshot Count: 0
    	Number of Bricks: 1
    	Transport-type: tcp
    	Bricks:
    	Brick1: gluster01:/gluster01/data1/distvol
    	Options Reconfigured:
    	transport.address-family: inet
    	storage.fips-mode-rchecksum: on
    	nfs.disable: on
    
    ## distributed-volume 구동 
    **gluster volume start distributed-volume**
    volume start: distributed-volume: success

### Gluster 마운트 방법

    # repo 등록 
    **yum install centos-release-gluster**
    
    # client 설치 
    **yum install glusterfs-client**
    
    # mount 위치 선정 
    **mkdir /glusterfs**
    
    # mount 
    **mount -t glusterfs gluster01:distributed-volume /glusterfs**
    
    # 확인
    **df -h**
    Filesystem                    Size  Used Avail Use% Mounted on
    /dev/mapper/centos-root       152G  2.1G  150G   2% /
    devtmpfs                      3.9G     0  3.9G   0% /dev
    tmpfs                         3.9G     0  3.9G   0% /dev/shm
    tmpfs                         3.9G  8.9M  3.9G   1% /run
    tmpfs                         3.9G     0  3.9G   0% /sys/fs/cgroup
    /dev/sda1                    1014M  209M  806M  21% /boot
    tmpfs                         783M     0  783M   0% /run/user/0
    /dev/mapper/gdata1-data1      250G   33M  250G   1% /gluster01/data1
    /dev/mapper/gdata2-data2      250G   33M  250G   1% /gluster01/data2
    **gluster01:distributed-volume  250G  2.6G  248G   2% /glusterfs**

## 참고 사항

### Gluster에서 사용가능한 볼륨 구성

    Distributed - 분산 파일 시스템 / 복제(무)
    Replicated  - 분산 파일 시스템(무) / 복제
    Striped     - 큰파일 및 동시접속 이 매우 높은 경우
    Distributed Striped - 큰파일 및 동시접속 이 매우 높은 경우 / 확장성
    Distributed Replicated - 분산파일시스템 / 복제 
    Distributed Replicated Replicated  - 동시접속 이 매우 높고 / 복제 (map reduce 업무에 지원)
    Striped Replicated -동시접속 이 매우 높고 /복제 (map reduce 업무에 지원)