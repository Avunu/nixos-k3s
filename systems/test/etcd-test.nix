{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./common.test.nix
  ];

  networking.hostName = "k3s-etcd-test";

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "ext4";
  };

  # Simple etcd configuration for testing
  services.etcd = {
    enable = true;
    name = "test-etcd";
    
    # Basic configuration without network references
    dataDir = "/var/lib/etcd";
    
    listenClientUrls = [
      "https://127.0.0.1:2379"
    ];
    advertiseClientUrls = [
      "https://127.0.0.1:2379"
    ];
    
    listenPeerUrls = [
      "https://127.0.0.1:2380"
    ];
    initialAdvertisePeerUrls = [
      "https://127.0.0.1:2380"
    ];
    
    initialCluster = [
      "test-etcd=https://127.0.0.1:2380"
    ];
    initialClusterState = "new";
    initialClusterToken = "test-etcd-cluster";
    
    # TLS Configuration
    clientCertAuth = true;
    certFile = "/var/lib/etcd/certs/server.crt";
    keyFile = "/var/lib/etcd/certs/server.key";
    trustedCaFile = "/var/lib/etcd/certs/ca.crt";
    
    peerClientCertAuth = true;
    peerCertFile = "/var/lib/etcd/certs/peer.crt";
    peerKeyFile = "/var/lib/etcd/certs/peer.key";
    peerTrustedCaFile = "/var/lib/etcd/certs/ca.crt";
    
    openFirewall = true;
  };

  # Certificate generation service
  systemd.services.etcd-cert-setup = {
    description = "Setup etcd certificates";
    before = [ "etcd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail
      
      CERT_DIR="/var/lib/etcd/certs"
      mkdir -p "$CERT_DIR"
      cd "$CERT_DIR"
      
      # Generate CA
      if [[ ! -f ca.key ]] || [[ ! -f ca.crt ]]; then
        ${pkgs.openssl}/bin/openssl genrsa -out ca.key 4096
        ${pkgs.openssl}/bin/openssl req -new -x509 -days 3650 -key ca.key -out ca.crt \
          -subj "/C=US/ST=CA/L=Local/O=k3s/OU=etcd/CN=etcd-ca"
      fi
      
      # Generate server certificate
      if [[ ! -f server.key ]] || [[ ! -f server.crt ]]; then
        ${pkgs.openssl}/bin/openssl genrsa -out server.key 4096
        ${pkgs.openssl}/bin/openssl req -new -key server.key -out server.csr \
          -subj "/C=US/ST=CA/L=Local/O=k3s/OU=etcd/CN=etcd-server"
        ${pkgs.openssl}/bin/openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key \
          -CAcreateserial -out server.crt -days 365
        rm server.csr
      fi
      
      # Generate peer certificate
      if [[ ! -f peer.key ]] || [[ ! -f peer.crt ]]; then
        ${pkgs.openssl}/bin/openssl genrsa -out peer.key 4096
        ${pkgs.openssl}/bin/openssl req -new -key peer.key -out peer.csr \
          -subj "/C=US/ST=CA/L=Local/O=k3s/OU=etcd/CN=etcd-peer"
        ${pkgs.openssl}/bin/openssl x509 -req -in peer.csr -CA ca.crt -CAkey ca.key \
          -CAcreateserial -out peer.crt -days 365
        rm peer.csr
      fi
      
      # Set permissions
      chown -R etcd:etcd "$CERT_DIR"
      chmod 600 "$CERT_DIR"/*.key
      chmod 644 "$CERT_DIR"/*.crt
    '';
  };

  networking.firewall.allowedTCPPorts = [ 2379 2380 ];
}