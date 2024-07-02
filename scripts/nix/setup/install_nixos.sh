#! /usr/bin/env bash
MOUNT_VOL="/mnt/"
# ./init_disk.sh $1 --encrypt --nvme --root=10G,ext4 --home=100G,xfs --swap=32G --opt=20G,ext4 --var=10G,ext4 --nix=100G,xfs --lv=vms,10G,xfs,vms --mount=$MOUNT_VOL

#`which nixos-generate-config` --root "$MOUNT_VOL"

#cp /mnt/etc/nixos/hardware-configuration.nix "/run/media/nixos/SHARED_STRG/dotfiles/nix/"


sudo PATH="$PATH" NIX_PATH="$NIX_PATH" `which nixos-install` --no-root-passwd --root $MOUNT_VOL --flake "/run/media/nixos/SHARED_STRG/dotfiles/nix/flake.nix#jbstl"

#nixos-enter --root $MOUNT_VOL -c 'passwd jose'



