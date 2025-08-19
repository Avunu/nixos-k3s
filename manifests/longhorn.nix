{
  apiVersion = "helm.cattle.io/v1";
  kind = "HelmChart";
  metadata = {
    name = "longhorn";
    namespace = "kube-system";
  };
  spec = {
    chart = "longhorn/longhorn";
    version = "1.7.1";
    repo = "https://charts.longhorn.io";
    targetNamespace = "longhorn-system";
    valuesContent = ''
      defaultSettings:
        defaultDataPath: /mnt/juicefs/longhorn
        defaultReplicaCount: 2
        guaranteedEngineManagerCPU: 12
        guaranteedReplicaManagerCPU: 12
      persistence:
        defaultClass: false
        defaultClassReplicaCount: 2
      csi:
        attacherReplicaCount: 1
        provisionerReplicaCount: 1
      ingress:
        enabled: false
      longhornManager:
        tolerations:
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"
      longhornDriver:
        tolerations:
          - key: "node-role.kubernetes.io/master"
            operator: "Exists"
            effect: "NoSchedule"
    '';
  };
}