{
  lib,
  ccacheClangStdenv,
  linux_latest,
  ...
}:

linux_latest.override {
  stdenv = ccacheClangStdenv;

  extraMakeFlags = [
    "LLVM=1"
    "LLVM_IAS=1"
    "KCFLAGS+=-O3"
    "KCFLAGS+=-march=haswell"
    "KCFLAGS+=-Wno-error=unused-command-line-argument"
  ];

  structuredExtraConfig = with lib.kernel; {
    CC_IS_CLANG = yes;
    LLVM_IAS = yes;
    LTO_CLANG_FULL = yes;

    # enable rust
    RUST = yes;

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
    SCSI_VIRTIO = module;
  };

  ignoreConfigErrors = true;
}
