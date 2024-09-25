{
  apiVersion = "helm.cattle.io/v1";
  kind = "HelmChart";
  metadata = {
    name = "kube-state-metrics";
    namespace = "kube-system";
  };
  spec = {
    chart = "prometheus-community/kube-state-metrics";
    version = "5.11.5";
    repo = "https://prometheus-community.github.io/helm-charts";
    targetNamespace = "monitoring";
  };
}