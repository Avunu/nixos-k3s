# Disko configuration for master system
{ lib, ... }:

let
  diskoCommon = import ./disko-common.nix { inherit lib; };
in
diskoCommon.mkDiskConfig "/dev/vda"