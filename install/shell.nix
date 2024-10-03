{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Basic system tools
    coreutils
    util-linux
    
    # Filesystem tools
    btrfs-progs
    
    # Network and download tools
    curl
    
    # JSON parsing
    jq
    
    # NixOS installation tools
    nixos-install-tools
    
    # Text processing
    gnused
    gawk
    
    # For secure input (used in get_github_token function)
    bash
  ];

  shellHook = ''
    echo "NixOS Agent Installation Environment"
    echo "Run your installation script in this shell to ensure all dependencies are available."
  '';
}