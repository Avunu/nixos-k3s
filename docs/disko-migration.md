# Disko Migration Summary

This document summarizes the migration from traditional NixOS filesystem configuration to Disko declarative disk management for the nixos-k3s project.

## Overview

The repository has been successfully migrated to use [Disko](https://github.com/nix-community/disko) for disk management across all systems (master, agent, and test configurations).

## Changes Made

### 1. Flake Configuration
- **File**: `flake.nix`
- **Changes**: Added `disko.nixosModules.disko` to all nixosConfigurations
- **Benefit**: Enables Disko functionality across all systems

### 2. Disko Configurations
- **New Files**:
  - `modules/disko-common.nix` - Common BTRFS configuration function
  - `modules/disko-master.nix` - Master system config (/dev/vda)  
  - `modules/disko-agent.nix` - Agent system config (/dev/sda)
  - `modules/disko-test.nix` - Test system config (/dev/vda)

### 3. Filesystem Layout
**New BTRFS Subvolume Structure:**
- `/` - Root filesystem (subvolume: `/root`)
- `/home` - User directories (subvolume: `/home`)  
- `/nix` - Nix store (subvolume: `/nix`)
- `/var/log` - System logs (subvolume: `/var/log`)
- `/var/lib` - Application data including k3s (subvolume: `/var/lib`)

**Partition Layout:**
- EFI System Partition: 1024M (vfat, mounted at `/boot`)
- Swap: 4G (with resume support)
- Root: Remaining space (BTRFS with compression and subvolumes)

### 4. System Updates
- **master.nix**: Removed old ext4 fileSystems declarations, added disko import
- **agent.nix**: Removed old BTRFS fileSystems declarations, added disko import  
- **test.nix**: Removed old ext4 fileSystems declarations, added disko import
- **netboot/client.nix**: Removed conflicting fileSystems declaration

### 5. Maintenance & Optimization
- **common.nix**: Added BTRFS auto-scrub for all systems (daily integrity checks)
- **images.nix**: Updated to use BTRFS with "rootfs" label for consistency
- **post-device-commands.sh**: Updated to look for "rootfs" label instead of "nixos-root"

## Benefits

1. **Consistency**: All systems now use the same BTRFS filesystem with identical subvolume structure
2. **Declarative**: Disk configuration is now fully declarative and reproducible
3. **k3s Optimized**: Subvolume layout optimized for k3s storage patterns
4. **Data Integrity**: Daily BTRFS scrubbing for early error detection
5. **Snapshots**: BTRFS subvolumes enable future snapshot capabilities
6. **Compression**: ZSTD compression reduces disk usage
7. **Performance**: noatime mount option improves performance

## Compatibility

- **CRI-O**: Already configured for BTRFS storage driver
- **Longhorn**: Will work with BTRFS backend  
- **Netboot**: Updated to work with new filesystem labels
- **Image Building**: Compatible with existing image generation

## Device Mappings

- **Master System**: `/dev/vda` (virtual/cloud environments)
- **Agent Systems**: `/dev/sda` (bare metal)  
- **Test Systems**: `/dev/vda` (virtual/testing)

## Migration Status

✅ **Complete** - All filesystem configurations migrated to Disko
✅ **Tested** - Configuration syntax validated
✅ **Optimized** - BTRFS maintenance and compression enabled
✅ **Documented** - Changes documented and explained

The migration maintains backward compatibility while providing a more robust, declarative disk management solution suitable for production k3s deployments.