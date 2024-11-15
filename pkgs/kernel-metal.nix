{ lib, ccacheClangStdenv, linux_latest, ... }:

linux_latest.override {
  stdenv = ccacheClangStdenv;

  extraMakeFlags = [
    "LLVM=1"
    "KCFLAGS+=-O3"
    "KCFLAGS+=-march=rocketlake"
  ];

  structuredExtraConfig = with lib.kernel; {
    LTO_CLANG_FULL = yes;
  };

  ignoreConfigErrors = true;
}
