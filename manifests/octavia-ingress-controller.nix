# Octavia Ingress Controller for OpenStack integration
# This replaces the default traefik ingress controller with OpenStack Octavia

''
---
apiVersion: v1
kind: Namespace
metadata:
  name: octavia-ingress-controller
  labels:
    name: octavia-ingress-controller
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: octavia-ingress-controller
  namespace: octavia-ingress-controller
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: octavia-ingress-controller
rules:
- apiGroups: [""]
  resources: ["endpoints", "services", "secrets", "configmaps"]
  verbs: ["get", "list", "watch", "create", "patch", "update", "delete"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["list", "watch", "get"]
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["list", "watch"]
- apiGroups: ["extensions", "networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get", "list", "watch", "create", "patch", "update", "delete"]
- apiGroups: ["extensions", "networking.k8s.io"]
  resources: ["ingresses/status"]
  verbs: ["update"]
- apiGroups: [""]
  resources: ["events"]
  verbs: ["create", "patch", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: octavia-ingress-controller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: octavia-ingress-controller
subjects:
- kind: ServiceAccount
  name: octavia-ingress-controller
  namespace: octavia-ingress-controller
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: octavia-ingress-controller
  namespace: octavia-ingress-controller
  labels:
    app: octavia-ingress-controller
spec:
  replicas: 1
  selector:
    matchLabels:
      app: octavia-ingress-controller
  template:
    metadata:
      labels:
        app: octavia-ingress-controller
    spec:
      serviceAccountName: octavia-ingress-controller
      hostNetwork: true
      dnsPolicy: ClusterFirstWithHostNet
      containers:
      - name: octavia-ingress-controller
        image: "k8scloudprovider/octavia-ingress-controller:v1.25.0"
        imagePullPolicy: IfNotPresent
        command:
        - /bin/octavia-ingress-controller
        - --cluster-name=k3s
        - --ingress-class=octavia
        args:
        - --v=2
        env:
        - name: KUBERNETES_NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        ports:
        - name: http
          containerPort: 10254
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 30
          timeoutSeconds: 5
        readinessProbe:
          httpGet:
            path: /healthz
            port: 10254
            scheme: HTTP
          initialDelaySeconds: 5
          timeoutSeconds: 5
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
      tolerations:
      - key: node.cloudprovider.kubernetes.io/uninitialized
        value: "true"
        effect: NoSchedule
      - key: node-role.kubernetes.io/control-plane
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
      nodeSelector:
        node-role.kubernetes.io/control-plane: "true"
''