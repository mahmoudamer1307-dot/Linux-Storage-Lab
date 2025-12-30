#!/bin/bash

# --- ALL-IN-ONE STORAGE MASTER TOOL ---

# 1. Root Check
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root (sudo)."
   exit 1
fi

# Function for Swap Setup
setup_swap() {
    read -p "Enter swap size (e.g., 1G): " SWAP_SIZE
    fallocate -l $SWAP_SIZE /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo "/swapfile none swap sw 0 0" >> /etc/fstab
    echo "Swap $SWAP_SIZE created and activated successfully!"
}

# Function for RAID Setup
setup_raid() {
    echo "Scanning available disks..."
    lsblk -d -o NAME,SIZE | grep -v "loop"
    read -p "Enter first disk (e.g., sdb): " DISK1
    read -p "Enter second disk (e.g., sdc): " DISK2
    read -p "Enter RAID level (0 or 1): " RAID_LEVEL
    
    apt update && apt install mdadm -y
    mdadm --create /dev/md0 --level=$RAID_LEVEL --raid-devices=2 /dev/$DISK1 /dev/$DISK2
    mkfs.ext4 /dev/md0
    mkdir -p /mnt/raid_storage
    mount /dev/md0 /mnt/raid_storage
    echo "RAID $RAID_LEVEL created at /mnt/raid_storage"
}

# Function for LVM Setup
setup_lvm() {
    lsblk -d -o NAME,SIZE | grep -v "loop"
    read -p "Enter disk to use (e.g., sdb): " DISK
    read -p "Enter VG name: " VG_NAME
    read -p "Enter LV name: " LV_NAME
    read -p "Enter LV size (e.g., 2G): " LV_SIZE
    
    wipefs -a /dev/$DISK
    pvcreate /dev/$DISK
    vgcreate $VG_NAME /dev/$DISK
    lvcreate -L $LV_SIZE -n $LV_NAME $VG_NAME
    mkfs.ext4 /dev/$VG_NAME/$LV_NAME
    
    MOUNT_DIR="/mnt/$LV_NAME"
    mkdir -p $MOUNT_DIR
    mount /dev/$VG_NAME/$LV_NAME $MOUNT_DIR
    
    # Persistent mount using UUID
    UUID=$(blkid -s UUID -o value /dev/$VG_NAME/$LV_NAME)
    echo "UUID=$UUID  $MOUNT_DIR  ext4  defaults  0  2" >> /etc/fstab
    echo "LVM $LV_NAME created and added to fstab!"
}

# --- MAIN MENU ---
echo "==============================="
echo "  STORAGE MANAGEMENT TOOL"
echo "==============================="
echo "1) Setup Swap File"
echo "2) Setup RAID Array"
echo "3) Setup LVM (Logical Volume)"
echo "4) Exit"
read -p "Choose an option [1-4]: " CHOICE

case $CHOICE in
    1) setup_swap ;;
    2) setup_raid ;;
    3) setup_lvm ;;
    4) exit 0 ;;
    *) echo "Invalid option!" ;;
esac

#END


