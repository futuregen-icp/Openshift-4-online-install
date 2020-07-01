# About Persistent Storage 



| Storage type | Description                                                  | example                                                      |
| ------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Block**    | - 운영 체제 (OS)에 블록 장치로 제공<br/> - 파일 시스템을 우회하는 파일에서 스토리지를 완전히 제어해야하고 낮은 <br>   수준에서 작동하는 애플리케이션에 적합<br/> - SAN (Storage Area Network)이라고도 함<br/> - 공유 불가능, 즉 한 번에 하나의 클라이언트 만이 유형의 엔드 포인트를 <br>   마운트 할 수 있습니다. | - aws - ebs<br> - vmware - datastore<br>   (support dynamic provisioning)<br> - internal disk or storage <br> - external storage<br>   (san, iscsi, redhat Ceph) |
| **File**     | - 마운트 할 파일 시스템 내보내기로 OS에 제공<br/> - NAS (Network Attached Storage)라고도 함<br/> - 동시성, 대기 시간, 파일 잠금 메커니즘 및 기타 기능은 프로토콜, <br>구현, 공급 업체 및 규모에 따라 크게 다릅니다. | - NFS, Gluster<br> - NAS (per vendor)                        |
| **Object**   | - REST API 엔드 포인트를 통해 액세스 가능<br/> - OpenShift Container Platform 레지스트리에서 사용하도록 구성 가능<br/> - 응용 프로그램은 드라이버를 응용 프로그램 및 / 또는 컨테이너에 빌드해야합니다. | - Aws - s3<br> - redhat - swift                              |



## 구성 가능한 스토리지 종류 

| Storage type | ROX  | RWX  | Registry     | Scaled registry | Metrics         | Logging         | Apps            |
| ------------ | ---- | ---- | ------------ | --------------- | --------------- | --------------- | --------------- |
| **Block**    | O    | X    | Configurable | No Configurable | Recommended     | Recommended     | Recommended     |
| **File**     | O    | O    | Configurable | Configurable    | Configurable    | Configurable    | Recommended     |
| **Object**   | O    | O    | Configurable | Recommended     | No Configurable | No Configurable | No Configurable |



## 어플리케이션 별 스토리지 권장 사항

### Registry

기본 스토리지 기술은 오브젝트 스토리지와 블록 스토리지입니다. 스토리지 기술은 RWX 액세스 모드를 지원하지 않아도됩니다.

스토리지 기술은 쓰기 후 읽기 일관성을 보장해야합니다. 프로덕션 워크로드가있는 OpenShift Container Platform Registry 클러스터 배포에는 모든 NAS 스토리지가 권장되지 않습니다.

### Scaled Registry

선호하는 스토리지 기술은 객체 스토리지입니다. 스토리지 기술은 RWX 액세스 모드를 지원해야하며 쓰기 후 읽기 일관성을 보장해야합니다.

프로덕션 워크로드가있는 확장 / HA OpenShift Container Platform 레지스트리 클러스터 배포에는 파일 스토리지 및 블록 스토리지가 권장되지 않습니다.

프로덕션 워크로드가있는 OpenShift Container Platform Registry 클러스터 배포에는 모든 NAS 스토리지가 권장되지 않습니다.

### Metics

   **OpenShift Container Platform  메트릭 클러스터 배포 :  권장하는 스토리지 기술은 블록 스토리지입니다.**

- 프로덕션 워크로드와 함께  메트릭 클러스터 배포에는 파일 스토리지를 사용하지 않는 것이 좋습니다. 

  데이터의 복구 불가능한  심각한 손상이 발생 할 수 있습니다.

  > Hostpath등의 block 스토리지를 권장합니다<br>사용화되어 어플라이언스로 제공하는 NAS에서는 문제가 없을 수 있으나 이는 공급업체에 문의 

### Logging

​    **OpenShift Container Platform  로깅 클러스터 배포 :  권장하는 스토리지 기술은 블록 스토리지입니다.**

   - 프로덕션 워크로드와 함께 호스트 메트릭 클러스터 배포에는 NAS 스토리지를 사용하지 않는 것이 좋습니다.

   - 성능적인 문제로 인해 NFS사용을 권장하지 않습니다.

     > Hostpath등의 block 스토리지를 권장합니다<br>사용화되어 어플라이언스로 제공하는 NAS에서는 문제가 없을 수 있으나 이는 공급업체에 문의 

### Applications

- 동적 PV 프로비저닝을 지원하는 스토리지 기술은 마운트 시간 지연이 적으며 정상적인 클러스터를 지원하기 위해 노드에 연결되지 않습니다.

- 응용 프로그램 개발자는 응용 프로그램의 저장소 요구 사항과 응용 프로그램이 저장소 계층과 상호 작용할 때 문제가 발생하지 않도록 제공된 저장소와 작동하는 방식을 알고 이해해야합니다.

- 아래 ETC 내용을 참조

  

### ETC

- OpenShift Container Platform 내부 etcd : 최상의 etcd 안정성을 위해 가장 낮은 일관된 대기 시간 저장 기술이 바람직합니다.

  NVMe 또는 SSD와 같이 직렬 쓰기 (fsync)를 빠르게 처리하는 스토리지와 함께 etcd를 사용하는 것이 좋습니다. Ceph, NFS 및 일반 디스크는 권장되지 않습니다.

- RHOSP (Red Hat OpenStack Platform) Cinder : RHOSP Cinder는 ROX 액세스 모드 사용 사례에 적합합니다.

- 데이터베이스 : 데이터베이스 (RDBMS, NoSQL DB 등)는 전용 블록 스토리지에서 가장 잘 수행되는 경향이 있습니다.