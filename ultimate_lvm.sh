#!/bin/bash

# --- LVM AUTOMATION TOOL (Industrial Grade) ---

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "CRITICAL ERROR: This script must be run as root (sudo)."
   exit 1
fi

echo "--- STEP 1: SCANNING STORAGE ---"
lsblk -d -o NAME,SIZE,MODEL | grep -v "loop"

# Get inputs from the user
read -p "Enter the device name (e.g., sdb): " DISK
read -p "Enter Volume Group name (VG): " VG_NAME
read -p "Enter Logical Volume name (LV): " LV_NAME
read -p "Enter size (e.g., 2G): " LV_SIZE

echo "--- STEP 2: PREPARING DISK ---"
# Wipe any existing signatures to prevent failure
wipefs -a /dev/$DISK

# Create Physical Volume
pvcreate /dev/$DISK || { echo "Failed to create PV"; exit 1; }

# Create Volume Group
vgcreate $VG_NAME /dev/$DISK || { echo "Failed to create VG"; exit 1; }

# Create Logical Volume
lvcreate -L $LV_SIZE -n $LV_NAME $VG_NAME || { echo "Failed to create LV"; exit 1; }

echo "--- STEP 3: FILESYSTEM & MOUNTING ---"
# Format with EXT4
mkfs.ext4 /dev/$VG_NAME/$LV_NAME

# Create mount point
MOUNT_DIR="/mnt/$LV_NAME"
mkdir -p $MOUNT_DIR

# Mount the volume
mount /dev/$VG_NAME/$LV_NAME $MOUNT_DIR

# --- STEP 4: MAKING IT PERMANENT (The Pro Touch) ---
# Get UUID for the new LV
UUID=$(blkid -s UUID -o value /dev/$VG_NAME/$LV_NAME)

# Append to /etc/fstab safely
echo "UUID=$UUID  $MOUNT_DIR  ext4  defaults  0  2" >> /etc/fstab

echo "--- STEP 5: FINAL VERIFICATION ---"
pvs
vgs
lvs
echo "LVM is ready and permanent at $MOUNT_DIR"


