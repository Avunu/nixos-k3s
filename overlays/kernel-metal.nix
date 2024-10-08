# overlays/kernel-virtio.nix
self: super:

let
  pkgs = self;
  inherit (pkgs) lib;
in
{
  linuxPackages_metal = super.linuxPackages_latest.extend (
    self: super: {
      kernel = super.kernel.override {
        stdenv = pkgs.stdenvLLVM;
        buildPackages = pkgs.buildPackages // {
          stdenv = pkgs.stdenvLLVM;
        };
        extraMakeFlags = [
          # Use Clang and optimize for x86_64_v3 CPUs with LTO and O3
          "KCFLAGS+=-march=rocketlake"
          "KCFLAGS+=-mavx512bw"
          "KCFLAGS+=-mavx512cd"
          "KCFLAGS+=-mavx512dq"
          "KCFLAGS+=-mavx512f"
          "KCFLAGS+=-mavx512vl"
          "KCFLAGS+=-mtune=rocketlake"
          "KCFLAGS+=-O3"
          "KCPPFLAGS+=-march=rocketlake"
          "KCPPFLAGS+=-mavx512bw"
          "KCPPFLAGS+=-mavx512cd"
          "KCPPFLAGS+=-mavx512dq"
          "KCPPFLAGS+=-mavx512f"
          "KCPPFLAGS+=-mavx512vl"
          "KCPPFLAGS+=-mtune=rocketlake"
          "KCPPFLAGS+=-O3"
          "LLVM_IAS=1"
          "LLVM=1"
          "V=1" # Enable verbose output
          "KBUILD_VERBOSE=1" # Another way to enable verbose output
        ];
        structuredExtraConfig = with lib.kernel; {
          ## Clang/LLVM Build Options
          AS_AVX512 = yes;
          CC_IS_CLANG = yes;
          # CC_OPTIMIZE_FOR_PERFORMANCE = yes; # defaults to O2
          CC_OPTIMIZE_FOR_SIZE = lib.mkForce no;
          INIT_ON_ALLOC_DEFAULT_ON = yes;
          INIT_STACK_ALL_ZERO = yes;
          LLVM_IAS = yes;
          LTO_CLANG_THIN = yes;
          MODULE_COMPRESS_ZSTD = yes;

          # Enable Intel Rocket Lake Features
          X86_SGX = lib.mkForce yes;
          NUMA = yes;
          NODES_SPAN_OTHER_NODES = yes;
          NUMA_BALANCING = yes;
          NUMA_BALANCING_DEFAULT_ENABLED = yes;

          # Specific configs for agent nodes
          HZ = freeform "1000";
          HZ_1000 = yes;
          PREEMPT_NONE = yes;

          # disable things we don't need on modern systems
          AGP = lib.mkForce no;
          PCMCIA = lib.mkForce no;

          # Disable Debugging (you might want to disable these in production)
          DEBUG_KERNEL = lib.mkForce no;
          DYNAMIC_DEBUG = lib.mkForce no;
        };
        ignoreConfigErrors = true;
      };
    }
  );
}
