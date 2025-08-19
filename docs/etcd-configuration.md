# etcd Configuration Test and Validation

## Basic Setup Validation

To test the etcd configuration:

1. **Build the etcd test configuration:**
   ```bash
   nix build .#etcd-test
   ```

2. **Build the master configuration:**
   ```bash
   nix build .#master
   ```

## Configuration Details

### etcd Service Configuration
- **Data Directory**: `/var/lib/etcd`
- **Client Port**: 2379 (TLS)
- **Peer Port**: 2380 (TLS)
- **Certificates**: Self-signed, stored in `/var/lib/etcd/certs/`

### k3s Integration
- **Datastore Endpoint**: `https://10.200.1.10:2379`
- **Authentication**: TLS with client certificates
- **Service Dependencies**: k3s waits for etcd service

### Network Configuration
- **etcd Interface**: k3s API network (eth2: 10.200.1.10/16)
- **Firewall**: Ports 2379, 2380 opened
- **TLS**: Client and peer authentication enabled

## Expansion for High Availability

To expand etcd for HA (future enhancement):

1. Add additional etcd nodes to the `initialCluster` configuration
2. Update DNS/IP addressing for cluster members
3. Configure k3s with multiple etcd endpoints using comma separation:
   ```
   --datastore-endpoint=https://etcd1:2379,https://etcd2:2379,https://etcd3:2379
   ```

## Troubleshooting

### Check etcd Status
```bash
systemctl status etcd
journalctl -u etcd -f
```

### Verify Certificates
```bash
ls -la /var/lib/etcd/certs/
openssl x509 -in /var/lib/etcd/certs/server.crt -text -noout
```

### Test etcd Connectivity
```bash
# From the master node
etcdctl --endpoints=https://127.0.0.1:2379 \
        --cacert=/var/lib/etcd/certs/ca.crt \
        --cert=/var/lib/etcd/certs/server.crt \
        --key=/var/lib/etcd/certs/server.key \
        endpoint health
```