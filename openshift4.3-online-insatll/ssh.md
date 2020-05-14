# ssh 인증키 생성

### ssh 인증키 생성

    ## bastion 일반 계정에서 생성
    su - core
    ssh-keygen -t rsa -b 4096 -N ''
    
    ssh-copy-id core@[serverip or hostname]
