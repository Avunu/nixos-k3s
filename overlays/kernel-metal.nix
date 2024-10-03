# overlays/kernel-agent.nix
self: super: {
  linuxPackages_metal = super.linuxPackages_latest.extend (
    self: super: {
      kernel =
        (super.kernel.override {
          structuredExtraConfig = with super.lib.kernel; {
            # Basic hardware support (adjust based on your hardware)
            SMP = yes;
            MCORE2 = yes;
            CPU_FREQ_DEFAULT_GOV_PERFORMANCE = yes;

            # Networking
            ETHERNET = yes;
            NET_VENDOR_INTEL = yes; # Adjust based on your NIC
            NETDEVICES = yes;
            NETWORK_FILESYSTEMS = yes;

            # Storage
            SATA_AHCI = yes;
            ATA_SFF = yes;
            ATA_BMDMA = yes;
            ATA_PIIX = yes;

            # Filesystems (adjust as needed)
            EXT4_FS = yes;
            BTRFS_FS = yes;
            XFS_FS = yes;
            FUSE_FS = yes;

            # Other essential features
            ACPI = yes;
            PCI = yes;
            PCIEPORTBUS = yes;

            # Security features
            SECURITY = yes;
            SECURITY_NETWORK = yes;
            SECURITY_SELINUX = yes;

            # Specific configs for agent nodes
            PREEMPT = yes;
            HZ = hz1000;

            # Debugging (you might want to disable these in production)
            DEBUG_KERNEL = yes;
            DYNAMIC_DEBUG = yes;
          };
        }).overrideAttrs
          {
            extraConfig = ''
              CC = "${self.buildPackages.llvmPackages_19.clang}/bin/clang"
              CFLAGS = "$CFLAGS -O3 -flto -march=x86-64-v4 -mtune=x86-64-v4"
              LDFLAGS = "$LDFLAGS -flto"
            '';
            stdenv = self.buildPackages.ccacheStdenv;
          };
    }
  );
}
