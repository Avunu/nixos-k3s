{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.linuxPackages_latest.kernel.src
  ];

  shellHook = ''
    echo "Entering shell with Linux kernel source"
    echo "The kernel source is available at $PWD/linux-source"
    ln -sfn ${pkgs.linuxPackages_latest.kernel.src} linux-source
  '';
}