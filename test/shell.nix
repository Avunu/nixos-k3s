{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    qemu
    OVMF
    libguestfs-with-appliance
    virt-manager
    guestfs-tools
  ];

  shellHook = ''
    echo "NixOS QCOW2 Image Testing Environment"
    echo "Available tools:"
    echo "  - qemu: for running the VM"
    echo "  - OVMF: for UEFI support"
    echo "  - libguestfs: for manipulating disk images"
    echo "  - virt-manager: for GUI-based VM management"
    echo "  - guestfish: for exploring and modifying disk images"
    echo ""
    echo "To test your image, you can use:"
    echo "  qemu-system-x86_64 -m 2G -enable-kvm -bios ${pkgs.OVMF.fd}/FV/OVMF.fd -drive file=path/to/your/image.qcow2,if=virtio -net nic,model=virtio -net user,hostfwd=tcp::2222-:22 -nographic"
    echo ""
    echo "To explore the contents of your image:"
    echo "  guestfish -a path/to/your/image.qcow2 -m /dev/sda1"
    echo ""
  '';

  # Environment variables
  LIBVIRT_DEFAULT_URI = "qemu:///system";
}