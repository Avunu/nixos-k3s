# overlays/ccache.nix
self: super:

let
  pkgs = self;
  inherit (pkgs) lib;

  llvmPackages = pkgs.llvmPackages_latest;
  noBintools = {
    bootBintools = null;
    bootBintoolsNoLibc = null;
  };
  mkLLVMPlatform = platform: platform // { useLLVM = true; };

  hostLLVM = pkgs.pkgsBuildHost.llvmPackages_latest.override noBintools;

  stdenvClangUseLLVM = pkgs.overrideCC hostLLVM.stdenv hostLLVM.clangUseLLVM;

  stdenvPlatformLLVM = stdenvClangUseLLVM.override (old: {
    hostPlatform = mkLLVMPlatform old.hostPlatform;
    buildPlatform = mkLLVMPlatform old.buildPlatform;
  });

  stdenvCcacheLLVM = pkgs.overrideCC stdenvPlatformLLVM (
    pkgs.ccacheWrapper.override {
      extraConfig = ''
        export CCACHE_COMPRESS=1
        export CCACHE_DIR=/var/cache/ccache
        export CCACHE_UMASK=007
      '';
      cc = stdenvPlatformLLVM.cc;
    }
  );
in
{
  stdenvLLVM = pkgs.addAttrsToDerivation {
    env.NIX_CC_USE_RESPONSE_FILE = "0";
    hardeningDisable = [ "fortify" ];
  } stdenvCcacheLLVM;
}
