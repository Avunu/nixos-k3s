# JuiceFS Deployment Checklist

## Prerequisites

### OVHcloud Setup
- [ ] OVHcloud account with Object Storage service enabled
- [ ] Create Object Storage container (bucket) named `juicefs-k3s`
- [ ] Generate S3-compatible API credentials (access key + secret key)
- [ ] Note your OVHcloud region (gra, sbg, or bhs)

### Environment Preparation
- [ ] Copy configuration template: `cp docs/juicefs-config.env.example /etc/juicefs/config`
- [ ] Edit `/etc/juicefs/config` with your OVHcloud credentials
- [ ] Ensure Redis connectivity between master and agent nodes
- [ ] Verify network connectivity to OVHcloud S3 endpoints

## Deployment Steps

### 1. System Level Configuration
- [ ] Deploy updated master configuration with Redis and JuiceFS
- [ ] Verify Redis is running: `systemctl status redis-juicefs`
- [ ] Verify JuiceFS mount on master: `systemctl status juicefs-k3s-storage`
- [ ] Check mount point: `df -h /mnt/juicefs`

### 2. Agent Configuration  
- [ ] Deploy updated agent configuration with JuiceFS client
- [ ] Verify JuiceFS mount on agents: `systemctl status juicefs-k3s-storage`
- [ ] Test connectivity to master Redis from agents
- [ ] Verify mount consistency across all nodes

### 3. Kubernetes Integration
- [ ] Verify JuiceFS CSI driver deployment: `kubectl get pods -n kube-system | grep juicefs`
- [ ] Check storage class: `kubectl get storageclass juicefs-sc`
- [ ] Verify Longhorn deployment with new path: `kubectl get pods -n longhorn-system`
- [ ] Test PVC creation with JuiceFS storage class

### 4. Testing
- [ ] Create test PVC with JuiceFS storage class
- [ ] Deploy test pod and verify volume mounting
- [ ] Write test data and verify persistence across pod restarts
- [ ] Test data visibility across different nodes

## Validation Commands

```bash
# System level
systemctl status redis-juicefs
systemctl status juicefs-k3s-storage
df -h /mnt/juicefs
ls -la /mnt/juicefs/

# Kubernetes level  
kubectl get storageclass
kubectl get pods -n kube-system | grep juicefs
kubectl get pods -n longhorn-system

# Test PVC
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-juicefs-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: juicefs-sc
  resources:
    requests:
      storage: 1Gi
EOF

kubectl get pvc test-juicefs-pvc
```

## Troubleshooting

### Common Issues
- [ ] **Mount fails**: Check OVHcloud credentials and network connectivity
- [ ] **Redis connection**: Verify firewall rules between master and agents  
- [ ] **CSI driver issues**: Check Helm chart deployment and Redis cluster
- [ ] **Performance**: Adjust cache settings in JuiceFS configuration

### Log Files
- System JuiceFS: `journalctl -u juicefs-k3s-storage`
- Redis: `journalctl -u redis-juicefs`
- CSI driver: `kubectl logs -n kube-system -l app=juicefs-csi-driver`

### Monitoring
- JuiceFS metrics: Available via systemd and CSI driver
- Object storage usage: OVHcloud console
- Performance: Monitor cache hit rates and network usage

## Post-Deployment

- [ ] Monitor storage usage and performance
- [ ] Set up backup strategies for Redis metadata
- [ ] Configure monitoring and alerting
- [ ] Document any environment-specific configurations
- [ ] Plan for scaling and disaster recovery scenarios