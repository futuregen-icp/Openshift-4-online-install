# ftp 설치 (필수)

### package 설치

    yum install vsftpd -y

**anonymous 접속** 

    # /var/ftp/pub/ 기본 접속 디렉토리
    cd /var/ftp/pub/
    wget https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/4.3/latest/rhcos-4.3.0-x86_64-metal.raw.gz

**running**

    systemctl enable vsftpd
    systemctl start vsftpd
    
    curl ftp://<ip or hostname>/pub/