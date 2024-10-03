final: prev: {
  linuxPackages_master = prev.linuxPackages_latest.override {
    kernel = prev.linuxPackages_latest.kernel.override {
      stdenv = prev.stdenv.override {
        cc = prev.llvmPackages_19.clang;
        NIX_CFLAGS_COMPILE = "-march=x86-64-v3 -mtune=x86-64-v3 -O3 -flto";
        NIX_LDFLAGS = "-flto";
      };
    };
  };

  linuxPackages_agent = prev.linuxPackages_latest.override {
    kernel = prev.linuxPackages_latest.kernel.override {
      stdenv = prev.stdenv.override {
        cc = prev.llvmPackages_19.clang;
        NIX_CFLAGS_COMPILE = "-march=x86-64-v4 -mtune=x86-64-v4 -O3 -flto";
        NIX_LDFLAGS = "-flto";
      };
    };
  };
}
