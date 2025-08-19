A WIP declarative k3s cluster deployment tailored for public cloud OpenStack.

- **Objective**: Deploy a fault-tolerant, highly-optimized k3s cluster with a hybrid use of OpenStack and bare-metal agents.
- **Provisioning**: Master provisioned with NixOS via a custom image deployed to OpenStack. Bare-metal agents installed manually. Ongoing updates are manged via flake-based configuration and updates.
- **Ingress Controller**: Integrate with the **Octavia Ingress Controller**.
- **Storage Engine**: 
  - Use **Longhorn** as the storage engine.
  - Ensure **Longhorn v2 readiness**.
  - Configure Longhorn to use as the underlying disks on the bare-metal agents.
- **Datastore Backend**: Uses NixOS-provisioned etcd as external K3s datastore with TLS authentication.

## Architecture

### etcd Datastore
The cluster uses an external etcd datastore instead of the embedded k3s database:
- etcd service runs on the master node with TLS encryption
- Self-signed certificates automatically generated for authentication
- k3s configured to connect to etcd via `--datastore-endpoint`
- etcd listens on the k3s API network (10.200.1.10:2379/2380)
- Firewall configured to allow etcd client and peer communication
