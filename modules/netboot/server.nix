# modules/netboot-server.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.netboot;
in {
  options.netboot = {
    interface = mkOption {
      type = types.str;
      default = "eth0";
      description = "Network interface for DHCP server";
    };
    ipRange = mkOption {
      type = types.str;
      default = "192.168.1.100,192.168.1.200";
      description = "IP range for DHCP server";
    };
    domainName = mkOption {
      type = types.str;
      default = "netboot.local";
      description = "Domain name for the netboot network";
    };
  };

  config = {
    # systemd-boot configuration
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # TFTP server setup
    services.tftpd = {
      enable = true;
      path = "/var/tftpboot";
    };

    # Prepare netboot files
    system.activationScripts.setupTftpboot = ''
      mkdir -p /var/tftpboot/EFI/BOOT
      cp ${pkgs.systemd}/lib/systemd/boot/efi/systemd-bootx64.efi /var/tftpboot/EFI/BOOT/BOOTX64.EFI
      cp ${config.boot.kernelPackages.kernel}/bzImage /var/tftpboot/vmlinuz
      cp ${config.system.build.initialRamdisk}/initrd /var/tftpboot/initrd
    '';

    # Create generic boot entry
    environment.etc."tftpboot/loader/entries/nixos.conf".text = ''
      title NixOS
      linux /vmlinuz
      initrd /initrd
      options rw ip=dhcp root=LABEL=nixos-root
    '';

    # dnsmasq configuration
    services.dnsmasq = {
      enable = true;
      settings = {
        interface = cfg.interface;
        dhcp-range = cfg.ipRange;
        domain = cfg.domainName;
        dhcp-boot = "EFI/BOOT/BOOTX64.EFI";
        # Disable DNS functionality
        port = 0;
        # Enable TFTP
        enable-tftp = true;
        tftp-root = "/var/tftpboot";
      };
    };

    # Open necessary ports
    networking.firewall = {
      allowedTCPPorts = [ 69 ];  # TFTP
      allowedUDPPorts = [ 67 68 69 ];  # DHCP and TFTP
    };
  };
}