# mirror registry 구성 (옵션)-(restricted natework 필수)

redhat  document (podman으로 구성)

    mkdir /opt/ocp4
    wget [https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz](https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz)
    tar zxvfp openshift-client-linux.tar.gz
    README.md
    oc
    kubectl
    cp -Rp kubectl /usr/local/bin/
    cp -Rp oc /usr/local/bin/

inatall package

    yum -y install podman httpd-tools

Create folders for the registry

    mkdir -p /opt/registry/{auth,certs,data}

Create certificate for the registry

    cd /opt/registry/certs
    openssl req -newkey rsa:4096 -nodes -sha256 -keyout registy.ocp4-1.fu.te.key -x509 -days 365 -out registy.ocp4-1.fu.te.crt
    ...
    Country Name (2 letter code) [XX]:KR
    State or Province Name (full name) []:Seoul
    Locality Name (eg, city) [Default City]:gurogu
    Organization Name (eg, company) [Default Company Ltd]:futuregen
    Organizational Unit Name (eg, section) []:ICS team
    Common Name (eg, your name or your server's hostname) []:registry.ocp4-1.fu.te
    Email Address []:jaesuk.lee@futuregen.co.kr

registry username and password 생성

    htpasswd -bBc /opt/registry/auth/htpasswd admin admin
    cat /opt/registry/auth/htpasswd
    admin:$2y$05$StVswQVO.hVYzkuFuyrrbuyNIY8COy0vaWfq/7MdLQvxLtuaVO/IG

mirror-registry container 생성

    podman run --name mirror-registry -p 5000:5000 \
         -v /opt/registry/data:/var/lib/registry:z \
         -v /opt/registry/auth:/auth:z \
         -e "REGISTRY_AUTH=htpasswd" \
         -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
         -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
         -v /opt/registry/certs:/certs:z \
         -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/registy.ocp4-1.fu.te.crt \
         -e REGISTRY_HTTP_TLS_KEY=/certs/registy.ocp4-1.fu.te.key \
         -d docker.io/library/registry:2

 trust ca 명령 실행 (gateway, bastion 둘다 필요)

    cp /opt/registry/certs/registy.ocp4-1.fu.te.crt /etc/pki/ca-trust/source/anchors/
    update-ca-trust
    
    ## bastion에 인증서 복사
    scp -r /etc/pki/ca-trust/source/anchors/registy.ocp4-1.fu.te.crt 192.168.40.30:/etc/pki/ca-trust/source/anchors/
    ## bastion에서 trust ca 명령 실행 
    update-ca-trust