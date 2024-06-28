#! /usr/bin/env bash
MOUNT_VOL="/mnt/"
./init_disk.sh $1 --encrypt --nvme --root=1G,ext4 --home=100G,xfs --swap=32G --opt=20G,ext4 --var=10G,ext4 --nix=100G,xfs --lv=vm_repo,10G,xfs,vms --mount=$MOUNT_VOL
`which nixos-generate-config` --root "$MOUNT_VOL"

cp ./configuration.nix "$MOUNT_VOL/etc/nixos/"


PATH="$PATH" NIX_PATH="$NIX_PATH" `which nixos-install` --root $MOUNT_VOL

nixos-enter --root $MOUNT_VOL -c 'passwd jose'



