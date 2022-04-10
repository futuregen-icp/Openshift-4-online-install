- 

# Red Hat OpenShift가 NIST 800-190을 해결하는 방법

2021년 1월 7일 | 커스틴 뉴커머

클라우드 네이티브 애플리케이션의 사용이 확대됨에 따라 기업은 프로덕션 환경에서 컨테이너 및 Kubernetes를 보호하기 위한 모범 사례에 대한 지침을 신뢰할 수 있는 파트너 및 표준 기관에 요청합니다. 그러한 표준 기관 중 하나는 NIST( [National Institute of Standards and Technology )입니다. ](https://www.nist.gov/)2017년 가을, NIST는 [Special Publication 800-190, Application Container Security Guide를 발간했습니다](https://csrc.nist.gov/publications/detail/sp/800-190/final) . NIST SP 800-190은 Red Hat OpenShift Container Platform과 같은 컨테이너 오케스트레이션 솔루션을 위한 컨테이너 보안 및 보안 요소에 대한 훌륭한 지침 소스입니다. 

OpenShift는 구축에서 배포, 미션 크리티컬 환경에서 컨테이너 실행에 이르기까지 컨테이너 수명 주기 전반에 걸쳐 보안을 통합하여 컨테이너 보안에 대한 [계층적 접근 방식 을 취합니다. ](https://www.redhat.com/en/resources/layered-approach-security-detail)우리가 자주 받는 질문 중 하나는 OpenShift가 어떻게 고객이 컨테이너화된 애플리케이션 보안을 위한 NIST 800-190 지침을 충족하도록 지원하는지입니다. 

진정으로 효과적이려면 컨테이너 및 Kubernetes 보안이 자동화되어야 하고 가능한 한 Kubernetes의 선언적 특성을 활용해야 합니다. 자동화에는 지침을 기술 제어로 코드화하는 기능이 필요합니다. NIST SP 800-190의 지침과 관련된 제어는 NIST 800-53에 포함되어 있으며 참조 목록은 NIST SP800-190의 부록 B에 제공됩니다.

고객이 원하는 보안 상태로 하이브리드 클라우드 애플리케이션을 구축, 배포 및 실행할 수 있도록 지원하려는 Red Hat의 약속의 일환으로 Red Hat은 Red Hat OpenShift Container Platform 클러스터에 배포하여 기술 제어 및 필요한 경우 자동으로 수정합니다. 규정 준수 운영자는 NIST 800-53의 기술 제어를 비롯한 여러 프레임워크를 지원합니다. 

현재 규정 준수 운영자는 OpenShift의 Red Hat Enterprise Linux CoreOS 계층에 적용된 NIST 800-53 컨트롤의 하위 집합에 대해 감사할 수 있습니다. 지원될 다음 제어 세트는 CIS( [Center for Internet Security ) ](https://www.cisecurity.org/)[Kubernetes 벤치마크 v1.6](https://www.cisecurity.org/benchmark/kubernetes/) 에서 영감을 받았습니다 . 

물론 NIST SP 800-190의 지침은 기술적 통제를 넘어선 것입니다. Red Hat 솔루션은 고객이 컨테이너 파이프라인의 다음 요소를 보호하기 위한 권장 모범 사례도 충족하도록 지원합니다. 

​		외부 컨테이너 레지스트리

- 내부 컨테이너 레지스트리
- 컨테이너 조정자
- 컨테이너 호스트

<iframe class="drift-frame-controller" scrolling="no" title="드리프트 위젯 아이콘" allow="autoplay; encrypted-media; fullscreen;" frameborder="0" src="https://js.driftt.com/core?embedId=pkebsuhdupai&amp;region=US&amp;forceShow=false&amp;skipCampaigns=false&amp;sessionId=893458b2-ccbd-48df-a24f-17ed8cd3545c&amp;sessionStarted=1649578401.144&amp;campaignRefreshToken=f3f98796-732d-45a9-a659-acc19a9faccd&amp;hideController=false&amp;pageLoadStartTime=1649590751940&amp;mode=CHAT&amp;driftEnableLog=false" style="box-sizing: border-box; text-rendering: optimizelegibility; display: block; min-width: 0px; max-width: 100%; min-height: 0px; max-height: none; bottom: 24px; border: none; background: transparent; width: 76px; height: 0px;"></iframe>

## 외부 컨테이너 레지스트리

**Red Hat 생태계 카탈로그** 는 고객이 맞춤형 컨테이너화 애플리케이션을 위한 빌딩 블록으로 필요로 하는 신뢰할 수 있는 컨테이너 이미지의 소스입니다 . Red Hat은 Linux(RHEL 및 Universal 기본 이미지)에서 애플리케이션을 실행하는 데 필요한 기본 운영 체제 라이브러리에 대한 서명된 이미지와 Java 및 Python과 같은 런타임 라이브러리가 있는 다양한 이미지를 제공합니다. Red Hat은 이러한 이미지를 유지 관리하여 새로 발견된 취약점에 대한 수정 사항을 포함하여 새 코드가 릴리스되면 업데이트된 버전을 제공합니다. 카탈로그의 각 컨테이너 이미지에 대해 상태 등급이 제공되어 개별 이미지의 연령 및 이미지와 관련된 알려진 CVE에 대한 정보를 제공합니다. 건강 지수 등급에 대한 자세한 정보는 [https://access.redhat.com/articles/2803031 에서 확인할 수 있습니다.](https://access.redhat.com/articles/2803031)

**Red Hat OpenShift** **Container Platform** 은 플랫폼 에 배포하기 위해 컨테이너 이미지를 가져올 수 있는 레지스트리 를 허용 목록에 *추가하거나 차단 목록* 에 추가 할 수 있는 기능을 제공합니다 . 승인 컨트롤러를 사용하여 유효한 서명이 있는 이미지만 배포되도록 할 수도 있습니다. 

OpenShift에는 외부 레지스트리에서 가져온 이미지의 변경 사항을 모니터링하는 데 사용할 수 있는 *ImageStreams* 라는 기능도 포함되어 있어 이러한 외부 이미지를 최신 버전 및 수정 사항으로 사용하는 사용자 지정 이미지 업데이트를 더 쉽게 자동화할 수 있습니다.



## 내부 컨테이너 레지스트리

**Red Hat OpenShift Container Platform** 에는 플랫폼과 함께 사용하기 위한 통합 컨테이너 레지스트리가 포함되어 있습니다.

또한 **Red Hat Quay** 는 SaaS 또는 온프레미스 프라이빗 레지스트리로 사용할 수 있는 엔터프라이즈 컨테이너 레지스트리입니다. Red Hat Quay 기능은 다음과 같습니다. 

​	

- 취약점 스캐닝을 위한 클레어 
- 지리적 복제
- 이미지 롤백 타임머신
- 이미지 트리거 빌드

**Red Hat OpenShift** 와 함께 사용는 경우 Clair 취약점 스캔 결과는 배포된 컨테이너 이미지에 대한 OpenShift 콘솔에서 볼 수 있습니다.



## 컨테이너 이미지 구축

Red Hat OpenShift는 Jenkins 및 Tekton(기술 미리 보기)의 두 가지 CI/CD 파이프라인을 지원합니다. 둘 다 취약점 스캐너 및 구성 분석 도구와 같은 컨테이너 보안 도구와 통합될 수 있습니다. 

**Red Hat CodeReady Workspaces** 는 신속한 클라우드 애플리케이션 개발을 위해 OpenShift 작업 공간과 브라우저 내 IDE를 제공하는 협업 Kubernetes 네이티브 개발 솔루션입니다. 개방형 Eclipse Che 프로젝트를 기반으로 구축된 Red Hat CodeReady Workspaces는 Kubernetes 및 컨테이너를 사용하여 개발 또는 IT 팀의 모든 구성원에게 일관되고 더 안전하며 구성이 필요 없는 개발 환경을 제공합니다. 사용자 경험은 랩탑의 IDE(통합 개발 환경)만큼 빠르고 친숙합니다. CodeReady Workspaces는 개발자가 선택한 데스크톱 IDE도 지원합니다. IDE와 통합되는 컨테이너 기본 보안 도구는 Code Ready Workspace와 함께 사용할 수 있습니다.



## 컨테이너 오케스트레이션

**Red Hat OpenShift Container Platform** 은 컨테이너 오케스트레이션을 위한 심층 방어를 제공합니다. 

OpenShift는 시행 모드의 *SELinux* 와 함께 **Red Hat Enterprise Linux 에서 실행됩니다.** OpenShift [*보안 컨텍스트 제약 조건*](https://docs.openshift.com/container-platform/4.6/authentication/managing-security-context-constraints.html) (Kuberenetes 승인 컨트롤러로 구현)은 기본적으로 OpenShift 작업자 노드에서 권한 있는 컨테이너를 실행할 수 없도록 합니다. 

위에서 언급한 바와 같이 OpenShift는 Kubernetes 승인 컨트롤러를 사용 하여 플랫폼에 배포하기 위해 컨테이너 이미지를 가져올 수 있는 레지스트리를 *블랙리스트/화이트리스트* 에 추가 하고 유효한 서명이 있는 이미지만 배포되었는지 확인하도록 구성할 수 있습니다. 

OpenShift에는 사용자 및 서비스의 토큰 기반 인증을 위한 내장 *OAuth 서버 가 포함되어 있습니다.* OpenShift는 9개의 외부 ID 공급자와의 통합을 지원합니다. OpenShift 플랫폼 구성 요소는 X.509 인증서를 통해 서로를 인증합니다. 플랫폼 구성 요소에 대한 CA 및 인증서는 OpenShift에서 관리합니다. 

OpenShift에는 즉시 사용 가능한 역할과 사용자 지정 역할 생성 기능이 있는 역할 기반 액세스 제어가 포함됩니다. 역할은 클러스터 전체 또는 프로젝트(아래 참조) 범위를 가질 수 있습니다.

OpenShift *프로젝트* (kube 네임스페이스)를 사용하면 동일한 목적, 민감도 및 위협 태세를 가진 사용자와 애플리케이션을 쉽게 그룹화할 수 있습니다. 원하는 경우 사용자는 Kubernetes taint 및 toleration을 사용하여 개별 호스트에서 애플리케이션을 격리할 수 있습니다. 

OpenShift는 애플리케이션을 오가는 동서 네트워크 트래픽을 제어하는 데 사용할 수 있는 *Kubernetes 네트워크 정책 을 지원합니다.* OpenShift 수신 및 송신 제어를 사용하여 남북 네트워크 트래픽을 제어할 수 있습니다. **OpenShift Service Mesh** 는 서비스 간 네트워크 트래픽의 추가 보안 및 관리에 사용할 수 있습니다. 

OpenShift에는 Prometheus 및 Grafana를 통해 제공되는 클러스터 모니터링 및 경고가 포함됩니다. 애플리케이션에 대해 동일한 모니터링 및 알림 스택을 사용하는 기능은 현재 기술 프리뷰 단계입니다.

OpenShift는 이벤트 감사를 제공하고 클러스터 수준 및 응용 프로그램 수준 로그 파일을 모두 생성하는 선택적 로깅 스택을 포함합니다. 로깅 파이프라인을 사용하여 감사 로그와 클러스터 및 애플리케이션 로그를 수집하고 이를 SIEM으로 전달할 수 있습니다. 

**현재 기술 프리뷰에 있는 Red Hat Advanced Cluster Management** 는 특정 지역에 특정 유형의 애플리케이션 또는 데이터를 배포해야 하는 요구 사항과 같은 사용 사례를 지원하는 정책에 따라 애플리케이션 배포를 관리하는 데 사용할 수 있습니다. 



## 컨테이너 호스트

[RHEL CoreOS](https://docs.openshift.com/container-platform/4.3/architecture/architecture-rhcos.html) 는 컨테이너에 최적화된 운영 체제(OS)입니다. RHEL CoreOS는 대체로 변경 불가능하며 OpenShift를 실행하는 데 필요한 패키지만 포함하므로 공격 표면이 최소화됩니다. RHCOS에 RPM 설치는 지원되지 않습니다. OS는 OS 외부의 모든 프로세스를 컨테이너로 실행하도록 구축되었습니다. 이를 통해 기존 운영 체제가 제공할 수 있는 것 이상으로 성공적인 업그레이드 및 자동화가 가능합니다.

- *rpm-ostree* 는 운영 체제를 조립하는 데 사용되는 기술입니다. RHEL RPM은 OS 이미지를 만드는 데 사용되며 버전은 rpm 명령을 사용하여 쉽게 쿼리할 수 있습니다. 

- - /usr은 운영 체제 바이너리와 라이브러리가 저장되고 읽기 전용인 곳입니다. 
  - /etc, /boot, /var는 시스템에서 쓸 수 있지만 Machine Config Operator에 의해서만 변경될 수 있습니다.
  - /var/lib/containers는 컨테이너 이미지를 저장하기 위한 그래프 저장 위치입니다.

OpenShift에서 RHEL CoreOS는 Machine Config Operator로 관리되어 클러스터의 모든 호스트가 균일하게 구성되도록 돕습니다. Machine Config Operator는 다음 구성 요소에 대한 구성을 관리합니다.

- CRI-O(컨테이너 런타임)
- 쿠벨렛
- 승인된 레지스트리
- SSH

호스트 OS에 대한 업데이트는 OpenShift에 대한 업데이트와 동일한 방식으로 관리됩니다. OpenShift Admin은 업데이트를 적용할 시기를 선택하고 클러스터는 롤링 방식으로 호스트에 업데이트를 적용합니다. 호스트는 정상 작동하는 애플리케이션을 위해 애플리케이션 다운타임 없이 업데이트할 수 있습니다. 

노드에 ssh할 필요 없이 사용할 수 있는 많은 디버깅 도구가 클러스터 관리에 제공됩니다. 예를 들어 두 가지는 필수 수집 도구와 oc 디버그 명령입니다. 자세한 내용은 다음을 참조하세요.

- https://docs.openshift.com/container-platform/4.6/support/gathering-cluster-data.html
- https://docs.openshift.com/container-platform/4.6/metering/metering-troubleshooting-debugging.html
- https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/developer-cli-commands.html#cli-troubleshooting-commands_cli-developer-commands

OpenShift 및 RHEL CoreOS는 다음 Linux 기능을 활용하여 호스트 OS 구성과 OpenShift [Security Context Constraint](https://docs.openshift.com/container-platform/4.4/authentication/managing-security-context-constraints.html) 승인 컨트롤러의 조합을 통해 컨테이너 프로세스를 보호합니다. 

- [*Linux 네임스페이스*](http://man7.org/linux/man-pages/man7/namespaces.7.html) 는 컨테이너 격리의 기본 사항을 제공합니다. 네임스페이스를 사용하면 네임스페이스 내의 프로세스에 고유한 전역 리소스 인스턴스가 있는 것으로 나타납니다. 네임스페이스는 컨테이너 내부에 있을 때 자체 운영 체제에서 실행되고 있다는 인상을 주는 추상화를 제공합니다.
- *마운트 네임스페이스* 는 프로세스 그룹에서 볼 수 있는 파일 시스템 마운트 지점 세트를 분리하여 다른 마운트 네임스페이스의 프로세스가 파일 시스템 계층 구조의 다른 보기를 가질 수 있도록 합니다. 마운트 네임스페이스를 사용하면 mount() 및 umount() 시스템 호출이 전역 마운트 지점 집합(모든 프로세스에 표시됨)에서 작동을 중지하고 대신 컨테이너 프로세스와 연결된 마운트 네임스페이스에만 영향을 주는 작업을 수행합니다. 예를 들어, 각 컨테이너는 고유한 /tmp 또는 /var 디렉토리를 갖거나 완전히 다른 사용자 공간을 가질 수도 있습니다.
- [*SELinux*](https://en.wikipedia.org/wiki/Security-Enhanced_Linux) 는 컨테이너를 서로 및 호스트로부터 격리된 상태로 유지하기 위해 추가 보안 계층을 제공합니다. SELinux를 통해 관리자는 모든 사용자, 애플리케이션, 프로세스 및 파일에 대해 MAC(필수 액세스 제어)를 시행할 수 있습니다. SELinux는 네임스페이스 추상화에서 (우연히 또는 고의로) 벗어나려고 하면 막을 수 있는 벽돌 벽과 같습니다.
- [*Cgroup*](https://en.wikipedia.org/wiki/Cgroups)[ (제어 그룹)은 프로세스 모음의 리소스 사용량](https://en.wikipedia.org/wiki/Resource_(computer_science)) (예: CPU, 메모리, 디스크 I/O, 네트워크)을제한, 설명 및 격리합니다Cgroup을 사용하여 컨테이너가 동일한 호스트의 다른 컨테이너에 의해 짓밟히지 않도록 하십시오. Cgroup은 인기 있는 공격 벡터인 의사 장치를 제어하는 데에도 사용할 수 있습니다. 
- [*Linux 기능*](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/container_security_guide/linux_capabilities_and_seccomp) 을 사용하여 컨테이너의 루트를 잠글 수 있습니다. 기능은 독립적으로 활성화 또는 비활성화할 수 있는 고유한 권한 단위입니다. 기능을 사용하면 원시 IP 패킷을 보내거나 1024 미만의 포트에 바인딩하는 등의 작업을 수행할 수 있습니다. 컨테이너를 실행할 때 대다수의 컨테이너화된 애플리케이션에 영향을 주지 않고 여러 기능을 삭제할 수 있습니다. 
- 마지막으로 [*보안 컴퓨팅 모드*](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/container_security_guide/linux_capabilities_and_seccomp) (seccomp) 프로필을 컨테이너와 연결하여 사용 가능한 시스템 호출을 제한할 수 있습니다.

호스트 감사는 *Auditd* 를 활성화하여 수행할 수 있으며 호스트 로그는 OpenShift 로깅 파이프라인 기능으로 수집 및 전달할 수 있습니다.

RHEL CoreOS 볼륨은 자동 복호화를 위해 TPM/vTPM(v2) 및 Tang 엔드포인트를 사용한 네트워크 바인딩 디스크 암호화를 사용하여 암호화할 수 있습니다.

TLS 1.3은 RHEL CoreOS의 기본값입니다.

RHEL CoreOS는 FIPS 암호화를 지원합니다. RHEL CoreOS 노드가 FIPS 모드에서 부팅되면 OpenShift 플랫폼 구성 요소는 RHEL 암호화 라이브러리를 호출합니다. RHEL CoreOS 암호화 라이브러리의 FIPS 상태는 처리 중인 모듈입니다



## 컨테이너 런타임 및 기타 도구

OpenShift는 컨테이너 런타임에 [CRI-O 를 사용합니다. ](https://cri-o.io/)CRI-O를 사용하면 불필요한 코드나 도구 없이 Kubernetes에서 직접 컨테이너를 실행할 수 있습니다. 컨테이너가 OCI를 준수하는 한 CRI-O는 컨테이너를 실행하여 불필요한 도구를 제거할 수 있습니다. CRI-O는 Kubernetes에 최적화되고 버전이 지정됩니다. OpenShift는 컨테이너를 실행해야 할 때 CRI-O를 호출하고 CRI-O 데몬은 runc와 함께 작동하여 컨테이너를 시작합니다.

OpenShift에는 [podman](https://podman.io/) 도 포함되어 있습니다 . Podman은 Linux에서 OCI 컨테이너를 개발, 관리 및 실행하기 위한 데몬이 없는 컨테이너 엔진입니다.

자세한 내용은 https://www.redhat.com/en/blog/introducing-cri-o-10 및 [https://www.redhat.com/en/blog/why-red-hat-investing-cri 를 참조하십시오. -o-and-podman](https://www.redhat.com/en/blog/why-red-hat-investing-cri-o-and-podman)

