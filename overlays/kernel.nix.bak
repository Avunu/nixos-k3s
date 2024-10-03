self: super:

let
  pkgs = self;
  inherit (pkgs) lib recurseIntoAttrs;

  makeKernel =
    name: extraConfig:
    pkgs.linuxPackages_latest.kernel.overrideAttrs {
      # Use CCACHE to speed up kernel builds
      stdenv = pkgs.ccacheStdenv;

      # optimizations, including LTO with Clang
      extraConfig = ''
        CC = "${pkgs.llvmPackages_19.clang}/bin/clang";
        CFLAGS = "$CFLAGS -O3 -flto ${extraConfig}";
        LDFLAGS = "$LDFLAGS -flto";
      '';
    };

in
{
  linuxKernel = super.linuxKernel // {
    kernels = super.linuxKernel.kernels // {
      linux_master = makeKernel "linux_master" "-march=x86-64-v3 -mtune=x86-64-v3";
      linux_agent = makeKernel "linux_agent" "-march=x86-64-v4 -mtune=x86-64-v4";
    };

    packages = super.linuxKernel.packages // {
      linux_master = recurseIntoAttrs (
        self.linuxKernel.packagesFor self.linuxKernel.kernels.linux_master
      );
      linux_agent = recurseIntoAttrs (self.linuxKernel.packagesFor self.linuxKernel.kernels.linux_agent);
    };
  };

  linuxPackages_master = self.linuxKernel.packages.linux_master;
  linuxPackages_agent = self.linuxKernel.packages.linux_agent;
}
