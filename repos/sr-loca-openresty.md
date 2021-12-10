## Service Request
openresty the file as openresty 1.19.91 version to send mail

## Reference download openresty (Officail Home)
https://openresty.org/en/linux-packages.html#rhel


## Online

```
# 1. Configured Repos file as /etc/yum.repos.d/openresty.repo
[root@repo1 ~]# cat openresty.repo 
[openresty]
name=Official OpenResty Open Source Repository for RHEL
baseurl=https://openresty.org/package/rhel/$releasever/$basearch
skip_if_unavailable=False
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://openresty.org/package/pubkey.gpg
enabled=1
enabled_metadata=1


# 2. Yum update check
[root@repo1 ~]# yum check-update
Loaded plugins: product-id, search-disabled-repos, subscription-manager
openresty                                                                         | 2.9 kB  00:00:00     
openresty/7Server/x86_64/primary_db                                               |  76 kB  00:00:00     

nss.x86_64                                   3.67.0-4.el7_9                            rhel-7-server-rpms
nss-sysinit.x86_64                           3.67.0-4.el7_9                            rhel-7-server-rpms
nss-tools.x86_64                             3.67.0-4.el7_9                            rhel-7-server-rpms

# 3. Yun installation
yum install openresty
```

## Disconnected 
1. 레포 다운 (etc. 400 M)
```
# example 
reposync --gpgcheck -lm --repoid=openresty --download_path=/var/www/html/openresty

# Refer. for uncheck gpg key
reposync -lm --repoid=openresty --download_path=/path/to/
```

2. 레포를 구성하려는 서버로 압축하여 이동
3. 레포를 구성하려는 서버에서 압축해제 및 이동

4. Create Repo on repo server
```
Createrepo -v /path/to/openresty -o /path/to/openresty
reposync --gpgcheck -lm --repoid=openresty --download_path=/var/www/html/openresty

# Install package
yum install createrepo
```

5. Configure repo file on Client server 
```
[root@repo1 yum.repos.d]# cat openresty.repo 
[openresty]
name=Official OpenResty Open Source Repository for RHEL
baseurl=http://192.168.5.151/repos/openresty
skip_if_unavailable=False
gpgcheck=0
repo_gpgcheck=0
enabled=1
```
