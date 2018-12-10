# stellar-core-postgresql-helm

Stellar-core with PostgreSQL deployment based on HELM.

## Deployment instance:

Ubuntu 18.04 with
- az cli
- kubectl

## Current status:

```bash
kubectl get events --all-namespaces | grep -i "error\|warning\|failed" | tail -n 10

default     1m          55m          34      stellar-core-95bd7f4f4-8thrp.156f129fe06d4acd               Pod                                 Warning   FailedAttachVolume      attachdetach-controller             AttachVolume.Attach failed for volume "pvc-0f7acf68-fcba-11e8-b233-ba153903c155" : Attach volume "kubernetes-dynamic-pvc-0f7acf68-fcba-11e8-b233-ba153903c155" to instance "/subscriptions/0aba6a11-6e19-400f-a5a9-b6bd2373b4ca/resourceGroups/MC_at-recruit_at-recruit-aks-aks_westeurope/providers/Microsoft.Compute/virtualMachines/aks-nodepool1-50223173-0" failed with compute.VirtualMachinesClient#CreateOrUpdate: Failure sending request: StatusCode=409 -- Original Error: failed request: autorest/azure: Service returned an error. Status=<nil> Code="AttachDiskWhileBeingDetached" Message="Cannot attach data disk 'kubernetes-dynamic-pvc-df634249-fc3d-11e8-b233-ba153903c155' to VM 'aks-nodepool1-50223173-0' because the disk is currently being detached or the last detach operation failed. Please wait until the disk is completely detached and then try again or delete/detach the disk explicitly again." Target="dataDisks"
default     1m          54m          34      stellar-core-postgresql-78fdc9585c-rjc86.156f12a2b330273f   Pod                                 Warning   FailedAttachVolume      attachdetach-controller             AttachVolume.Attach failed for volume "pvc-0f78102d-fcba-11e8-b233-ba153903c155" : Attach volume "kubernetes-dynamic-pvc-0f78102d-fcba-11e8-b233-ba153903c155" to instance "/subscriptions/0aba6a11-6e19-400f-a5a9-b6bd2373b4ca/resourceGroups/MC_at-recruit_at-recruit-aks-aks_westeurope/providers/Microsoft.Compute/virtualMachines/aks-nodepool1-50223173-0" failed with compute.VirtualMachinesClient#CreateOrUpdate: Failure sending request: StatusCode=409 -- Original Error: failed request: autorest/azure: Service returned an error. Status=<nil> Code="AttachDiskWhileBeingDetached" Message="Cannot attach data disk 'kubernetes-dynamic-pvc-df634249-fc3d-11e8-b233-ba153903c155' to VM 'aks-nodepool1-50223173-0' because the disk is currently being detached or the last detach operation failed. Please wait until the disk is completely detached and then try again or delete/detach the disk explicitly again." Target="dataDisks"
default     47s         53m          24      stellar-core-95bd7f4f4-8thrp.156f12bc72a74faa               Pod                                 Warning   FailedMount             kubelet, aks-nodepool1-50223173-0   Unable to mount volumes for pod "stellar-core-95bd7f4f4-8thrp_default(0fc2237b-fcba-11e8-b233-ba153903c155)": timeout expired waiting for volumes to attach or mount for pod "default"/"stellar-core-95bd7f4f4-8thrp". list of unmounted volumes=[data]. list of unattached volumes=[data stellar-core-token-pbdfm]
default     43s         52m          24      stellar-core-postgresql-78fdc9585c-rjc86.156f12bf43b53ef3   Pod                                 Warning   FailedMount             kubelet, aks-nodepool1-50223173-0   Unable to mount volumes for pod "stellar-core-postgresql-78fdc9585c-rjc86_default(0fc1f87f-fcba-11e8-b233-ba153903c155)": timeout expired waiting for volumes to attach or mount for pod "default"/"stellar-core-postgresql-78fdc9585c-rjc86". list of unmounted volumes=[data]. list of unattached volumes=[data default-token-d5lld]
```

## Troubleshooting

```bash
kubectl get pods,deploy,rs,sts,ds,svc,endpoints,pv,pvc --all-namespaces | grep stellar-core

default       pod/stellar-core-95bd7f4f4-8thrp               0/1     ContainerCreating   0          57m
default       pod/stellar-core-postgresql-78fdc9585c-rjc86   0/1     ContainerCreating   0          57m

default       deployment.extensions/stellar-core              1         1         1            0           57m
default       deployment.extensions/stellar-core-postgresql   1         1         1            0           57m

default       replicaset.extensions/stellar-core-95bd7f4f4               1         1         0       57m
default       replicaset.extensions/stellar-core-postgresql-78fdc9585c   1         1         0       57m


default       service/stellar-core-http         ClusterIP      10.0.168.218   <none>        11626/TCP         57m
default       service/stellar-core-peer         LoadBalancer   10.0.231.113   <pending>     11625:31524/TCP   57m
default       service/stellar-core-postgresql   ClusterIP      10.0.198.148   <none>        5432/TCP          57m

default       endpoints/stellar-core-http         <none>                                                  57m
default       endpoints/stellar-core-peer         <none>                                                  57m
default       endpoints/stellar-core-postgresql   <none>                                                  57m
            persistentvolume/pvc-0f78102d-fcba-11e8-b233-ba153903c155   8Gi        RWO            Delete           Bound    default/stellar-core-postgresql   westeurope-standard-lrs            56m
            persistentvolume/pvc-0f7acf68-fcba-11e8-b233-ba153903c155   8Gi        RWO            Delete           Bound    default/stellar-core              westeurope-standard-lrs            57m

default     persistentvolumeclaim/stellar-core              Bound    pvc-0f7acf68-fcba-11e8-b233-ba153903c155   8Gi        RWO            westeurope-standard-lrs   57m
default     persistentvolumeclaim/stellar-core-postgresql   Bound    pvc-0f78102d-fcba-11e8-b233-ba153903c155   8Gi        RWO            westeurope-standard-lrs   57m
```

```bash
kubectl describe pod stellar-core-postgresql-78fdc9585c-rjc86

Name:               stellar-core-postgresql-78fdc9585c-rjc86
Namespace:          default
Priority:           0
PriorityClassName:  <none>
Node:               aks-nodepool1-50223173-0/10.240.0.4
Start Time:         Mon, 10 Dec 2018 20:28:06 +0000
Labels:             app=postgresql
                    pod-template-hash=3498751417
                    release=stellar-core
Annotations:        <none>
Status:             Pending
IP:                 
Controlled By:      ReplicaSet/stellar-core-postgresql-78fdc9585c
Containers:
  stellar-core-postgresql:
    Container ID:   
    Image:          postgres:9.6.2
    Image ID:       
    Port:           5432/TCP
    Host Port:      0/TCP
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
    Restart Count:  0
    Requests:
      cpu:      100m
      memory:   256Mi
    Liveness:   exec [sh -c exec pg_isready --host $POD_IP] delay=60s timeout=5s period=10s #success=1 #failure=6
    Readiness:  exec [sh -c exec pg_isready --host $POD_IP] delay=5s timeout=3s period=5s #success=1 #failure=3
    Environment:
      POSTGRES_USER:                 postgres
      PGUSER:                        postgres
      POSTGRES_DB:                   stellar-core
      POSTGRES_INITDB_ARGS:          
      PGDATA:                        /var/lib/postgresql/data/pgdata
      POSTGRES_PASSWORD:             <set to the key 'postgres-password' in secret 'stellar-core-postgresql'>  Optional: false
      POD_IP:                         (v1:status.podIP)
      KUBERNETES_PORT_443_TCP_ADDR:  <skipped>.westeurope.azmk8s.io
      KUBERNETES_PORT:               <skipped>.westeurope.azmk8s.io:443
      KUBERNETES_PORT_443_TCP:       <skipped>.westeurope.azmk8s.io:443
      KUBERNETES_SERVICE_HOST:       <skipped>.westeurope.azmk8s.io
    Mounts:
      /var/lib/postgresql/data/pgdata from data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-d5lld (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
Volumes:
  data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  stellar-core-postgresql
    ReadOnly:   false
  default-token-d5lld:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-d5lld
    Optional:    false
QoS Class:       Burstable
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason              Age                  From                               Message
  ----     ------              ----                 ----                               -------
  Warning  FailedScheduling    58m (x10 over 59m)   default-scheduler                  pod has unbound PersistentVolumeClaims (repeated 2 times)
  Normal   Scheduled           58m                  default-scheduler                  Successfully assigned default/stellar-core-postgresql-78fdc9585c-rjc86 to aks-nodepool1-50223173-0
  Warning  FailedAttachVolume  102s (x36 over 58m)  attachdetach-controller            AttachVolume.Attach failed for volume "pvc-0f78102d-fcba-11e8-b233-ba153903c155" : Attach volume "kubernetes-dynamic-pvc-0f78102d-fcba-11e8-b233-ba153903c155" to instance "/subscriptions/0aba6a11-6e19-400f-a5a9-b6bd2373b4ca/resourceGroups/MC_at-recruit_at-recruit-aks-aks_westeurope/providers/Microsoft.Compute/virtualMachines/aks-nodepool1-50223173-0" failed with compute.VirtualMachinesClient#CreateOrUpdate: Failure sending request: StatusCode=409 -- Original Error: failed request: autorest/azure: Service returned an error. Status=<nil> Code="AttachDiskWhileBeingDetached" Message="Cannot attach data disk 'kubernetes-dynamic-pvc-df634249-fc3d-11e8-b233-ba153903c155' to VM 'aks-nodepool1-50223173-0' because the disk is currently being detached or the last detach operation failed. Please wait until the disk is completely detached and then try again or delete/detach the disk explicitly again." Target="dataDisks"
  Warning  FailedMount         12s (x26 over 56m)   kubelet, aks-nodepool1-50223173-0  Unable to mount volumes for pod "stellar-core-postgresql-78fdc9585c-rjc86_default(0fc1f87f-fcba-11e8-b233-ba153903c155)": timeout expired waiting for volumes to attach or mount for pod "default"/"stellar-core-postgresql-78fdc9585c-rjc86". list of unmounted volumes=[data]. list of unattached volumes=[data default-token-d5lld]
  ```

```bash
kubectl describe pod stellar-core-95bd7f4f4-8thrp
Name:               stellar-core-95bd7f4f4-8thrp
Namespace:          default
Priority:           0
PriorityClassName:  <none>
Node:               aks-nodepool1-50223173-0/10.240.0.4
Start Time:         Mon, 10 Dec 2018 20:27:54 +0000
Labels:             app=stellar-core
                    pod-template-hash=516839090
                    release=stellar-core
Annotations:        <none>
Status:             Pending
IP:                 
Controlled By:      ReplicaSet/stellar-core-95bd7f4f4
Containers:
  stellar-core:
    Container ID:   
    Image:          satoshipay/stellar-core:10.0.0-2
    Image ID:       
    Ports:          11625/TCP, 11626/TCP
    Host Ports:     0/TCP, 0/TCP
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
    Restart Count:  0
    Requests:
      cpu:      100m
      memory:   512Mi
    Liveness:   http-get http://:http/info delay=0s timeout=1s period=10s #success=1 #failure=3
    Readiness:  http-get http://:http/info delay=0s timeout=1s period=10s #success=1 #failure=3
    Environment:
      NODE_SEED:  <skipped>
      DATABASE_PASSWORD:   <skipped>
      DATABASE:  <skipped>
      KNOWN_PEERS:  <skipped>
      PREFERRED_PEERS:  <skipped>
      NODE_NAMES:  <skipped>
      QUORUM_SET:  <skipped>
      NODE_IS_VALIDATOR:             true
      NETWORK_PASSPHRASE:            Public Global Stellar Network ; September 2015
      MAX_PEER_CONNECTIONS:          50
      KUBERNETES_PORT_443_TCP_ADDR:  <skipped>.westeurope.azmk8s.io
      KUBERNETES_PORT:               <skipped>.hcp.westeurope.azmk8s.io:443
      KUBERNETES_PORT_443_TCP:       <skipped>.hcp.westeurope.azmk8s.io:443
      KUBERNETES_SERVICE_HOST:       <skipped>.westeurope.azmk8s.io
    Mounts:
      /data from data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from stellar-core-token-pbdfm (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
Volumes:
  data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  stellar-core
    ReadOnly:   false
  stellar-core-token-pbdfm:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  stellar-core-token-pbdfm
    Optional:    false
QoS Class:       Burstable
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type     Reason              Age                   From                               Message
  ----     ------              ----                  ----                               -------
  Warning  FailedScheduling    59m (x3 over 59m)     default-scheduler                  pod has unbound PersistentVolumeClaims (repeated 2 times)
  Normal   Scheduled           59m                   default-scheduler                  Successfully assigned default/stellar-core-95bd7f4f4-8thrp to aks-nodepool1-50223173-0
  Warning  FailedAttachVolume  2m34s (x36 over 59m)  attachdetach-controller            AttachVolume.Attach failed for volume "pvc-0f7acf68-fcba-11e8-b233-ba153903c155" : Attach volume "kubernetes-dynamic-pvc-0f7acf68-fcba-11e8-b233-ba153903c155" to instance "/subscriptions/0aba6a11-6e19-400f-a5a9-b6bd2373b4ca/resourceGroups/MC_at-recruit_at-recruit-aks-aks_westeurope/providers/Microsoft.Compute/virtualMachines/aks-nodepool1-50223173-0" failed with compute.VirtualMachinesClient#CreateOrUpdate: Failure sending request: StatusCode=409 -- Original Error: failed request: autorest/azure: Service returned an error. Status=<nil> Code="AttachDiskWhileBeingDetached" Message="Cannot attach data disk 'kubernetes-dynamic-pvc-df634249-fc3d-11e8-b233-ba153903c155' to VM 'aks-nodepool1-50223173-0' because the disk is currently being detached or the last detach operation failed. Please wait until the disk is completely detached and then try again or delete/detach the disk explicitly again." Target="dataDisks"
  Warning  FailedMount         56s (x26 over 57m)    kubelet, aks-nodepool1-50223173-0  Unable to mount volumes for pod "stellar-core-95bd7f4f4-8thrp_default(0fc2237b-fcba-11e8-b233-ba153903c155)": timeout expired waiting for volumes to attach or mount for pod "default"/"stellar-core-95bd7f4f4-8thrp". list of unmounted volumes=[data]. list of unattached volumes=[data stellar-core-token-pbdfm]
  ```
### Reference:
- [Azure disk PVC Multi-Attach error, makes disk mount very slow or mount failure forever](https://github.com/kubernetes/cloud-provider-azure/blob/master/docs/azuredisk-issues.md#5-azure-disk-pvc-multi-attach-error-makes-disk-mount-very-slow-or-mount-failure-forever)
- [the disk is currently being detached or the last detach operation failed #615](https://github.com/Azure/AKS/issues/615)
