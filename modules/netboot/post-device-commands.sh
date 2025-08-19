#!/bin/sh

# Scan for BTRFS filesystems with label 'rootfs' (disko default)
root_dev=$(blkid -L rootfs)

if [ -z "$root_dev" ]; then
  echo "Error: Could not find root filesystem with label 'rootfs'"
  exit 1
fi

# Mount the BTRFS root subvolume
mount -t btrfs -o subvol=/root $root_dev /mnt

# If mounting fails, try to find the correct subvolume
if [ $? -ne 0 ]; then
  # Mount BTRFS root without subvolume
  mount -t btrfs $root_dev /mnt
  
  # Find subvolume named 'root' or '@'
  root_subvol=$(btrfs subvolume list /mnt | awk '/root|@/{print $NF; exit}')
  
  if [ -n "$root_subvol" ]; then
    # Unmount and remount with correct subvolume
    umount /mnt
    mount -t btrfs -o subvol=$root_subvol $root_dev /mnt
  else
    echo "Error: Could not find appropriate root subvolume"
    exit 1
  fi
fi