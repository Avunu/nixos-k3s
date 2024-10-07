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
          # Use Clang and optimize for x86_64_v3 CPUs with LTO and O3
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
          "V=1" # Enable verbose output
          "KBUILD_VERBOSE=1" # Another way to enable verbose output
          # "C=1"  # Enable sparse warnings
        ];
        structuredExtraConfig = with lib.kernel; {
          ## Clang/LLVM Build Options
          CC_IS_CLANG = yes;
          LLVM_IAS = yes;
          LTO_CLANG_FULL = yes;
          CC_OPTIMIZE_FOR_PERFORMANCE_O3 = yes;
          CC_OPTIMIZE_FOR_SIZE = lib.mkForce yes;
          MODULE_COMPRESS_ZSTD = yes;
          INIT_ON_ALLOC_DEFAULT_ON = yes;
          INIT_STACK_ALL_ZERO = yes;

          ## Base Configuration
          EXPERT = yes;
          MODULES = yes;
          SMP = yes;

          ## Virtualization Support
          HYPERVISOR_GUEST = yes;
          PARAVIRT = yes;
          KVM_GUEST = yes;

          ## Virtio Support
          DRM = yes;
          DRM_FBDEV_EMULATION = yes;
          DRM_VIRTIO_GPU = yes;
          INPUT = yes;
          VIRTIO = yes;
          VIRTIO_BALLOON = yes;
          VIRTIO_BLK = yes;
          VIRTIO_CONSOLE = yes;
          VIRTIO_INPUT = yes;
          VIRTIO_MENU = yes;
          VIRTIO_MMIO = yes;
          VIRTIO_NET = yes;
          VIRTIO_PCI = yes;
          "9P_FS_POSIX_ACL" = yes;
          "9P_FS" = module;
          "9P_FSCACHE" = yes;
          "9P_NET" = yes;

          ## Basic Filesystems
          EXT4_FS = yes;
          JBD2 = yes;
          TMPFS = yes;
          PROC_FS = yes;
          SYSFS = yes;

          ## Basic Networking
          NET = yes;
          INET = yes;
          IPV6 = yes;
          NETDEVICES = yes;
          NET_CORE = yes;

          # Ethernet drivers for Virtio
          ETHERNET = module;
          NET_VENDOR_INTEL = yes;

          ## Disable Unnecessary Hardware Support
          AGP = lib.mkForce no;
          FUJITSU_ES = lib.mkForce no;
          HYPERV_NET = lib.mkForce no;
          IEEE802154 = lib.mkForce no;
          NTB_NETDEV = lib.mkForce no;
          SND = lib.mkForce no;
          SOUND = lib.mkForce no;
          USB_NET_DRIVERS = lib.mkForce no;
          USB4_NET = lib.mkForce no;
          WIRELESS = lib.mkForce no;
          XEN_NETDEV_BACKEND = lib.mkForce no;
          XEN_NETDEV_FRONTEND = lib.mkForce no;

          ## Memory Management
          SLUB_TINY = yes;
          TRANSPARENT_HUGEPAGE = lib.mkForce no;

          ## Performance and Size Optimizations
          JUMP_LABEL = yes;
          PREEMPT_NONE = yes;
          HZ = freeform "100";
          HZ_100 = yes;
          NO_HZ_IDLE = yes;
          HIGH_RES_TIMERS = yes;
          TRIM_UNUSED_KSYMS = yes;

          ## Disable Debugging
          DEBUG_KERNEL = lib.mkForce no;
          KGDB = lib.mkForce no;
          KALLSYMS = lib.mkForce no;
          MAGIC_SYSRQ = lib.mkForce no;
          BUG = lib.mkForce no;

          ## Disable Android & ChromeOS Support
          ANDROID_BINDERFS = lib.mkForce no;
          ANDROID_BINDER_IPC = lib.mkForce no;
          CHROME_PLATFORMS = lib.mkForce no;
          CHROMEOS_LAPTOP = lib.mkForce no;
          CHROMEOS_PSTORE = lib.mkForce no;
          CHROMEOS_TBMC = lib.mkForce no;

          ## Disable Unnecessary Filesystems
          AFS_FS = lib.mkForce no;
          BCACHEFS_FS = lib.mkForce no;
          BTRFS_FS = lib.mkForce no;
          CIFS = lib.mkForce no;
          CODA_FS = lib.mkForce no;
          F2FS_FS = lib.mkForce no;
          ISO9660_FS = lib.mkForce no;
          MSDOS_FS = lib.mkForce no;
          NFS_FS = lib.mkForce no;
          NFS_V4 = lib.mkForce no;
          SMB_FS = lib.mkForce no;
          SMB_SERVER = lib.mkForce no;
          UBIFS_FS = lib.mkForce no;
          VFAT_FS = lib.mkForce no;
          XFS_FS = lib.mkForce no;

          ## Disable Unnecessary Cryptography
          CRYPTO_DES = lib.mkForce no;
          CRYPTO_ARC4 = lib.mkForce no;
          CRYPTO_BLOWFISH = lib.mkForce no;
          CRYPTO_CAMELLIA = lib.mkForce no;

          ## Additional Optimizations
          AIO = yes;
          EPOLL = yes;
          INOTIFY_USER = yes;
          SIGNALFD = yes;
          TIMERFD = yes;
          DNOTIFY = lib.mkForce no;
          FANOTIFY = lib.mkForce no;
          COREDUMP = lib.mkForce no;
          ADVISE_SYSCALLS = lib.mkForce no;

          ## Explicitly Disable Options from common-config.nix
          RANDOM_KMALLOC_CACHES = lib.mkForce no;
          RCU_LAZY = lib.mkForce no;
          RT2800USB_RT53XX = lib.mkForce no;
          RT2800USB_RT55XX = lib.mkForce no;
          RTW88 = lib.mkForce no;
          RTW88_8822BE = lib.mkForce no;
          RTW88_8822CE = lib.mkForce no;
          SLAB_FREELIST_HARDENED = lib.mkForce no;
          SLAB_FREELIST_RANDOM = lib.mkForce no;

          ## Disable Unnecessary Drivers
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
          DRM_XE = lib.mkForce no;
          INFINIBAND = lib.mkForce no;
          IWLWIFI = lib.mkForce no;
          NVME_HWMON = lib.mkForce no;
          THERMAL_HWMON = lib.mkForce no;
          THERMAL_NETLINK = lib.mkForce no;
          MLX5_CORE_EN = lib.mkForce no;

          ## Disable Unnecessary Networking Protocols
          FDDI = lib.mkForce no;
          HIPPI = lib.mkForce no;
          L2TP = lib.mkForce no;
          PLIP = lib.mkForce no;
          PPP = lib.mkForce module;
          PPPOE = lib.mkForce no;
          PPTP = lib.mkForce no;
          SLIP = lib.mkForce no;
          WLAN = lib.mkForce no;
          WWAN = lib.mkForce no;

          ## Disable Unnecessary Input Device Classes
          INPUT_MOUSE = lib.mkForce no;
          INPUT_JOYSTICK = lib.mkForce no;
          INPUT_TOUCHSCREEN = lib.mkForce no;
          INPUT_TABLET = lib.mkForce no;
          INPUT_MISC = lib.mkForce no;
          INPUT_KEYBOARD = lib.mkForce no;
          INPUT_LED = lib.mkForce no;
          INPUT_FF_MEMLESS = lib.mkForce module;

          ## Disable MEDIA Subsystem
          MEDIA_SUPPORT = lib.mkForce no;
          MEDIA_CAMERA_SUPPORT = lib.mkForce no;
          MEDIA_ANALOG_TV_SUPPORT = lib.mkForce no;
          MEDIA_DIGITAL_TV_SUPPORT = lib.mkForce no;
          MEDIA_RADIO_SUPPORT = lib.mkForce no;
          MEDIA_SDR_SUPPORT = lib.mkForce no;
          MEDIA_RC_SUPPORT = lib.mkForce no;
          MEDIA_PCI_SUPPORT = lib.mkForce no;
          MEDIA_USB_SUPPORT = lib.mkForce no;

          ## Disable unnecessary Ethernet drivers
          NET_VENDOR_3COM = lib.mkForce no;
          NET_VENDOR_8390 = lib.mkForce no;
          NET_VENDOR_ACTIONS = lib.mkForce no;
          NET_VENDOR_ADAPTEC = lib.mkForce no;
          NET_VENDOR_ADI = lib.mkForce no;
          NET_VENDOR_AGERE = lib.mkForce no;
          NET_VENDOR_ALACRITECH = lib.mkForce no;
          NET_VENDOR_ALLWINNER = lib.mkForce no;
          NET_VENDOR_ALTEON = lib.mkForce no;
          NET_VENDOR_AMAZON = lib.mkForce no;
          NET_VENDOR_AMD = lib.mkForce no;
          NET_VENDOR_APPLE = lib.mkForce no;
          NET_VENDOR_AQUANTIA = lib.mkForce no;
          NET_VENDOR_ARC = lib.mkForce no;
          NET_VENDOR_ASIX = lib.mkForce no;
          NET_VENDOR_ATHEROS = lib.mkForce no;
          NET_VENDOR_BROADCOM = lib.mkForce no;
          NET_VENDOR_BROCADE = lib.mkForce no;
          NET_VENDOR_CADENCE = lib.mkForce no;
          NET_VENDOR_CAVIUM = lib.mkForce no;
          NET_VENDOR_CHELSIO = lib.mkForce no;
          NET_VENDOR_CIRRUS = lib.mkForce no;
          NET_VENDOR_CISCO = lib.mkForce no;
          NET_VENDOR_CORTINA = lib.mkForce no;
          NET_VENDOR_DEC = lib.mkForce no;
          NET_VENDOR_DLINK = lib.mkForce no;
          NET_VENDOR_EMULEX = lib.mkForce no;
          NET_VENDOR_ENGLEDER = lib.mkForce no;
          NET_VENDOR_EZCHIP = lib.mkForce no;
          NET_VENDOR_FARADAY = lib.mkForce no;
          NET_VENDOR_FREESCALE = lib.mkForce no;
          NET_VENDOR_FUJITSU = lib.mkForce no;
          NET_VENDOR_FUNGIBLE = lib.mkForce no;
          NET_VENDOR_GOOGLE = lib.mkForce no;
          NET_VENDOR_HISILICON = lib.mkForce no;
          NET_VENDOR_HUAWEI = lib.mkForce no;
          NET_VENDOR_I825XX = lib.mkForce no;
          NET_VENDOR_IBM = lib.mkForce no;
          NET_VENDOR_LITEX = lib.mkForce no;
          NET_VENDOR_MARVELL = lib.mkForce no;
          NET_VENDOR_MEDIATEK = lib.mkForce no;
          NET_VENDOR_MELLANOX = lib.mkForce no;
          NET_VENDOR_META = lib.mkForce no;
          NET_VENDOR_MICREL = lib.mkForce no;
          NET_VENDOR_MICROCHIP = lib.mkForce no;
          NET_VENDOR_MICROSEMI = lib.mkForce no;
          NET_VENDOR_MICROSOFT = lib.mkForce no;
          NET_VENDOR_MOXART = lib.mkForce no;
          NET_VENDOR_MYRI = lib.mkForce no;
          NET_VENDOR_NATSEMI = lib.mkForce no;
          NET_VENDOR_NETERION = lib.mkForce no;
          NET_VENDOR_NETRONOME = lib.mkForce no;
          NET_VENDOR_NI = lib.mkForce no;
          NET_VENDOR_NVIDIA = lib.mkForce no;
          NET_VENDOR_OKI = lib.mkForce no;
          NET_VENDOR_PACKET_ENGINES = lib.mkForce no;
          NET_VENDOR_PASEMI = lib.mkForce no;
          NET_VENDOR_PENSANDO = lib.mkForce no;
          NET_VENDOR_QLOGIC = lib.mkForce no;
          NET_VENDOR_QUALCOMM = lib.mkForce no;
          NET_VENDOR_RDC = lib.mkForce no;
          NET_VENDOR_REALTEK = lib.mkForce no;
          NET_VENDOR_RENESAS = lib.mkForce no;
          NET_VENDOR_ROCKER = lib.mkForce no;
          NET_VENDOR_SAMSUNG = lib.mkForce no;
          NET_VENDOR_SEEQ = lib.mkForce no;
          NET_VENDOR_SGI = lib.mkForce no;
          NET_VENDOR_SILAN = lib.mkForce no;
          NET_VENDOR_SIS = lib.mkForce no;
          NET_VENDOR_SMSC = lib.mkForce no;
          NET_VENDOR_SOCIONEXT = lib.mkForce no;
          NET_VENDOR_SOLARFLARE = lib.mkForce no;
          NET_VENDOR_STMICRO = lib.mkForce no;
          NET_VENDOR_SUN = lib.mkForce no;
          NET_VENDOR_SUNPLUS = lib.mkForce no;
          NET_VENDOR_SYNOPSYS = lib.mkForce no;
          NET_VENDOR_TEHUTI = lib.mkForce no;
          NET_VENDOR_TI = lib.mkForce no;
          NET_VENDOR_TOSHIBA = lib.mkForce no;
          NET_VENDOR_TUNDRA = lib.mkForce no;
          NET_VENDOR_VERTEXCOM = lib.mkForce no;
          NET_VENDOR_VIA = lib.mkForce no;
          NET_VENDOR_WANGXUN = lib.mkForce no;
          NET_VENDOR_WIZNET = lib.mkForce no;
          NET_VENDOR_XILINX = lib.mkForce no;
          NET_VENDOR_XIRCOM = lib.mkForce no;
          NET_VENDOR_XSCALE = lib.mkForce no;

          ## Disable PMBus drivers
          PMBUS = lib.mkForce no;
          SENSORS_PMBUS = lib.mkForce no;
          SENSORS_ADM1275 = lib.mkForce no;
          SENSORS_IBM_CFFPS = lib.mkForce no;
          SENSORS_IR35221 = lib.mkForce no;
          SENSORS_IR38064 = lib.mkForce no;
          SENSORS_ISL68137 = lib.mkForce no;
          SENSORS_LM25066 = lib.mkForce no;
          SENSORS_LTC2978 = lib.mkForce no;
          SENSORS_LTC3815 = lib.mkForce no;
          SENSORS_MAX16064 = lib.mkForce no;
          SENSORS_MAX20751 = lib.mkForce no;
          SENSORS_MAX31785 = lib.mkForce no;
          SENSORS_MAX34440 = lib.mkForce no;
          SENSORS_MAX8688 = lib.mkForce no;
          SENSORS_PMC = lib.mkForce no;
          SENSORS_TPS40422 = lib.mkForce no;
          SENSORS_TPS53679 = lib.mkForce no;
          SENSORS_UCD9000 = lib.mkForce no;
          SENSORS_UCD9200 = lib.mkForce no;
          SENSORS_XDPE122 = lib.mkForce no;
        };
        ignoreConfigErrors = true;
      };
    }
  );
}
