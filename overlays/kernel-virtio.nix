# overlays/kernel-master.nix
self: super: {
  linuxPackages_virtio = super.linuxPackages_latest.extend (
    self: super: {
      kernel =
        (super.kernel.override {
          structuredExtraConfig = with super.lib.kernel; {
            # Base virtualization support
            HYPERVISOR_GUEST = yes;
            PARAVIRT = yes;
            KVM_GUEST = yes;

            # Virtio support
            VIRTIO = yes;
            VIRTIO_PCI = yes;
            VIRTIO_NET = yes;
            VIRTIO_BLK = yes;
            VIRTIO_CONSOLE = yes;
            VIRTIO_BALLOON = yes;
            VIRTIO_INPUT = yes;
            VIRTIO_MMIO = yes;
            VIRTIO_RING = yes;

            # Minimal filesystem support (adjust as needed)
            EXT4_FS = yes;
            FUSE_FS = yes;

            # Disable unnecessary drivers
            ETHERNET = no;
            NET_VENDOR_INTEL = no;
            NET_VENDOR_AMD = no;
            NET_VENDOR_REALTEK = no;
            FUSION = no;
            DRM = no;
            AGP = no;
            USB_SUPPORT = no;

            # Specific configs for master node
            PREEMPT = no;
            HZ = hz100;

            # Disable debugging and other unnecessary features
            DEBUG_KERNEL = no;
            KGDB = no;
            UNUSED_SYMBOLS = no;
            TRIM_UNUSED_KSYMS = yes;
          };
        }).overrideAttrs
          (oldAttrs: {
            extraConfig = ''
              CC = "${self.buildPackages.llvmPackages_19.clang}/bin/clang"
              CFLAGS = "$CFLAGS -O3 -flto -march=x86-64-v3 -mtune=x86-64-v3"
              LDFLAGS = "$LDFLAGS -flto"
            '';
            stdenv = self.buildPackages.ccacheStdenv;
          });
    }
  );
}
