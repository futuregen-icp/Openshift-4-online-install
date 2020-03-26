# Pullsecerts

### pull-secret down

    https://cloud.redhat.com/openshift/install/metal/user-provisioned pull-secret download
    cd /opt/ocp4.3/pull
    cat ./pull-secret.text | jq .  > pull-secret.json
    
    

### mirror registry 구성시 추가 부분

    mirror-registry 등록 
    echo -n 'admin:admin' | base64 -w0  # admin:admin ( mirror registry 접속 계정 )
    **YWRtaW46YWRtaW4=**
    vi pull-secret.json  (아래 부부분 추가)
        }**,
        "registry.ocp4-1.fu.te" {
          "auth": "YWRtaW46YWRtaW4=",
          "email": "jaesuk.lee@futuregen.co.kr"
        }**
      }
    }

### podman login을 위한 config 설정

    # bastion과 mirror registry 가 구동되는 서버에 설정 
    mkdir /root/.docker
    cp -Rp path/to/pull-secret.json /root/.docker/config.json