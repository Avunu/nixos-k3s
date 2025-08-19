# JuiceFS Integration

This repository now includes JuiceFS integration as a distributed file system alternative to Longhorn's local storage dependency.

## Overview

JuiceFS is configured to use OVHcloud Object Storage as the backend storage, with Redis for metadata storage. This provides a truly distributed storage solution that doesn't rely on local disk availability.

## Configuration

### Prerequisites

1. **OVHcloud Object Storage**: Create an Object Storage container in your OVHcloud project
2. **S3 credentials**: Generate S3-compatible API credentials for your Object Storage

### Setup

1. **Configure credentials**: Copy the example configuration and customize it:
   ```bash
   cp docs/juicefs-config.env.example /etc/juicefs/config
   # Edit /etc/juicefs/config with your OVHcloud credentials
   ```

2. **Environment variables**: The configuration expects these environment variables:
   - `ACCESS_KEY`: Your OVHcloud Object Storage access key
   - `SECRET_KEY`: Your OVHcloud Object Storage secret key
   - `ENDPOINT`: S3 endpoint (default: https://s3.gra.io.cloud.ovh.net)
   - `BUCKET`: Object Storage container name

### Components

#### System Level (NixOS)
- **JuiceFS package**: Installed on all nodes
- **Redis**: Running on master node for metadata storage
- **JuiceFS mount**: `/mnt/juicefs` mounted on all nodes

#### Kubernetes Level
- **JuiceFS CSI Driver**: Deployed via Helm chart
- **Storage Class**: `juicefs-sc` for dynamic provisioning
- **Redis cluster**: For CSI driver metadata (separate from system Redis)

### Storage Classes

Two storage options are available:

1. **JuiceFS Storage Class** (`juicefs-sc`): 
   - Fully distributed storage
   - No local disk dependency
   - Uses OVHcloud Object Storage

2. **Longhorn** (modified):
   - Uses JuiceFS mount as backend storage
   - Provides additional replication and snapshot features
   - Path: `/mnt/juicefs/longhorn`

## Usage

### Direct JuiceFS Usage
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: juicefs-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: juicefs-sc
  resources:
    requests:
      storage: 10Gi
```

### Longhorn with JuiceFS Backend
Longhorn continues to work as before, but now uses distributed storage instead of local disks.

## Benefits

1. **No local storage dependency**: Storage survives node failures
2. **Scalable**: Object storage scales independently of compute nodes
3. **Cost-effective**: Pay only for storage used
4. **Multi-region**: Can span multiple OVHcloud regions
5. **POSIX compatible**: Full filesystem semantics
6. **High performance**: Configurable caching for optimal performance

## Monitoring

JuiceFS metrics are available through:
- System-level: via systemd service status
- Kubernetes-level: via CSI driver metrics
- Object storage: via OVHcloud monitoring

## OVHcloud Regions

Available S3 endpoints:
- Gravelines (France): `https://s3.gra.io.cloud.ovh.net`
- Strasbourg (France): `https://s3.sbg.io.cloud.ovh.net`
- Beauharnois (Canada): `https://s3.bhs.io.cloud.ovh.net`

Choose the region closest to your deployment for optimal performance.