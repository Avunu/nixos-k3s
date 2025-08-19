{
  config,
  lib,
  pkgs,
  ...
}:

let
  networkConfig = (import ../network-config.nix).networkConfig;
in
{
  services.etcd = {
    enable = true;
    name = config.networking.hostName;
    
    # Data directory
    dataDir = "/var/lib/etcd";
    
    # Network configuration - listen on k3s API network interface
    listenClientUrls = [
      "https://0.0.0.0:2379"
      "https://127.0.0.1:2379"
    ];
    advertiseClientUrls = [
      "https://${networkConfig.k3sApi.masterIp}:2379"
    ];
    
    # Peer communication for clustering
    listenPeerUrls = [
      "https://0.0.0.0:2380"
    ];
    initialAdvertisePeerUrls = [
      "https://${networkConfig.k3sApi.masterIp}:2380"
    ];
    
    # Cluster configuration - single node initially, can be expanded
    initialCluster = [
      "${config.networking.hostName}=https://${networkConfig.k3sApi.masterIp}:2380"
    ];
    initialClusterState = "new";
    initialClusterToken = "k3s-etcd-cluster";
    
    # TLS Configuration - using self-signed certificates for now
    clientCertAuth = true;
    certFile = "/var/lib/etcd/certs/server.crt";
    keyFile = "/var/lib/etcd/certs/server.key";
    trustedCaFile = "/var/lib/etcd/certs/ca.crt";
    
    # Peer TLS
    peerClientCertAuth = true;
    peerCertFile = "/var/lib/etcd/certs/peer.crt";
    peerKeyFile = "/var/lib/etcd/certs/peer.key";
    peerTrustedCaFile = "/var/lib/etcd/certs/ca.crt";
    
    # Open firewall for etcd
    openFirewall = true;
    
    # Extra configuration
    extraConf = {
      # Enable v2 API for compatibility if needed
      "enable-v2" = "false";
      # Optimize for reliability
      "heartbeat-interval" = "100";
      "election-timeout" = "1000";
      # Logging
      "log-level" = "info";
    };
  };

  # Open additional firewall ports
  networking.firewall.allowedTCPPorts = [ 2379 2380 ];

  # Create etcd certificates directory and generate self-signed certificates
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
      
      # Generate CA key and certificate if they don't exist
      if [[ ! -f ca.key ]] || [[ ! -f ca.crt ]]; then
        ${pkgs.openssl}/bin/openssl genrsa -out ca.key 4096
        ${pkgs.openssl}/bin/openssl req -new -x509 -days 3650 -key ca.key -out ca.crt \
          -subj "/C=US/ST=CA/L=Local/O=k3s/OU=etcd/CN=etcd-ca"
      fi
      
      # Generate server key and certificate if they don't exist
      if [[ ! -f server.key ]] || [[ ! -f server.crt ]]; then
        ${pkgs.openssl}/bin/openssl genrsa -out server.key 4096
        ${pkgs.openssl}/bin/openssl req -new -key server.key -out server.csr \
          -subj "/C=US/ST=CA/L=Local/O=k3s/OU=etcd/CN=etcd-server"
        
        # Create extension file for server certificate
        cat > server.ext << EOF
      authorityKeyIdentifier=keyid,issuer
      basicConstraints=CA:FALSE
      keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
      subjectAltName = @alt_names
      
      [alt_names]
      DNS.1 = localhost
      DNS.2 = ${config.networking.hostName}
      IP.1 = 127.0.0.1
      IP.2 = ${networkConfig.k3sApi.masterIp}
      EOF
        
        ${pkgs.openssl}/bin/openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key \
          -CAcreateserial -out server.crt -days 365 -extensions v3_req -extfile server.ext
        rm server.csr server.ext
      fi
      
      # Generate peer key and certificate if they don't exist
      if [[ ! -f peer.key ]] || [[ ! -f peer.crt ]]; then
        ${pkgs.openssl}/bin/openssl genrsa -out peer.key 4096
        ${pkgs.openssl}/bin/openssl req -new -key peer.key -out peer.csr \
          -subj "/C=US/ST=CA/L=Local/O=k3s/OU=etcd/CN=etcd-peer"
        
        # Create extension file for peer certificate
        cat > peer.ext << EOF
      authorityKeyIdentifier=keyid,issuer
      basicConstraints=CA:FALSE
      keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
      subjectAltName = @alt_names
      
      [alt_names]
      DNS.1 = localhost
      DNS.2 = ${config.networking.hostName}
      IP.1 = 127.0.0.1
      IP.2 = ${networkConfig.k3sApi.masterIp}
      EOF
        
        ${pkgs.openssl}/bin/openssl x509 -req -in peer.csr -CA ca.crt -CAkey ca.key \
          -CAcreateserial -out peer.crt -days 365 -extensions v3_req -extfile peer.ext
        rm peer.csr peer.ext
      fi
      
      # Set proper permissions
      chown -R etcd:etcd "$CERT_DIR"
      chmod 600 "$CERT_DIR"/*.key
      chmod 644 "$CERT_DIR"/*.crt
    '';
  };
}