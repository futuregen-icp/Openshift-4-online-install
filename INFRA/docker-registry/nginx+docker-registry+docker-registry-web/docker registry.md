# docker registry 구축

This wiki is built in Notion. Here are all the tips you need to contribute.

# docker registry

## nginx + docker-registry + docker-registry-web

docker compose 를 이용하여 컨테이너 그룹으로 사용 

## 구성

- docker registry : id , pass anth
- nginx : 80port expose ,   docker registry web connction :  127.0.0.1:8080
- docker registry web : docker registry connction : ssl protocol

## 디렉토리 구조

    /opt/registry/certs/htpasswd  
                        registry.ocp4.igotit.co.kr.crt  
                        registry.ocp4.igotit.co.kr.csr  
                        registry.ocp4.igotit.co.kr.key
                 /conf/nginx/default.conf
                      /registry-web/config.yml
                 /data
                 /db
                 /docker-compose.yaml

- certs/htpasswd  :  registry  id/pass , registry.ocp4.igotit.co.kr.* 인증서
- /conf/nginx/default.conf : nginx 설정
- /registry-web/config.yml : docker-registry-web 설정
- docker-compose.yaml : 컨테이너 그룹 정의

## 파일 생성 방법

    # htpasswd 생성 방법 
    htpasswd -Bb -c /opt/registry/cert/htpasswd  admin admin
    
    # 인증서 생성방법
    openssl genrsa -out registry.ocp4.igotit.co.kr.key 4096
    openssl req -new -key registry.ocp4.igotit.co.kr.key -out registry.ocp4.igotit.co.kr.csr
    openssl x509 -req -days 3650 -in registry.ocp4.igotit.co.kr.csr -signkey registry.ocp4.igotit.co.kr.key -out registry.ocp4.igotit.co.kr.crt
    cp -r registry.ocp4.igotit.co.kr.crt /etc/pki/ca-trust/source/anchors/registry.ocp4.igotit.co.kr.crt
    update-ca-trust

    # nginx/default.conf
    upstream docker-registry {
        server registry:5000;
    }
    
    upstream docker-registry-web {
        server registry-web:8080;
    }
    
    server {
        server_name localhost;
            listen 80;
    
    #    *** for https support uncomment following lines ***
    #    listen 443 ssl;
    #
    #    # SSL keys
    #    ssl_certificate     /etc/nginx/ssl.cert;
    #    ssl_certificate_key /etc/nginx/ssl.key;
    #
    #    # Recommendations from https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
    #    ssl_protocols TLSv1.1 TLSv1.2;
    #    ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
    #    ssl_prefer_server_ciphers on;
    #    ssl_session_cache shared:SSL:10m;
    
    
        # disable any limits to avoid HTTP 413 for large image uploads
        client_max_body_size 0;
    
        # required to avoid HTTP 411: see Issue #1486 (https://github.com/docker/docker/issues/1486)
        chunked_transfer_encoding on;
    
        location /v2/ {
          # Do not allow connections from docker 1.5 and earlier
          # docker pre-1.6.0 did not properly set the user agent on ping, catch "Go *" user agents
          if ($http_user_agent ~ "^(docker\/1\.(3|4|5(?!\.[0-9]-dev))|Go ).*\$" ) {
            return 404;
          }
    
          proxy_pass                          http://docker-registry;
          proxy_set_header  Host              $http_host;   # required for docker client's sake
          proxy_set_header  X-Real-IP         $remote_addr; # pass on real client's IP
          proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
          proxy_set_header  X-Forwarded-Proto $scheme;
          proxy_read_timeout                  900;
        }
    
        location / {
          proxy_pass                          http://docker-registry-web;
          proxy_set_header  Host              $http_host;
          proxy_set_header  X-Real-IP         $remote_addr; # pass on real client's IP
          proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
          proxy_set_header  X-Forwarded-Proto $scheme;
        }
    }

    # registry-web/config.yml
    registry:
      # Docker registry url
      url: https://registry.ocp4.igotit.co.kr:5000/v2
      # Docker registry fqdn
      name: localhost:5000
      # To allow image delete, should be false
      readonly: false
      auth:
        # Disable authentication
        enabled: false

    REGISTRY_BASIC_AUTH
      echo -n "admin:admin" | base64
    # /docker-compose.yaml
    version: "3.3"
    services:
      nginx:
        image: nginx:1.10
        ports:
          - 80:80
        volumes:
           - /opt/registry/conf/nginx:/etc/nginx/conf.d/:z
        depends_on:
          - registry
          - registry-web
      registry-web:
        image: hyper/docker-registry-web:latest
        ports:
          - 127.0.0.1:8080:8080
        environment:
          REGISTRY_URL: https://registry.ocp4.igotit.co.kr:5000/v2
          REGISTRY_TRUST_ANY_SSL: 1
          REGISTRY_BASIC_AUTH: "YWRtaW46YWRtaW4="
          REGISTRY_NAME: registry.ocp4.igotit.co.kr:5000
        volumes:
           - /opt/registry/db:/data:z
        depends_on:
           - registry
      registry:
        container_name: 'registry'
        restart: always
        image: registry
        privileged: true
        ports:
          - 5000:5000
        environment:
          TZ: "korea/seoul"
          REGISTRY_AUTH: htpasswd
          REGISTRY_AUTH_HTPASSWD_PATH: /certs/htpasswd
          REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
          REGISTRY_STORAGE_DELETE_ENABLED: "true"
          REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY: /data/registry
          REGISTRY_HTTP_TLS_CERTIFICATE: /certs/registry.ocp4.igotit.co.kr.crt
          REGISTRY_HTTP_TLS_KEY: /certs/registry.ocp4.igotit.co.kr.key
        volumes:
          - /opt/registry/data:/var/lib/registry:z
          - /opt/registry/certs:/certs:z

## Running

    $ docker-compose up -d
    Creating network "registry_default" with the default driver
    Creating registry ... done
    Creating registry_registry-web_1 ... done
    Creating registry_nginx_1        ... done

## Stopping

    $ docker-compose down -v
    Stopping registry_nginx_1        ... done
    Stopping registry_registry-web_1 ... done
    Stopping registry                ... done
    Removing registry_nginx_1        ... done
    Removing registry_registry-web_1 ... done
    Removing registry                ... done
    Removing network registry_default

## 구동후 확인 방법

    ## docker 명령어로 확인
    $ docker ps
    CONTAINER ID        IMAGE                              COMMAND                  CREATED             STATUS              PORTS                         NAMES
    409b64629d84        nginx:1.10                         "nginx -g 'daemon of…"   9 seconds ago       Up 7 seconds        0.0.0.0:80->80/tcp, 443/tcp   registry_nginx_1
    3d9e65ea59b9        hyper/docker-registry-web:latest   "start.sh"               9 seconds ago       Up 8 seconds        127.0.0.1:8080->8080/tcp      registry_registry-web_1
    9a2c20dedbf3        registry                           "/entrypoint.sh /etc…"   10 seconds ago      Up 9 seconds        0.0.0.0:5000->5000/tcp        registryYou can add code notation to any Notion page:
    
    ## docker-compose로 확인 
    $ docker-compose top
    registry
    UID     PID    PPID    C   STIME   TTY     TIME                          CMD
    --------------------------------------------------------------------------------------------------
    root   13095   13079   0   06:36   ?     00:00:00   registry serve /etc/docker/registry/config.yml
    
    registry_nginx_1
    UID     PID    PPID    C   STIME   TTY     TIME                        CMD
    ----------------------------------------------------------------------------------------------
    root   13279   13263   0   06:36   ?     00:00:00   nginx: master process nginx -g daemon off;
    104    13327   13279   0   06:36   ?     00:00:00   nginx: worker process
    
    registry_registry-web_1
    UID     PID    PPID    C    STIME   TTY     TIME                                                                               CMD
    ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    root   13183   13166   37   06:36   ?     00:00:51   /usr/lib/jvm/java-7-openjdk-amd64/bin/java -Djava.util.logging.config.file=/var/lib/tomcat7/conf/logging.properties
                                                         -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.security.egd=file:/dev/./urandom -Dcontext.path=
                                                         -Djava.endorsed.dirs=/usr/share/tomcat7/endorsed -classpath /usr/share/tomcat7/bin/bootstrap.jar:/usr/share/tomcat7/bin/tomcat-juli.jar
                                                         -Dcatalina.base=/var/lib/tomcat7 -Dcatalina.home=/usr/share/tomcat7 -Djava.io.tmpdir=/var/lib/tomcat7/temp org.apache.catalina.startup.Bootstrap start
    $ docker-compose ps
             Name                        Command               State              Ports
    ----------------------------------------------------------------------------------------------
    registry                  /entrypoint.sh /etc/docker ...   Up      0.0.0.0:5000->5000/tcp
    registry_nginx_1          nginx -g daemon off;             Up      443/tcp, 0.0.0.0:80->80/tcp
    registry_registry-web_1   start.sh                         Up      127.0.0.1:8080->8080/tcp

- 

![docker%20registry/Untitled.png](docker%20registry/Untitled.png)