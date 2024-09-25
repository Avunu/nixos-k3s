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
        defaultDataPath: /var/lib/longhorn
      persistence:
        defaultClass: true
        defaultClassReplicaCount: 3
      csi:
        attacherReplicaCount: 1
        provisionerReplicaCount: 1
      ingress:
        enabled: false
    '';
  };
}