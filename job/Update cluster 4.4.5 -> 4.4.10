


##  Updating a restricted network cluster 4.4.5->4.4.10

###   required OC command
1, oc install 

    wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.4.10/openshift-client-linux-4.4.10.tar.gz
    
    mv oc `which oc` &&  mv kubectl `which kubectl`


### Update the cluster

    $ OCP_RELEASE=<release_version> 
    $ LOCAL_REGISTRY='<local_registry_host_name>:<local_registry_host_port>' 
    $ LOCAL_REPOSITORY='<repository_name>' 
    $ PRODUCT_REPO='openshift-release-dev' 
    $ LOCAL_SECRET_JSON='<path_to_pull_secret>' 
    $ RELEASE_NAME='ocp-release' 
    $ ARCHITECTURE=<server_architecture>
    $ REMOVABLE_MEDIA_PATH=<imsi_path>

1, <release_version>  업그레이드 할 버전 
2, <repository_name> OCP repository
3, <imsi_path> 이미지 임시 저장 위치

    export OCP_RELEASE="4.4.10"
    export LOCAL_REGISTRY='registry.ocp44.fu.com:5000' 
    export LOCAL_REPOSITORY='ocp44/openshift4'
    export PRODUCT_REPO='openshift-release-dev'
    export LOCAL_SECRET_JSON='/opt/ocp44/pull/pull-secret.json' 
    export RELEASE_NAME="ocp-release"
    export ARCHITECTURE=x86_64
    export REMOVABLE_MEDIA_PATH=/opt/ocp44/ocpop/ocpversionup/registry/ocp4411
    export OCP_RELEASE_NUMBER=4.4.11

   ##### Review the images and configuration manifests to mirror:

    oc adm release mirror -a ${LOCAL_SECRET_JSON} --to-dir=${REMOVABLE_MEDIA_PATH}/mirror quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} --dry-run
        
    
    
   ##### download the release images to the local directory
    oc adm release mirror -a ${LOCAL_SECRET_JSON} --to-dir=${REMOVABLE_MEDIA_PATH}/mirror quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE}

##### upload images to local container registry

    oc image mirror  -a ${LOCAL_SECRET_JSON} --from-dir=${REMOVABLE_MEDIA_PATH}/mirror 'file://openshift/release:${OCP_RELEASE}*' ${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}

##### release images to the local registry and apply the ConfigMap to the cluster
    oc adm release mirror -a ${LOCAL_SECRET_JSON} --from=quay.io/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-${ARCHITECTURE} --to=${LOCAL_REGISTRY}/${LOCAL_REPOSITORY} --apply-release-image-signature

##### Creating ImageContentSourcePolicy

    apiVersion: operator.openshift.io/v1alpha1
    kind: ImageContentSourcePolicy
    metadata:
      name: ocp4411
    spec:
      repositoryDigestMirrors:
      - mirrors:
        - registry.ocp44.fu.com:5000/ocp4/openshift4411
        source: quay.io/openshift-release-dev/ocp-release
      - mirrors:
        - registry.ocp44.fu.com:5000/ocp4/openshift4411
        source: quay.io/openshift-release-dev/ocp-v4.0-art-dev
        
        
    oc apply -f ImageContentSourcePolicy.yaml

##### Creating an image signature ConfigMap

    DIGEST="$(oc adm release info quay.io/openshift-release-dev/ocp-release:${OCP_RELEASE_NUMBER}-${ARCHITECTURE} | sed -n 's/Pull From: .*@//p')"
    
    DIGEST_ALGO="${DIGEST%%:*}"
    
    DIGEST_ENCODED="${DIGEST#*:}"
    
    SIGNATURE_BASE64=$(curl -s "https://mirror.openshift.com/pub/openshift-v4/signatures/openshift/release/${DIGEST_ALGO}=${DIGEST_ENCODED}/signature-1" | base64 -w0 && echo)
    
    cat >checksum-${OCP_RELEASE_NUMBER}.yaml <<EOF
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: release-image-${OCP_RELEASE_NUMBER}
      namespace: openshift-config-managed
      labels:
        release.openshift.io/verification-signatures: ""
    binaryData:
      ${DIGEST_ALGO}-${DIGEST_ENCODED}: ${SIGNATURE_BASE64}
    EOF
    
    oc apply -f checksum-${OCP_RELEASE_NUMBER}.yaml

##### Update the cluster

    oc adm upgrade --allow-explicit-upgrade --to-image  ${LOCAL_REGISTRY}/${LOCAL_REPOSITORY}@${DIGEST_ALGO}:${DIGEST_ENCODED}

