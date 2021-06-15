## pod간의 통신이 안되는 경우 해결방법

### 증상

1. 동일 Namespaces의 두 Pod

2. 동일 node에 있을 경우 통신이 원활함

3. 다른 node에 있을 경우 통신이 안됨 .



### 해결 방안

1. 방화벽 설정 및 네트워크 통신 문제 확인  

   마스터와는 통신이 원활하지만 worker node들 사이에 통신상의 문제가 된다면  발생할 수 있습니다.

 

| *Table 1. All machines to all machines*    |                                                              |                             |
| ------------------------------------------ | ------------------------------------------------------------ | --------------------------- |
| **Protocol**                               | **Port**                                                     | **Description**             |
| ICMP                                       | N/A                                                          | Network reachability  tests |
| TCP                                        | 1936                                                         | Metrics                     |
| 9000-9999                                  | Host level services,  including the node exporter on ports 9100-9101 and the  Cluster Version Operator on port 9099. |                             |
| 10250-10259                                | The default ports that  Kubernetes reserves                  |                             |
| 10256                                      | openshift-sdn                                                |                             |
| UDP                                        | 4789                                                         | VXLAN and Geneve            |
| 6081                                       | VXLAN and Geneve                                             |                             |
| 9000-9999                                  | Host level services,  including the node exporter on ports 9100-9101. |                             |
| TCP/UDP                                    | 30000-32767                                                  | Kubernetes node port        |
| *Table 2. All machines to control   plane* |                                                              |                             |
| **Protocol**                               | **Port**                                                     | **Description**             |
| TCP                                        | 6443                                                         | Kubernetes API              |

 

| *Table 3. Control plane machines to   control plane machines* |           |                             |
| ------------------------------------------------------------ | --------- | --------------------------- |
| **Protocol**                                                 | **Port**  | **Description**             |
| TCP                                                          | 2379-2380 | etcd server and peer  ports |

 

2.  Curl 로 TC{P 통신 확인 

   아래와 같이 확인합니다.

```
curl -v telnet://127.0.0.1:22
```



