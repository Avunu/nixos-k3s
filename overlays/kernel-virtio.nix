# overlays/kernel-virtio.nix
self: super:

let
  pkgs = self;
  inherit (pkgs) lib;
in
{
  linuxPackages_virtio = super.linuxPackages_latest.extend (
    self: super: {
      kernel = super.kernel.override {
        stdenv = pkgs.stdenvLLVM;
        buildPackages = pkgs.buildPackages // {
          stdenv = pkgs.stdenvLLVM;
        };
        extraMakeFlags = [
          "KCFLAGS+=-flto"
          "KCFLAGS+=-march=haswell"
          "KCFLAGS+=-mtune=haswell"
          "KCFLAGS+=-O3"
          "KCPPFLAGS+=-flto"
          "KCPPFLAGS+=-march=haswell"
          "KCPPFLAGS+=-mtune=haswell"
          "KCPPFLAGS+=-O3"
          "LDFLAGS+=-flto"
          "LDFLAGS+=-O3"
          "LLVM_IAS=1"
          "LLVM=1"
        ];
        structuredExtraConfig = with lib.kernel; {

          # clang optimized build
          CC_OPTIMIZE_FOR_PERFORMANCE_O3 = yes;
          CC_OPTIMIZE_FOR_SIZE = lib.mkForce yes;
          INIT_ON_ALLOC_DEFAULT_ON = yes;
          INIT_STACK_ALL_ZERO = yes;
          LTO_CLANG_FULL = yes;
          MODULE_COMPRESS_ZSTD = yes;
          MZEN = yes;
          RCU_BOOST = no;

          # see https://raw.githubusercontent.com/NixOS/nixpkgs/refs/heads/master/pkgs/os-specific/linux/kernel/common-config.nix

          # Explicitly disable options from common-config.nix
          RANDOM_KMALLOC_CACHES = lib.mkForce no;
          RCU_LAZY = lib.mkForce no;
          RT2800USB_RT53XX = lib.mkForce no;
          RT2800USB_RT55XX = lib.mkForce no;
          RTW88 = lib.mkForce no;
          RTW88_8822BE = lib.mkForce no;
          RTW88_8822CE = lib.mkForce no;
          SECCOMP = lib.mkForce no;
          SECCOMP_FILTER = lib.mkForce no;
          SLAB_BUCKETS = lib.mkForce no;
          SLAB_FREELIST_HARDENED = lib.mkForce no;
          SLAB_FREELIST_RANDOM = lib.mkForce no;

          # no android support
          ANDROID_BINDERFS = lib.mkForce no;
          ANDROID_BINDER_IPC = lib.mkForce no;

          # disable hardware drivers
          DRM_AMDGPU = lib.mkForce no;
          DRM_AMDGPU_CIK = lib.mkForce no;
          DRM_AMDGPU_SI = lib.mkForce no;
          DRM_GMA500 = lib.mkForce no;
          DRM_HYPERV = lib.mkForce no;
          DRM_I915 = lib.mkForce no;
          DRM_I915_GVT = lib.mkForce no;
          DRM_I915_GVT_KVMGT = lib.mkForce no;
          DRM_NOUVEAU = lib.mkForce no;
          DRM_RADEON = lib.mkForce no;
          DRM_VBOXVIDEO = lib.mkForce no;
          INFINIBAND = lib.mkForce no;
          IWLWIFI = lib.mkForce no;


          # Base configuration
          EXPERT = yes;
          MODULES = yes;
          SMP = yes;

          # Virtualization support
          HYPERVISOR_GUEST = yes;
          PARAVIRT = yes;
          KVM_GUEST = yes;

          # Virtio support
          "9P_FS_POSIX_ACL" = yes;
          "9P_FSCACHE" = yes;
          "9P_NET" = yes;
          DRM = yes;
          DRM_FBDEV_EMULATION = yes;
          DRM_VIRTIO_GPU = yes;
          PCI = yes;
          PCI_HOST_GENERIC = yes;
          VIRTIO = yes;
          VIRTIO_BALLOON = yes;
          VIRTIO_BLK = yes;
          VIRTIO_CONSOLE = yes;
          VIRTIO_INPUT = yes;
          VIRTIO_MENU = yes;
          VIRTIO_MMIO = yes;
          VIRTIO_NET = yes;
          VIRTIO_PCI = yes;

          # Minimal filesystem support
          EXT4_FS = yes;
          FUSE_FS = yes;
          BTRFS_FS = no;
          XFS_FS = no;
          F2FS_FS = lib.mkForce no;

          # Networking
          NET = yes;
          INET = yes;
          IP_PNP = lib.mkForce yes;
          IP_PNP_DHCP = yes;
          IPV6 = yes;

          # Disable unnecessary features
          ETHERNET = no;
          NET_VENDOR_INTEL = no;
          NET_VENDOR_AMD = no;
          NET_VENDOR_REALTEK = no;
          AGP = lib.mkForce no;

          # USB_SUPPORT = lib.mkForce no;
          WIRELESS = no;
          WLAN = no;

          # Performance and size optimizations
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

          # Enable AIO support
          AIO = yes;
          # INOTIFY_USER = yes;
          # SIGNALFD = yes;
          # TIMERFD = yes;
          # EPOLL = yes;

          # Additional optimizations
          ADVISE_SYSCALLS = no;
          COREDUMP = no;
          DNOTIFY = no;
          FANOTIFY = lib.mkForce no;
        };
        ignoreConfigErrors = true;
      };
    }
  );
}
