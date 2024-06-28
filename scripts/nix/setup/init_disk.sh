#! /usr/bin/env bash

set -euo pipefail

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

show_usage() {
	echo "Usage: $0 <DISK_PATH> [options]"
	echo "Options:"
	echo "  --wipe"
	echo "  --encrypt"
	echo "  --encryption-key=<key>"
	echo "  --root=<size>,<filesystem>"
	echo "  --swap=<size>"
	echo "  --home=<size>,<filesystem>"
	echo "  --opt=<size>,<filesystem>"
	echo "  --var=<size>,<filesystem>"
	echo "  --nix=<size>,<filesystem>"
	echo "  --lv=<name>,<size>,<filesystem>,<mount_point>"
	echo "  --mount=<root_mount_point>"
	echo "  --nvme"
	echo "Example:"
	echo "  $0 /dev/vda --encrypt --nvme --root=1G,ext4 --home=100G,xfs --swap=8G --opt=20G,ext4 --var=10G,ext4 --nix=100G,xfs --lv=vm_repo,10G,xfs,vms --mount=/mnt/rootvol"
}

# Default values
DISK_PATH=""
ROOT_MOUNT_DIR=""
WIPE=false
ENCRYPT=false
ENCRYPTION_KEY=""
NVME_FLAG=false  # Added for NVMe flag
LVOL_FLAGS=()

# Parse arguments
for arg in "$@"; do
	case $arg in
	--wipe)
		WIPE=true
		shift
		;;
	--encrypt)
		ENCRYPT=true
		shift
		;;
	--nvme)
		NVME_FLAG=true
		shift
		;;
	--encryption-key=*)
		ENCRYPTION_KEY="${arg#*=}"
		shift
		;;
	--root=*)
		ROOT_VOL="${arg#*=}"
		shift
		;;
	--swap=*)
		SWAP_VOL="${arg#*=}"
		shift
		;;
	--home=*)
		HOME_VOL="${arg#*=}"
		shift
		;;
	--opt=*)
		OPT_VOL="${arg#*=}"
		shift
		;;
	--var=*)
		VAR_VOL="${arg#*=}"
		shift
		;;
	--nix=*)
		NIX_VOL="${arg#*=}"
		shift
		;;
	--lv=*)
		LVOL_FLAGS+=("${arg#*=}")
		shift
		;;
	--mount=*)
		ROOT_MOUNT_DIR="${arg#*=}"
		shift
		;;
	*)
		if [[ -z "$DISK_PATH" ]]; then
			DISK_PATH="$arg"
		else
			echo "Unknown option: $arg"
			show_usage
			exit 1
		fi
		;;
	esac
done

if [[ -z "$DISK_PATH" ]]; then
	echo "Disk path required"
	show_usage
	exit 1
fi


if [[ -z "$ROOT_VOL" ]]; then
	echo "Root volume configuration required"
	show_usage
	exit 1
fi

# Wipe disk if requested
if $WIPE; then
	log "Wiping disk $DISK_PATH"
	cryptsetup open --type plain --key-file=/dev/urandom "$DISK_PATH" wipe-me
	dd if=/dev/zero of=/dev/mapper/wipe-me bs=4M status=progress
	cryptsetup close
fi

# Partition the disk
log "Partitioning disk $DISK_PATH"
parted -a opt --script "${DISK_PATH}" \
	mklabel gpt \
	mkpart primary fat32 0% 512MiB \
	mkpart primary 512MiB 100% \
	set 1 esp on \
	name 1 boot \
	set 2 lvm on \
	name 2 root

# Adjust disk path for NVMe if --nvme flag is provided
if $NVME_FLAG; then
	DISK_PATH="${DISK_PATH}p"
fi

# Encrypt disk if requested
if $ENCRYPT; then
	log "Setting up LUKS encryption"
	if [[ -n "$ENCRYPTION_KEY" ]]; then
		echo -n "$ENCRYPTION_KEY" | cryptsetup luksFormat "${DISK_PATH}2" -
		echo -n "$ENCRYPTION_KEY" | cryptsetup open "${DISK_PATH}2" cryptlvm -
	else
		cryptsetup luksFormat "${DISK_PATH}2"
		cryptsetup open "${DISK_PATH}2" cryptlvm
	fi
fi

# Setup LVM
log "Creating LVM physical volume, volume group, and logical volumes"
if $ENCRYPT; then
	pvcreate /dev/mapper/cryptlvm
	vgcreate vg0 /dev/mapper/cryptlvm
else
	pvcreate "${DISK_PATH}2"
	vgcreate vg0 "${DISK_PATH}2"
fi

# Create and mount logical volumes
create_and_mount_lv() {
	local name=$1
	local size=$2
	local fs=$3
	local mount_point=$4

	lvcreate -L "$size" -n "$name" vg0
	mkfs."$fs" /dev/vg0/"$name"
	if [[ -n "$ROOT_MOUNT_DIR" ]]; then
	  mkdir -p "${ROOT_MOUNT_DIR}/${mount_point}"
	  mount /dev/vg0/"$name" "${ROOT_MOUNT_DIR}/${mount_point}"
	fi
}

# Create root volume
IFS=',' read -r root_size root_fs <<<"$ROOT_VOL"
create_and_mount_lv "root" "$root_size" "$root_fs" ""

# Mount boot volume
if [[ -n "$ROOT_MOUNT_DIR" ]]; then
  mkdir -p "${ROOT_MOUNT_DIR}/boot"
  mount -o umask=077 "${DISK_PATH}1" "${ROOT_MOUNT_DIR}/boot"
fi

# Create other volumes if specified
if [[ -n "${SWAP_VOL:-}" ]]; then
	lvcreate -L "$SWAP_VOL" -n swap vg0
	mkswap /dev/vg0/swap
	swapon /dev/vg0/swap
fi

if [[ -n "${HOME_VOL:-}" ]]; then
	IFS=',' read -r home_size home_fs <<<"$HOME_VOL"
	create_and_mount_lv "home" "$home_size" "$home_fs" "home"
fi

if [[ -n "${OPT_VOL:-}" ]]; then
	IFS=',' read -r opt_size opt_fs <<<"$OPT_VOL"
	create_and_mount_lv "opt" "$opt_size" "$opt_fs" "opt"
fi

if [[ -n "${VAR_VOL:-}" ]]; then
	IFS=',' read -r var_size var_fs <<<"$VAR_VOL"
	create_and_mount_lv "var" "$var_size" "$var_fs" "var"
fi

if [[ -n "${NIX_VOL:-}" ]]; then
	IFS=',' read -r nix_size nix_fs <<<"$NIX_VOL"
	create_and_mount_lv "nix" "$nix_size" "$nix_fs" "nix"
fi

# Process additional logical volume flags
for lv_flag in "${LVOL_FLAGS[@]}"; do
	echo "LV_FLAG: $lv_flag"
	echo "ROOT: $ROOT_MOUNT_DIR"
#	IFS=',' read -r lv_name lv_size lv_fs lv_mount_point <<<"$lv_flag"
#	create_and_mount_lv "$lv_name" "$lv_size" "$lv_fs" "$lv_mount_point"
done

log "Disk initialization complete"
