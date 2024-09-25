{
  apiVersion = "helm.cattle.io/v1";
  kind = "HelmChart";
  metadata = {
    name = "cert-manager";
    namespace = "kube-system";
  };
  spec = {
    chart = "jetstack/cert-manager";
    version = "v1.12.0";
    repo = "https://charts.jetstack.io";
    targetNamespace = "cert-manager";
    set = {
      installCRDs = "true";
    };
  };
}