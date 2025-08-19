A WIP declarative k3s cluster deployment tailored for public cloud OpenStack.

- **Objective**: Deploy a fault-tolerant, highly-optimized k3s cluster with a hybrid use of OpenStack and bare-metal agents.
- **Provisioning**: Master provisioned with NixOS via a custom image deployed to OpenStack. Bare-metal agents installed manually. Ongoing updates are manged via flake-based configuration and updates.
- **Ingress Controller**: Integrated with the **Octavia Ingress Controller** for native OpenStack load balancing.
- **Storage Engine**: 
  - Use **Longhorn** as the storage engine.
  - Ensure **Longhorn v2 readiness**.
  - Configure Longhorn to use as the underlying disks on the bare-metal agents.
- **Datastore Backend**: Experiment with Supabase as external K3s datastore.
