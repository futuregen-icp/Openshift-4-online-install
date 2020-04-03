# openldap install

## 구성 요소

openldap + phpldapadmin + nginx 구성 
openldap :   디렉토리 인증 서비스 
phpldapadmin  :  openldap의 web base ui
nginx : phpldapadmin   proxy 서비스 

## TLS 인증서 생성

### 사설 Root CA

    **cd /etc/pki/CA
    echo 0001 > serial
    touch index.txt
    openssl genrsa -aes256 -out /etc/pki/CA/private/ca.key
    openssl req -new -x509 -days 3650 -key /etc/pki/CA/private/ca.key -extensions v3_ca -out /etc/pki/CA/certs/ca.crt**
          Country Name (2 letter code) [XX]:KR
          State or Province Name (full name) []:Seoul
          Locality Name (eg, city) [Default City]:Gurogu
          Organization Name (eg, company) [Default Company Ltd]:Futuregen
          Organizational Unit Name (eg, section) []:ICS
          Common Name (eg, your name or your server's hostname) []:registry.ocp4.igotit.co.kr
          Email Address []:test@test.net

### 사설 도메인 인증서 생성

    **openssl genrsa -out private/registry.ocp4.igotit.co.kr.key
    openssl req -new -key private/registry.ocp4.igotit.co.kr.key -out certs/registry.ocp4.igotit.co.kr.csr**
          You are about to be asked to enter information that will be incorporated
          into your certificate request.
          What you are about to enter is what is called a Distinguished Name or a DN.
          There are quite a few fields but you can leave some blank
          For some fields there will be a default value,
          If you enter '.', the field will be left blank.
          -----
          Country Name (2 letter code) [XX]:KR
          State or Province Name (full name) []:Seoul
          Locality Name (eg, city) [Default City]:Gurogu
          Organization Name (eg, company) [Default Company Ltd]:Futuregen
          Organizational Unit Name (eg, section) []:ICS TEAM
          Common Name (eg, your name or your server's hostname) []:registry.ocp4.igotit.co.kr
          Email Address []:test@test.net
        
          Please enter the following 'extra' attributes
          to be sent with your certificate request
          A challenge password []:
          An optional company name []:
        
        
    **openssl ca -keyfile private/ca.key.pem -cert certs/ca.cert.pem -in certs/registry.ocp4.igotit.co.kr.csr -out certs/registry.ocp4.igotit.co.kr.crt**
          Using configuration from /etc/pki/tls/openssl.cnf
          Enter pass phrase for private/ca.key:
          Check that the request matches the signature
          Signature ok
          Certificate Details:
                  Serial Number: 1 (0x1)
                  Validity
                      Not Before: Apr  2 11:19:26 2020 GMT
                      Not After : Apr  2 11:19:26 2021 GMT
                  Subject:
                      countryName               = KR
                      stateOrProvinceName       = Seoul
                      organizationName          = Futuregen
                      organizationalUnitName    = ICS TEAM
                      commonName                = registry.ocp4.igotit.co.kr
                      emailAddress              = test@test.net
                  X509v3 extensions:
                      X509v3 Basic Constraints:
                          CA:FALSE
                      Netscape Comment:
                          OpenSSL Generated Certificate
                      X509v3 Subject Key Identifier:
                          02:4D:CE:4D:CD:FB:9B:9B:35:43:3D:AF:1C:FD:96:C5:2F:A6:42:30
                      X509v3 Authority Key Identifier:
                          keyid:80:06:75:62:FD:10:6A:D7:5F:B3:00:50:4C:22:31:16:A6:73:8C:B0
        
          Certificate is to be certified until Apr  2 11:19:26 2021 GMT (365 days)
          Sign the certificate? [y/n]:y
        
        
          1 out of 1 certificate requests certified, commit? [y/n]y
          Write out database with 1 new entries
          Data Base Updated
        
    **openssl verify -CAfile certs/ca.crt certs/registry.ocp4.igotit.co.kr.crt**
          certs/registry.ocp4.igotit.co.kr.crt: OK
        
        
    **cd /opt/ldap/certs
    mv registry.ocp4.igotit.co.kr.crt ldap.crt
    mv registry.ocp4.igotit.co.kr.key ldap.key**

### 디피 헬만 파라메타 만들기

    openssl dhparam -out dhparam.pem 4096

# Docker-compose 이용하여 설치

### docker-compose.yml 작성

    **cd /opt/ldap**
    vi docker-compose.yml
        version: '3'
        services:
          openldap:
            image: osixia/openldap:1.3.0
            container_name: openldap
            hostname: "ldap.ocp3-11.fu.te"
            environment:
              LDAP_LOG_LEVEL: "256"
              LDAP_ORGANISATION: "Futuregen Inc."
              LDAP_DOMAIN: "ldap.ocp3-11.fu.te"
              LDAP_BASE_DN: ""
              LDAP_ADMIN_PASSWORD: "admin"
              LDAP_CONFIG_PASSWORD: "config"
              LDAP_READONLY_USER: "false"
              LDAP_RFC2307BIS_SCHEMA: "false"
              LDAP_BACKEND: "mdb"
              LDAP_TLS: "true"
              LDAP_TLS_CRT_FILENAME: "ldap.crt"
              LDAP_TLS_KEY_FILENAME: "ldap.key"
              LDAP_TLS_DH_PARAM_FILENAME: "dhparam.pem"
              LDAP_TLS_CA_CRT_FILENAME: "ca.crt"
              LDAP_TLS_ENFORCE: "false"
              LDAP_TLS_CIPHER_SUITE: "SECURE256:-VERS-SSL3.0"
              LDAP_TLS_PROTOCOL_MIN: "3.1"
              LDAP_TLS_VERIFY_CLIENT: "demand"
              LDAP_REPLICATION: "false"
              KEEP_EXISTING_CONFIG: "false"
              LDAP_REMOVE_CONFIG_AFTER_SETUP: "true"
              LDAP_SSL_HELPER_PREFIX: "ldap"
            tty: true
            stdin_open: true
            volumes:
              - /opt/ldap/data:/var/lib/ldap:z
              - /opt/ldap/conf:/etc/ldap/slapd.d:z
              - /opt/ldap/certs:/container/service/slapd/assets/certs:z
            ports:
              - "389:389"
              - "636:636"
            command: ["--copy-service", "--loglevel", "debug"]
          phpldapadmin:
            image: osixia/phpldapadmin:latest
            container_name: phpldapadmin
            environment:
              PHPLDAPADMIN_LDAP_HOSTS: "openldap"
              PHPLDAPADMIN_HTTPS: "false"
            ports:
              - "8081:80"
            depends_on:
              - openldap

# 운영

    **docker-compose up -d**
        reating network "ldap_default" with the default driver
        Creating openldap ... done
        Creating phpldapadmin ... done
        
    **docker-compose ps**
            Name             Command         State                     Ports
        ---------------------------------------------------------------------------------------
        openldap       /container/tool/run   Up      0.0.0.0:389->389/tcp, 0.0.0.0:636->636/tcp
        phpldapadmin   /container/tool/run   Up      443/tcp, 0.0.0.0:8081->80/tcp
        
    **docker exec openldap ldapsearch -x -H ldap://10.0.0.118 -b dc=ldap,dc=ocp3-11,dc=fu,dc=te -D "cn=admin,dc=ldap,dc=ocp3-11,dc=fu,dc=te" -w admin**
        # extended LDIF
        #
        # LDAPv3
        # base <dc=ldap,dc=ocp3-11,dc=fu,dc=te> with scope subtree
        # filter: (objectclass=*)
        # requesting: ALL
        #
        
        # ldap.ocp3-11.fu.te
        dn: dc=ldap,dc=ocp3-11,dc=fu,dc=te
        objectClass: top
        objectClass: dcObject
        objectClass: organization
        o: Futuregen Inc.
        dc: ldap
        
        # admin, ldap.ocp3-11.fu.te
        dn: cn=admin,dc=ldap,dc=ocp3-11,dc=fu,dc=te
        objectClass: simpleSecurityObject
        objectClass: organizationalRole
        cn: admin
        description: LDAP administrator
        userPassword:: e1NTSEF9NFRtREJJQXZYREdva1pnVnZBMkdQY2FYV0Z4cDRMUzQ=
        
        # search result
        search: 2
        result: 0 Success
        
        # numResponses: 3
        # numEntries: 2
    
    **docker-compose down -v**
        Stopping phpldapadmin ... done
        Stopping openldap     ... done
        Removing phpldapadmin ... done
        Removing openldap     ... done