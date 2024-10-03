# overlays/kernel-master.nix
self: super:

let
  pkgs = self;
  inherit (pkgs) lib;
in
{
  linuxPackages_virtio = super.linuxPackages_latest.extend (
    self: super: {
      kernel =
        (super.kernel.override {
          structuredExtraConfig = with lib.kernel; {

            # Explicitly disable options from common-config.nix
            RANDOM_KMALLOC_CACHES = lib.mkForce (option no);
            RCU_LAZY = lib.mkForce (option no);
            RT2800USB_RT53XX = lib.mkForce (option no);
            RT2800USB_RT55XX = lib.mkForce (option no);
            RTW88 = lib.mkForce (option no);
            RTW88_8822BE = lib.mkForce (option no);
            RTW88_8822CE = lib.mkForce (option no);
            SECCOMP = lib.mkForce no;
            SECCOMP_FILTER = lib.mkForce (option no);
            SLAB_BUCKETS = lib.mkForce (option no);
            SLAB_FREELIST_HARDENED = lib.mkForce (option no);
            SLAB_FREELIST_RANDOM = lib.mkForce (option no);

            # Base configuration
            EXPERT = yes;
            MODULES = yes;
            SMP = yes;

            # Virtualization support
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

            # Minimal filesystem support
            EXT4_FS = yes;
            FUSE_FS = yes;

            # Networking
            NET = yes;
            INET = yes;
            IP_PNP = lib.mkForce yes;
            IP_PNP_DHCP = yes;

            # Disable unnecessary drivers and features
            ETHERNET = no;
            NET_VENDOR_INTEL = no;
            NET_VENDOR_AMD = no;
            NET_VENDOR_REALTEK = no;
            DRM = lib.mkForce no;
            AGP = lib.mkForce no;
            # USB_SUPPORT = lib.mkForce no;
            IPV6 = yes;
            # WIRELESS = no;
            WLAN = no;

            # Performance and size optimizations
            CC_OPTIMIZE_FOR_SIZE = lib.mkForce yes;
            JUMP_LABEL = yes;
            PREEMPT = no;
            HZ = freeform "100";
            HZ_100 = yes;
            NO_HZ_IDLE = yes;
            HIGH_RES_TIMERS = yes;

            # Memory management
            SLUB_TINY = yes;
            # TRANSPARENT_HUGEPAGE = lib.mkForce no;

            # Disable debugging and unnecessary features
            DEBUG_KERNEL = lib.mkForce no;
            KGDB = no;
            # UNUSED_SYMBOLS = no;
            TRIM_UNUSED_KSYMS = yes;
            KALLSYMS = no;
            MAGIC_SYSRQ = no;
            BUG = lib.mkForce no;

            # Security features (adjust as needed)
            # SECURITY = no;
            # SECCOMP = lib.mkForce no;

            # Additional optimizations
            ADVISE_SYSCALLS = no;
            AIO = lib.mkForce no;
            COREDUMP = no;
            DNOTIFY = no;
            SIGNALFD = no;
            TIMERFD = no;
            EPOLL = no;
            INOTIFY_USER = no;
            FANOTIFY = lib.mkForce no;
          };
          ignoreConfigErrors = true;
        }).overrideAttrs
          (oldAttrs: {
            extraConfig = ''
              CC = "${pkgs.llvmPackages_19.clang}/bin/clang"
              CFLAGS = "$CFLAGS -O3 -flto -march=x86-64-v3 -mtune=x86-64-v3"
              LDFLAGS = "$LDFLAGS -flto"
            '';
            stdenv = pkgs.ccacheStdenv;
          });
    }
  );
}
