A WIP declarative k3s cluster deployment tailored for public cloud OpenStack.

- **Objective**: Deploy a fault-tolerant, highly-optimized k3s cluster with a hybrid use of OpenStack and bare-metal agents.
- **Provisioning**: Master provisioned with NixOS via a custom image deployed to OpenStack. Bare-metal agents installed manually. Ongoing updates are manged via flake-based configuration and updates.
- **Ingress Controller**: Integrate with the **Octavia Ingress Controller**.
- **Storage Engine**: 
  - Use **JuiceFS** as the primary distributed storage engine with OVHcloud Object Storage backend.
  - **Longhorn** as secondary storage engine, now using JuiceFS as backend storage.
  - Ensure **Longhorn v2 readiness**.
  - No dependency on local disk availability.
- **Datastore Backend**: Experiment with Supabase as external K3s datastore.
