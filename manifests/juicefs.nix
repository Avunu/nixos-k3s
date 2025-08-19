{
  apiVersion = "helm.cattle.io/v1";
  kind = "HelmChart";
  metadata = {
    name = "juicefs-csi-driver";
    namespace = "kube-system";
  };
  spec = {
    chart = "juicefs-csi-driver";
    version = "0.21.0";
    repo = "https://juicedata.github.io/charts/";
    targetNamespace = "kube-system";
    valuesContent = ''
      controller:
        replicas: 1
        resources:
          limits:
            cpu: 1000m
            memory: 1Gi
          requests:
            cpu: 100m
            memory: 512Mi
      
      node:
        resources:
          limits:
            cpu: 2000m
            memory: 5Gi
          requests:
            cpu: 100m
            memory: 512Mi
        hostNetwork: false
        storageClassShareMount: false
        
      storageClasses:
        - name: "juicefs-sc"
          enabled: true
          reclaimPolicy: "Retain"
          backend:
            name: "ovh-s3"
            metaurl: "redis://juicefs-redis:6379/1"
            storage: "s3"
            bucket: "juicefs-k3s"
            endpoint: "https://s3.gra.io.cloud.ovh.net"
          mountPod:
            resources:
              limits:
                cpu: 5000m
                memory: 5Gi
              requests:
                cpu: 1000m
                memory: 1Gi
      
      # Redis for metadata storage
      redis:
        enabled: true
        auth:
          enabled: false
        master:
          persistence:
            enabled: true
            size: 8Gi
        replica:
          replicaCount: 1
          persistence:
            enabled: true
            size: 8Gi
    '';
  };
}