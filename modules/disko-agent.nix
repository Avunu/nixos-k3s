# Disko configuration for agent system (bare metal)
{ lib, ... }:

let
  diskoCommon = import ./disko-common.nix { inherit lib; };
in
diskoCommon.mkDiskConfig "/dev/sda"