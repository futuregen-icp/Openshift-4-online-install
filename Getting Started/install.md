# install 파일 구성

### install dir  설정

    mkdir /opt/ocp4.3
    chown core.core /opt/ocp4.3 -R
    su - core
    mkdir /opt/ocp4.3/install-`date +%Y%m%d$h`
    cd /opt/ocp4.3

### install-config.yaml 생성 - online

    apiVersion: v1
    baseDomain: fu.te
    compute:
    - hyperthreading: Enabled
      name: worker
      replicas: 0
    controlPlane:
      hyperthreading: Enabled
      name: master
      replicas: 3
    metadata:
      name: ocp4-1
    networking:
      clusterNetwork:
      - cidr: 10.136.0.0/14
        hostPrefix: 23
      networkType: OpenShiftSDN
      serviceNetwork:
      - 172.36.0.0/16
    platform:
      none: {}
    fips: false
    pullSecret: '{"auths":{"cloud.openshift.com":{"auth":"b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K2xvY2xpNTQyNzF5Z2pzd2dweWlhNWwzZHh3ajlqeHF3YnM3cDpCNlZCVUFPVkNFV1dJOTNFMjRIQ1RWUjlRSzFXVUdYSEQ2V0YzMUdHRDFVQkxXU0hVQjIzUzcxUkFWTDYwRjUw","email":"jaesuk.lee@futuregen.co.kr"},"quay.io":{"auth":"b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K2xvY2xpNTQyNzF5Z2pzd2dweWlhNWwzZHh3ajlqeHF3YnM3cDpCNlZCVUFPVkNFV1dJOTNFMjRIQ1RWUjlRSzFXVUdYSEQ2V0YzMUdHRDFVQkxXU0hVQjIzUzcxUkFWTDYwRjUw","email":"jaesuk.lee@futuregen.co.kr"},"registry.connect.redhat.com":{"auth":"NTMyMjcyMDB8dWhjLTFZZ2pTd0dweWlBNWwzZFhXSjlqeHFXQlM3UDpleUpoYkdjaU9pSlNVelV4TWlKOS5leUp6ZFdJaU9pSmlORFJrTVdSaVlqQm1NbVUwTnpZMk9XTXhNbUkxWW1Rd09EWmpZek5tWWlKOS5IMmdaTUktNHJIblVUMG5SeHQtRk5LVTVRcFhlUGtxM3N2X3FpZ1RuUXdWeV9zelZrS0V0UWR0X2VWSUh6dmdNdjRwTHY4UUhnWjlBQUgxSVI5WFh4aWxBRnZIcW9qZHV5anlSTVlGcW1EUFlpNllKNzY5clhfQTQwczRvSnM5VDRiZ0V2U1lpWDh0Qkc2LV83eFYyVXdpOWpzLWVHRlVZenpRM3hraFVOREFoc1VyN1JmX1dKVEpBNVdtY0JFR0MtVmktTGxqaS1hVmNpd2duMHhoQnZUSnBsbEliaUJfSU1teEotZlhoUEh1SFA5Y3VkT1kxdVZjRUVTUjBfRTRUUFA2bEhGQldEcW9rTzhNdjJJbEFubkNvR0QwVjRsbkIyWTVsRFIzS04tc1BBVDdnNWVuN2JJZkwtcms4UkljX05DdTBwbzNnbDZzOXFmb3ZGZTd3bUZNWWNHVWJyMWJ4MUJWLTg0LU5PMklmcmxhdlJFb0hLLWoyUzVCWnVzNUhuaEw2TWJ6d2FxdXBSVHN6S3lZaktFdExtMk9xNkJiUTFUNWZpcmVrdXQ1cnZVbWJKVlNJQy1MTURIRHNCSVlFeEp4bE15alVXZFF6YjVMZkExQ1dnay1fWmdBV0JzQXptS2NmQVM4WFYyNVZueVdpbFBoZFMtUjNDY21BNDliakkweVY1YmlMaFBjS3pRZHFlbFYxX1FqcjlRMG1xajBLbW9saTc4TkJLMlJTREQzckphZl8yQ1dUcWdnNmNPaGhHdkE4UjA1SjkzaFRBNTNvWnB0OTZPczJwaHVjSzI2dzRBWUZPT2cxWXZvRUhpMDVnc2lxSTVhV1YtbkRQSGk3U2RrS0k0Z2JBTHZnLUM1ZnktUTN6dl9wVVIwNmlyMGtVNUc4a3J4b2ZmNA==","email":"jaesuk.lee@futuregen.co.kr"},"registry.redhat.io":{"auth":"NTMyMjcyMDB8dWhjLTFZZ2pTd0dweWlBNWwzZFhXSjlqeHFXQlM3UDpleUpoYkdjaU9pSlNVelV4TWlKOS5leUp6ZFdJaU9pSmlORFJrTVdSaVlqQm1NbVUwTnpZMk9XTXhNbUkxWW1Rd09EWmpZek5tWWlKOS5IMmdaTUktNHJIblVUMG5SeHQtRk5LVTVRcFhlUGtxM3N2X3FpZ1RuUXdWeV9zelZrS0V0UWR0X2VWSUh6dmdNdjRwTHY4UUhnWjlBQUgxSVI5WFh4aWxBRnZIcW9qZHV5anlSTVlGcW1EUFlpNllKNzY5clhfQTQwczRvSnM5VDRiZ0V2U1lpWDh0Qkc2LV83eFYyVXdpOWpzLWVHRlVZenpRM3hraFVOREFoc1VyN1JmX1dKVEpBNVdtY0JFR0MtVmktTGxqaS1hVmNpd2duMHhoQnZUSnBsbEliaUJfSU1teEotZlhoUEh1SFA5Y3VkT1kxdVZjRUVTUjBfRTRUUFA2bEhGQldEcW9rTzhNdjJJbEFubkNvR0QwVjRsbkIyWTVsRFIzS04tc1BBVDdnNWVuN2JJZkwtcms4UkljX05DdTBwbzNnbDZzOXFmb3ZGZTd3bUZNWWNHVWJyMWJ4MUJWLTg0LU5PMklmcmxhdlJFb0hLLWoyUzVCWnVzNUhuaEw2TWJ6d2FxdXBSVHN6S3lZaktFdExtMk9xNkJiUTFUNWZpcmVrdXQ1cnZVbWJKVlNJQy1MTURIRHNCSVlFeEp4bE15alVXZFF6YjVMZkExQ1dnay1fWmdBV0JzQXptS2NmQVM4WFYyNVZueVdpbFBoZFMtUjNDY21BNDliakkweVY1YmlMaFBjS3pRZHFlbFYxX1FqcjlRMG1xajBLbW9saTc4TkJLMlJTREQzckphZl8yQ1dUcWdnNmNPaGhHdkE4UjA1SjkzaFRBNTNvWnB0OTZPczJwaHVjSzI2dzRBWUZPT2cxWXZvRUhpMDVnc2lxSTVhV1YtbkRQSGk3U2RrS0k0Z2JBTHZnLUM1ZnktUTN6dl9wVVIwNmlyMGtVNUc4a3J4b2ZmNA==","email":"jaesuk.lee@futuregen.co.kr"}}}'
    sshKey: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4JX+gF18t2ayvfM9D/jqvpyHTxvnQf6SLEAa4rFeqLwQfWLy1KKGSoymW+pyIm7mTbCUrolvAEEp1PVWzWZm5gsHAWStSttUJbWqLS3saKX8Z8sDdKeXibTLUIoSkDtW+vNapxxtAJzK5gbB9aiuPFG/SD+A2JmoCjf5xIWw+zSMw9PdRMImlBQV8zBgwnta+gtW0mYKJVoMa951s3ACizYBdSo5h4XaL0SIX/biNgKHXCT+i/BriG+THxywYcv/ogtLtUkVL+eugzejEH638rKlgo4QzQstZ8QrF+9GxOG6XiMmpuDlnSQkmFLTC4pnZ2kc692ymSey0W5QHQkWyH69W7c9hAwT6XeO1gchGaSO8OYDUTIzDDHloFfbEv2siPlwqyKCbHkfUggtxLyHy9/VLUd7QYy03wv9sDQO1tnar1oH5eR+4b6kad2wSlzIn4wWU2QwWr/XxS3mnL+UXmCrfsKNOaQBCAg55LtlUbILPk+dl8eTzQlKryFXC1hU5AeAlaWPhX+8N8dgcNRHgWbnvqLjFQLOEXwefEU6JcNH+541ZoDieyZvtfF0B+vJqoD65fQjRUQPxVI2A759krhUzRtXDLWtHrnoZ4jxA7PFu1cgTcnATuS7NvvuWHZVw509dMxGZWwC1mgjLaKoyXau027QQsZ2pAi8WwEe7UQ== core@bastion.ocp4-1.fu.te'
    
    **## pullSecret cloud.redhat.com에서 다운 받은 pullSecret
    ## sshKey  /home/core/.ssh/ras.pub**

### install-config.yaml 생성 - offline

    apiVersion: v1
    baseDomain: fu.te
    compute:
    - hyperthreading: Enabled
      name: worker
      replicas: 0
    controlPlane:
      hyperthreading: Enabled
      name: master
      replicas: 3
    metadata:
      name: ocp4-1
    networking:
      clusterNetwork:
      - cidr: 10.136.0.0/14
        hostPrefix: 23
      networkType: OpenShiftSDN
      serviceNetwork:
      - 172.36.0.0/16
    platform:
      none: {}
    fips: false
    pullSecret: '{"auths":{"cloud.openshift.com":{"auth":"b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K2xvY2xpNTQyNzF5Z2pzd2dweWlhNWwzZHh3ajlqeHF3YnM3cDpCNlZCVUFPVkNFV1dJOTNFMjRIQ1RWUjlRSzFXVUdYSEQ2V0YzMUdHRDFVQkxXU0hVQjIzUzcxUkFWTDYwRjUw","email":"jaesuk.lee@futuregen.co.kr"},"quay.io":{"auth":"b3BlbnNoaWZ0LXJlbGVhc2UtZGV2K2xvY2xpNTQyNzF5Z2pzd2dweWlhNWwzZHh3ajlqeHF3YnM3cDpCNlZCVUFPVkNFV1dJOTNFMjRIQ1RWUjlRSzFXVUdYSEQ2V0YzMUdHRDFVQkxXU0hVQjIzUzcxUkFWTDYwRjUw","email":"jaesuk.lee@futuregen.co.kr"},"registry.connect.redhat.com":{"auth":"NTMyMjcyMDB8dWhjLTFZZ2pTd0dweWlBNWwzZFhXSjlqeHFXQlM3UDpleUpoYkdjaU9pSlNVelV4TWlKOS5leUp6ZFdJaU9pSmlORFJrTVdSaVlqQm1NbVUwTnpZMk9XTXhNbUkxWW1Rd09EWmpZek5tWWlKOS5IMmdaTUktNHJIblVUMG5SeHQtRk5LVTVRcFhlUGtxM3N2X3FpZ1RuUXdWeV9zelZrS0V0UWR0X2VWSUh6dmdNdjRwTHY4UUhnWjlBQUgxSVI5WFh4aWxBRnZIcW9qZHV5anlSTVlGcW1EUFlpNllKNzY5clhfQTQwczRvSnM5VDRiZ0V2U1lpWDh0Qkc2LV83eFYyVXdpOWpzLWVHRlVZenpRM3hraFVOREFoc1VyN1JmX1dKVEpBNVdtY0JFR0MtVmktTGxqaS1hVmNpd2duMHhoQnZUSnBsbEliaUJfSU1teEotZlhoUEh1SFA5Y3VkT1kxdVZjRUVTUjBfRTRUUFA2bEhGQldEcW9rTzhNdjJJbEFubkNvR0QwVjRsbkIyWTVsRFIzS04tc1BBVDdnNWVuN2JJZkwtcms4UkljX05DdTBwbzNnbDZzOXFmb3ZGZTd3bUZNWWNHVWJyMWJ4MUJWLTg0LU5PMklmcmxhdlJFb0hLLWoyUzVCWnVzNUhuaEw2TWJ6d2FxdXBSVHN6S3lZaktFdExtMk9xNkJiUTFUNWZpcmVrdXQ1cnZVbWJKVlNJQy1MTURIRHNCSVlFeEp4bE15alVXZFF6YjVMZkExQ1dnay1fWmdBV0JzQXptS2NmQVM4WFYyNVZueVdpbFBoZFMtUjNDY21BNDliakkweVY1YmlMaFBjS3pRZHFlbFYxX1FqcjlRMG1xajBLbW9saTc4TkJLMlJTREQzckphZl8yQ1dUcWdnNmNPaGhHdkE4UjA1SjkzaFRBNTNvWnB0OTZPczJwaHVjSzI2dzRBWUZPT2cxWXZvRUhpMDVnc2lxSTVhV1YtbkRQSGk3U2RrS0k0Z2JBTHZnLUM1ZnktUTN6dl9wVVIwNmlyMGtVNUc4a3J4b2ZmNA==","email":"jaesuk.lee@futuregen.co.kr"},"registry.redhat.io":{"auth":"NTMyMjcyMDB8dWhjLTFZZ2pTd0dweWlBNWwzZFhXSjlqeHFXQlM3UDpleUpoYkdjaU9pSlNVelV4TWlKOS5leUp6ZFdJaU9pSmlORFJrTVdSaVlqQm1NbVUwTnpZMk9XTXhNbUkxWW1Rd09EWmpZek5tWWlKOS5IMmdaTUktNHJIblVUMG5SeHQtRk5LVTVRcFhlUGtxM3N2X3FpZ1RuUXdWeV9zelZrS0V0UWR0X2VWSUh6dmdNdjRwTHY4UUhnWjlBQUgxSVI5WFh4aWxBRnZIcW9qZHV5anlSTVlGcW1EUFlpNllKNzY5clhfQTQwczRvSnM5VDRiZ0V2U1lpWDh0Qkc2LV83eFYyVXdpOWpzLWVHRlVZenpRM3hraFVOREFoc1VyN1JmX1dKVEpBNVdtY0JFR0MtVmktTGxqaS1hVmNpd2duMHhoQnZUSnBsbEliaUJfSU1teEotZlhoUEh1SFA5Y3VkT1kxdVZjRUVTUjBfRTRUUFA2bEhGQldEcW9rTzhNdjJJbEFubkNvR0QwVjRsbkIyWTVsRFIzS04tc1BBVDdnNWVuN2JJZkwtcms4UkljX05DdTBwbzNnbDZzOXFmb3ZGZTd3bUZNWWNHVWJyMWJ4MUJWLTg0LU5PMklmcmxhdlJFb0hLLWoyUzVCWnVzNUhuaEw2TWJ6d2FxdXBSVHN6S3lZaktFdExtMk9xNkJiUTFUNWZpcmVrdXQ1cnZVbWJKVlNJQy1MTURIRHNCSVlFeEp4bE15alVXZFF6YjVMZkExQ1dnay1fWmdBV0JzQXptS2NmQVM4WFYyNVZueVdpbFBoZFMtUjNDY21BNDliakkweVY1YmlMaFBjS3pRZHFlbFYxX1FqcjlRMG1xajBLbW9saTc4TkJLMlJTREQzckphZl8yQ1dUcWdnNmNPaGhHdkE4UjA1SjkzaFRBNTNvWnB0OTZPczJwaHVjSzI2dzRBWUZPT2cxWXZvRUhpMDVnc2lxSTVhV1YtbkRQSGk3U2RrS0k0Z2JBTHZnLUM1ZnktUTN6dl9wVVIwNmlyMGtVNUc4a3J4b2ZmNA==","email":"jaesuk.lee@futuregen.co.kr"},"registry.ocp4-1.fu.te:5000": {"auth": "YWRtaW46YWRtaW4=","email": "jaesuk.lee@futuregen.co.kr"}}}'
    sshKey: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4JX+gF18t2ayvfM9D/jqvpyHTxvnQf6SLEAa4rFeqLwQfWLy1KKGSoymW+pyIm7mTbCUrolvAEEp1PVWzWZm5gsHAWStSttUJbWqLS3saKX8Z8sDdKeXibTLUIoSkDtW+vNapxxtAJzK5gbB9aiuPFG/SD+A2JmoCjf5xIWw+zSMw9PdRMImlBQV8zBgwnta+gtW0mYKJVoMa951s3ACizYBdSo5h4XaL0SIX/biNgKHXCT+i/BriG+THxywYcv/ogtLtUkVL+eugzejEH638rKlgo4QzQstZ8QrF+9GxOG6XiMmpuDlnSQkmFLTC4pnZ2kc692ymSey0W5QHQkWyH69W7c9hAwT6XeO1gchGaSO8OYDUTIzDDHloFfbEv2siPlwqyKCbHkfUggtxLyHy9/VLUd7QYy03wv9sDQO1tnar1oH5eR+4b6kad2wSlzIn4wWU2QwWr/XxS3mnL+UXmCrfsKNOaQBCAg55LtlUbILPk+dl8eTzQlKryFXC1hU5AeAlaWPhX+8N8dgcNRHgWbnvqLjFQLOEXwefEU6JcNH+541ZoDieyZvtfF0B+vJqoD65fQjRUQPxVI2A759krhUzRtXDLWtHrnoZ4jxA7PFu1cgTcnATuS7NvvuWHZVw509dMxGZWwC1mgjLaKoyXau027QQsZ2pAi8WwEe7UQ== core@bastion.ocp4-1.fu.te'
    additionalTrustBundle: |
      -----BEGIN CERTIFICATE-----
      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
      -----END CERTIFICATE-----
    imageContentSources:
    - mirrors:
      - registry.ocp4-1.fu.te:5000/ocp4/openshift4
      source: quay.io/openshift-release-dev/ocp-release
    - mirrors:
      - registry.ocp4-1.fu.te:5000/ocp4/openshift4
      source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
    
    
    **## pullSecret cloud.redhat.com에서 다운 받은 pullSecret + mirror registry의 pullsecret 추가 
    ## sshKey  /home/core/.ssh/ras.pub
    ##** additionalTrustBundle: **mirror registry생성시 만든 인증서 
    ##** imageContentSources **mirror registry 생성후 oc adm으로 설치 이미지 미러후 나오는 메세지 내용 추가** 

### openshift-install 파일 다운로드

    https://cloud.redhat.com/openshift/install/metal/user-provisioned
    install file 다운로드 
    
    다운위치  : /opt/ocp4.3
    install-config.yaml 위치 : /opt/ocp4.3