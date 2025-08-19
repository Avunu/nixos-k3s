# IngressClass for Octavia Ingress Controller
# This defines the ingress class that users can reference in their Ingress resources

''
---
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: octavia
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: octavia-ingress-controller
    app.kubernetes.io/name: octavia-ingress-controller
  annotations:
    ingressclass.kubernetes.io/is-default-class: "true"
spec:
  controller: openstack.org/octavia
''