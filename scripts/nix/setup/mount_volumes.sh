 #cryptsetup luksOpen /dev/nvme0n1p2 crypt
 mount /dev/mapper/vg0-root /mnt/
 mkdir -p /mnt/{var,nix,home,boot,opt,vms}
 mount -o umask=077 /dev/nvme0n1p1 /mnt/boot
 mount /dev/mapper/vg0-opt /mnt/opt
 mount /dev/mapper/vg0-var /mnt/var
 mount /dev/mapper/vg0-home /mnt/home
 mount /dev/mapper/vg0-nix /mnt/nix
 mount /dev/mapper/vg0-vms /mnt/vms
