# overlays/ccache.nix
self: super:

let
  pkgs = self;
  inherit (pkgs) lib;
in
{
  ccacheClangStdenv = pkgs.ccacheStdenv.override {
    inherit (pkgs.llvmPackages_latest) stdenv;
    cc = pkgs.llvmPackages_latest.clang;
  };
}
