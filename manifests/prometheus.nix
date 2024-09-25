{
  apiVersion = "helm.cattle.io/v1";
  kind = "HelmChart";
  metadata = {
    name = "prometheus";
    namespace = "kube-system";
  };
  spec = {
    chart = "prometheus-community/prometheus";
    version = "20.0.1";
    repo = "https://prometheus-community.github.io/helm-charts";
    targetNamespace = "monitoring";
    valuesContent = ''
      alertmanager:
        enabled: true
      server:
        persistentVolume:
          enabled: true
          size: 8Gi
    '';
  };
}