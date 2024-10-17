# overlays/kernel-virtio.nix
self: super:

let
  pkgs = self;
  inherit (pkgs) lib;
in
{
  linuxPackages_virtio = super.linuxPackages_testing.extend (
    self: super: {
      kernel = super.kernel.override {
        stdenv = pkgs.stdenvLLVM;
        buildPackages = pkgs.buildPackages // {
          stdenv = pkgs.stdenvLLVM;
        };
        extraMakeFlags = [
          # Use Clang and optimize for x86_64_v3 CPUs with LTO and O3
          "KCFLAGS+=-march=haswell"
          "KCFLAGS+=-mtune=haswell"
          "KCFLAGS+=-O3"
          "KCPPFLAGS+=-march=haswell"
          "KCPPFLAGS+=-mtune=haswell"
          "KCPPFLAGS+=-O3"
          "KRUSTFLAGS+=-Copt-level=2"
          "LDFLAGS+=-O3"
          "LLVM_IAS=1"
          "LLVM=1"
          "V=1" # Enable verbose output
          "KBUILD_VERBOSE=1" # Another way to enable verbose output
          "C=1" # Enable sparse warnings
        ];
        # enable rust inputs
        extraBuildInputs = with pkgs; [
          sparse
          rustc
          rust-bindgen
          rustfmt
        ];
        structuredExtraConfig = with lib.kernel; {
          ## Clang/LLVM Build Options
          CC_IS_CLANG = yes;
          # CC_OPTIMIZE_FOR_PERFORMANCE = yes; # defaults to O2
          CC_OPTIMIZE_FOR_SIZE = lib.mkForce no;
          # INIT_ON_ALLOC_DEFAULT_ON = yes;
          # INIT_STACK_ALL_ZERO = yes;
          LLVM_IAS = yes;
          LTO_CLANG_THIN = yes;
          # MODULE_COMPRESS_ZSTD = yes;
          DEBUG_INFO_BTF = lib.mkForce no;

          # enable rust
          RUST = yes;

          # ## Base Configuration
          # EXPERT = yes;
          # MODULES = yes;
          # SMP = yes;

          # ## Virtualization Support
          # HYPERVISOR_GUEST = yes;
          # PARAVIRT = yes;
          # KVM_GUEST = yes;

          # ## Virtio Support
          # DRM = yes;
          # DRM_FBDEV_EMULATION = yes;
          # DRM_VIRTIO_GPU = yes;
          # VIRTIO = yes;
          # VIRTIO_BALLOON = yes;
          # VIRTIO_BLK = yes;
          # VIRTIO_CONSOLE = yes;
          # VIRTIO_INPUT = yes;
          # VIRTIO_MENU = yes;
          # VIRTIO_MMIO = yes;
          # VIRTIO_NET = yes;
          # VIRTIO_PCI = yes;
          # "9P_FS_POSIX_ACL" = yes;
          # "9P_FS" = module;
          # "9P_FSCACHE" = yes;
          # "9P_NET" = yes;
          # SCSI_VIRTIO = module;
        };
        ignoreConfigErrors = true;
      };
    }
  );
}
