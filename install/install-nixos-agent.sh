#!/bin/bash
#
# Install a bare-metal NixOS k3s agent onto two drives (btrfs RAID1).
#
# Usage:
#   K3S_CONFIGS_REPO=<owner>/<repo> install-nixos-agent.sh <drive1> <drive2>
#
# K3S_CONFIGS_REPO names the (private) GitHub repository that holds this
# cluster's secrets and settings. Its root must contain the files
# `environment`, `envs`, `pubkey` and `tokenFile` (see environment.template and
# k3s-env.template in this directory). The GitHub access token you are prompted
# for needs read access to that repository.

set -e

# Function to prompt for GitHub access token
get_github_token() {
    read -rsp "Enter your GitHub access token: " GITHUB_TOKEN
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
    echo "Usage: K3S_CONFIGS_REPO=<owner>/<repo> $0 <drive1> <drive2>"
    exit 1
fi

# The cluster configuration repository is deliberately not hard-coded: it is
# private to whoever runs the cluster. Fail before anything destructive happens.
if [[ ! "${K3S_CONFIGS_REPO:-}" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
    echo "Set K3S_CONFIGS_REPO to the <owner>/<repo> of your cluster configuration repository." >&2
    echo "Usage: K3S_CONFIGS_REPO=<owner>/<repo> $0 <drive1> <drive2>" >&2
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
download_from_github "$K3S_CONFIGS_REPO" "environment" "/mnt/etc/environment"
download_from_github "$K3S_CONFIGS_REPO" "envs" "/mnt/etc/k3s/envs"
download_from_github "$K3S_CONFIGS_REPO" "pubkey" "/mnt/etc/pubkey"
download_from_github "$K3S_CONFIGS_REPO" "tokenFile" "/mnt/etc/k3s/tokenFile"

# fix permissions
chmod 600 /mnt/etc/k3s/tokenFile

# Install NixOS
nixos-install --flake /mnt/etc/nixos#

echo "NixOS agent installation complete. You can now reboot into your new system."