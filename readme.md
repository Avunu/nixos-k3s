A WIP declarative k3s cluster deployment tailored for public cloud OpenStack.

- **Objective**: Deploy a fault-tolerant, highly-optimized k3s cluster with a hybrid use of OpenStack and bare-metal agents.
- **Provisioning**: Master provisioned with NixOS via a custom image deployed to OpenStack. Bare-metal agents installed manually. Ongoing updates are manged via flake-based configuration and updates.
- **Ingress Controller**: Integrated with the **Octavia Ingress Controller** for native OpenStack load balancing.
- **Storage Engine**: 
  - Use **Longhorn** as the storage engine.
  - Ensure **Longhorn v2 readiness**.
  - Configure Longhorn to use as the underlying disks on the bare-metal agents.
- **Datastore Backend**: Experiment with Supabase as external K3s datastore.

## Installing a bare-metal agent

`install/install-nixos-agent.sh` formats two drives as btrfs RAID1, generates the NixOS configuration
and fetches this cluster's settings and secrets from a private GitHub repository that you own. That
repository is not part of this project, so its name is passed in rather than built in:

```sh
K3S_CONFIGS_REPO=<owner>/<repo> bash install/install-nixos-agent.sh /dev/sda /dev/sdb
```

The root of that repository must contain `environment`, `envs`, `pubkey` and `tokenFile`
(`install/environment.template` and `install/k3s-env.template` show the first two). The script asks
for a GitHub access token with read access to it. It refuses to start, before touching any disk, if
`K3S_CONFIGS_REPO` is unset or is not of the form `owner/name`.
