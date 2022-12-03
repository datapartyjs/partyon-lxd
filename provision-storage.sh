#!/bin/bash

## Provisions ARM server external HDD/SDD

set -e

DRIVE="/dev/sda"
MOUNT_POINT="/storage_bulk"
SWAP_DEV="$DRIVE"1
STORAGE_DEV="$DRIVE"2

if [ ! -b "$DRIVE" ]; then
  echo "ERROR: No drive: $DRIVE"
  exit
fi

# Check if mount point taken
mount | grep $MOUNT_POINT &> /dev/null
if [ $? == 0 ]; then
  echo "ERROR: Mountpoint is in use $MOUNT_POINT"
  exit
fi

if [ -b "$SWAP_DEV" ]; then
  echo "ERROR: Swap space already created: $SWAP_DEV"
  exit
fi

if [ -b "$STORAGE_DEV" ]; then
  echo "ERROR: Storage space already created: $STORAGE_DEV"
  exit
fi

echo "Creating partition tables"

parted --script -a optimal -- $DRIVE \
  mklabel gpt \
  mkpart primary 1MiB 8GiB \
  mkpart primary 8GiB -0

sync

echo "Formating storage"

mkfs.ext4 $STORAGE_DEV

echo "Creating Mount Point"
mkdir -p $MOUNT_POINT


echo "Formating swap"

sync
mkswap $SWAP_DEV
sync

echo "Activating Swap $SWAP_DEV"
swapon $SWAP_DEV


echo "Activating Storage Bulk $STORAGE_DEV"
mount $STORAGE_DEV /storage_bulk
mkdir -p $MOUNT_POINT/postgresql
mkdir -p $MOUNT_POINT/mastodon

echo "Updating /etc/fstab"

if ! grep -q $SWAP_DEV /etc/fstab ; then
    echo "# Extra External Swap" >> /etc/fstab
    echo "$SWAP_DEV    swap    swap    defaults    0    2" >> /etc/fstab
fi

if ! grep -q $STORAGE_DEV /etc/fstab ; then
    echo "# Storage Bulk" >> /etc/fstab
    echo "$STORAGE_DEV    $MOUNT_POINT    ext4    defaults    0    2" >> /etc/fstab
fi

