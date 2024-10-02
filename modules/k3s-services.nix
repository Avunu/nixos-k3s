{ config, pkgs, ... }:
{
  # Server-specific configuration
  services.k3s = {
    manifests = {
      longhorn = {
        target = "longhorn.yaml";
        content = builtins.import ./manifests/longhorn.nix;
      };
      prometheus = {
        target = "prometheus.yaml";
        content = builtins.import ./manifests/prometheus.nix;
      };
      kubeStateMetrics = {
        target = "kube-state-metrics.yaml";
        content = builtins.import ./manifests/kube-state-metrics.nix;
      };
      certManager = {
        target = "cert-manager.yaml";
        content = builtins.import ./manifests/cert-manager.nix;
      };
    };
  };
}