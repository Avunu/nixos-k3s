#!/bin/sh

# Scan for BTRFS filesystems with label 'nixos-root'
root_dev=$(blkid -L nixos-root)

if [ -z "$root_dev" ]; then
  echo "Error: Could not find root filesystem with label 'nixos-root'"
  exit 1
fi

# Mount the BTRFS root
mount -t btrfs -o subvol=@ $root_dev /mnt

# If mounting fails, try to find the correct subvolume
if [ $? -ne 0 ]; then
  # Mount BTRFS root without subvolume
  mount -t btrfs $root_dev /mnt
  
  # Find subvolume named '@' or 'root'
  root_subvol=$(btrfs subvolume list /mnt | awk '/@ |root/{print $NF; exit}')
  
  if [ -n "$root_subvol" ]; then
    # Unmount and remount with correct subvolume
    umount /mnt
    mount -t btrfs -o subvol=$root_subvol $root_dev /mnt
  else
    echo "Error: Could not find appropriate root subvolume"
    exit 1
  fi
fi