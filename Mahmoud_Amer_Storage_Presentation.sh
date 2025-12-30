#!/bin/bash

# =================================================================
# PROJECT: LINUX STORAGE DYNAMIC PRESENTATION (PRO VERSION)
# AUTHOR:  MAHMOUD AMER
# DESCRIPTION: EDUCATIONAL SCRIPT WITH AUTO-CALCULATED DELAYS
# =================================================================

# Smart Function to calculate lines and use as sleep time
smart_delay() {
    local content="$1"
    echo -e "$content"
    # Count lines in the current section
    local lines=$(echo -e "$content" | wc -l)
    # Set dynamic sleep based on lines (minimum 2 seconds)
    if [ $lines -lt 2 ]; then lines=2; fi
    sleep $lines
}

# 1. Introduction: Boot Systems & Filesystems
intro_section() {
    clear
    text="--- SECTION 1: BOOT ARCHITECTURE & FILESYSTEMS ---

- BIOS/MBR: Legacy system, 512-byte sectors, max 4 partitions.
   

- UEFI/GPT: Modern replacement, supports up to 128 partitions.


- Filesystems:
 
  * Ext4: Reliable and balanced for small/large files.
  

  * XFS: High performance, ideal for large data volumes.


  * Btrfs: Advanced features like snapshots and RAID support."
    
    smart_delay "$text"
    
    echo -e "\n[SYSTEM SCAN]: Listing block devices..."
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT
    sleep 2
}


# 2. Swap Management: Theory & Implementation
swap_section() {
    text="--- SECTION 2: SWAP SPACE MANAGEMENT ---
Definition: Virtual RAM created on physical storage.
Mahmoud Amer's 4-Step Process:

1. Create file: fallocate -l [SIZE] /swapfile

2. Secure: chmod 600 /swapfile

3. Format: mkswap /swapfile

4. Activate: swapon /swapfile"
    
    smart_delay "$text"
    
    read -p "Execute Swap Setup? (y/n): " RUN_SWAP
    if [[ $RUN_SWAP == "y" ]]; then
        read -p "Enter Size (e.g., 2G): " S_SIZE
        sudo fallocate -l $S_SIZE /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo "/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab
        echo "Swap is successfully activated."
        sleep 2
    fi
}

# 3. RAID Management: Redundancy Concepts
raid_section() {
    text="--- SECTION 3: RAID (REDUNDANT ARRAY OF INDEPENDENT DISKS) ---
RAID Levels Overview:

- RAID 0: Striping (Maximum Performance).

- RAID 1: Mirroring (Maximum Security/Redundancy).

- RAID 5: Distributed Parity (3+ disks required).

- RAID 10: 1+0 Combination (Speed + Safety)."
    
    smart_delay "$text"
    
    read -p "Configure RAID Array? (y/n): " RUN_RAID
    if [[ $RUN_RAID == "y" ]]; then
        lsblk -d -n -o NAME,SIZE
        read -p "Level (0/1/5): " LVL
        read -p "Devices Count: " D_COUNT
        read -p "Device Paths: " D_PATHS
        sudo mdadm --create /dev/md0 --level=$LVL --raid-devices=$D_COUNT $D_PATHS
        sudo mkfs.ext4 /dev/md0
        echo "RAID Device /dev/md0 is ready."
        sleep 2
    fi
}

# 4. LVM Management: Layered Storage
lvm_section() {
    text="--- SECTION 4: LVM (LOGICAL VOLUME MANAGER) ---

LVM Stack Architecture:

1. Physical Volumes (PV): Raw disk initialization.

2. Volume Groups (VG)   : Combining PVs into a pool.

3. Logical Volumes (LV) : Flexible partitions for mounting."
    
    smart_delay "$text"
    
    read -p "Setup LVM Structure? (y/n): " RUN_LVM
    if [[ $RUN_LVM == "y" ]]; then
        read -p "PV Disks (e.g., /dev/sdb): " PV_DISK
        sudo pvcreate $PV_DISK
        read -p "VG Name: " VG_NAME
        sudo vgcreate $VG_NAME $PV_DISK
        read -p "LV Name: " LV_NAME
        read -p "LV Size: " LV_SIZE
        sudo lvcreate -L $LV_SIZE -n $LV_NAME $VG_NAME
        sudo mkfs.xfs /dev/$VG_NAME/$LV_NAME
        echo "LVM Structure created and formatted with XFS."
        sleep 2
    fi
}

# Execution Flow
intro_section
swap_section
raid_section
lvm_section

sleep 2

echo "================================================="
echo "  PRESENTATION COMPLETE | BY: MAHMOUD AMER       "
echo "================================================="
echo "  Many Thanks                                    "
echo "================================================="

#END

