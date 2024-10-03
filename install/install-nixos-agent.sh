#!/bin/bash

set -e

# Function to prompt for GitHub access token
get_github_token() {
    read -sp "Enter your GitHub access token: " GITHUB_TOKEN
    echo
}

# Function to download files from GitHub
download_from_github() {
    local repo=$1
    local file=$2
    local destination=$3
    curl -H "Authorization: token $GITHUB_TOKEN" -L "https://api.github.com/repos/$repo/contents/$file" | jq -r .content | base64 --decode > "$destination"
}

# Check if correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <drive1> <drive2>"
    exit 1
fi

DRIVE1=$1
DRIVE2=$2

# Prompt for GitHub access token
get_github_token

# Create BTRFS filesystem with RAID1 for both metadata and data
mkfs.btrfs -L nixos-root -m raid1 -d raid1 "$DRIVE1" "$DRIVE2"

# Mount the BTRFS filesystem
mount "$DRIVE1" /mnt  # We can mount either drive, BTRFS will handle the RAID1

# Create BTRFS subvolumes
btrfs subvolume create /mnt/@

# Unmount and remount with subvolumes
umount /mnt
mount -o subvol=@ "$DRIVE1" /mnt

# Generate NixOS configuration
nixos-generate-config --root /mnt

# Download flake.agent.nix from GitHub and rename it
download_from_github "Avunu/nixos-k3s" "install/flake.agent.nix" "/mnt/etc/nixos/flake.nix"

# Download and place required files
mkdir -p /mnt/etc/k3s
download_from_github "Avunu/nixos-k3s-configs" "environment" "/mnt/etc/environment"
download_from_github "Avunu/nixos-k3s-configs" "tokenFile" "/mnt/etc/k3s/tokenFile"
download_from_github "Avunu/nixos-k3s-configs" "envs" "/mnt/etc/k3s/envs"

# fix permissions
chmod 600 /mnt/etc/k3s/tokenFile

# Install NixOS
nixos-install --flake /mnt/etc/nixos#

echo "NixOS agent installation complete. You can now reboot into your new system."