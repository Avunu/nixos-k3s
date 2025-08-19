# Octavia Ingress Controller

This k3s cluster is configured to use the OpenStack Octavia Ingress Controller instead of a traditional ingress controller like traefik or nginx-ingress.

## Overview

The Octavia Ingress Controller integrates directly with OpenStack's Octavia load balancer service to provide ingress capabilities. This provides:

- Native OpenStack integration
- Automatic load balancer provisioning
- High availability through OpenStack infrastructure
- Cost-effective load balancing using cloud-native services

## Usage

### Basic Ingress Example

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  namespace: default
spec:
  ingressClassName: octavia  # Uses the Octavia Ingress Controller
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: example-service
            port:
              number: 80
```

### Advanced Configuration

You can configure the Octavia load balancer behavior using annotations:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    octavia.ingress.kubernetes.io/load-balancer-class: "amphora"
    octavia.ingress.kubernetes.io/internal: "false"
spec:
  ingressClassName: octavia
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: example-service
            port:
              number: 80
```

## Configuration Details

- **Controller Image**: `k8scloudprovider/octavia-ingress-controller:v1.25.0`
- **Default Ingress Class**: `octavia` (set as default)
- **Namespace**: `octavia-ingress-controller`
- **Controller Name**: `openstack.org/octavia`

## Prerequisites

1. OpenStack cluster with Octavia service enabled
2. Proper OpenStack cloud provider configuration
3. Network connectivity between k3s nodes and OpenStack API

## Troubleshooting

Check the controller logs:
```bash
kubectl logs -n octavia-ingress-controller deployment/octavia-ingress-controller
```

Verify the ingress class:
```bash
kubectl get ingressclass
```

Check ingress resources:
```bash
kubectl get ingress -A
```