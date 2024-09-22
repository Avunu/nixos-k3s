A WIP declarative k3s cluster deployment tailored for public cloud OpenStack.

- **Objective**: Deploy a fault-tolerant, highly-optimized k3s cluster directly on OpenStack.
- **Provisioning**: Nodes provisioned with NixOS via a custom image deployed to OpenStack. Ongoing updates are manged via flake-based configuration and updates.
- **Cluster Auto-scaling**: 
  - **Server nodes**: Manually configured.
  - **Agent nodes**: Automatically deployed via Kubernetes Cluster Autoscaler.
- **Ingress Controller**: Integrate with the **Octavia Ingress Controller**.
- **Storage Engine**: 
  - Use **Longhorn** as the storage engine.
  - Ensure **Longhorn v2 readiness**.
  - Configure Longhorn to use **Cinder CSI block storage** as the underlying storage.
- **Datastore Backend**: Experiment with Supabase as external K3s datastore.
