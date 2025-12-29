#!/bin/bash

# RAID Architect - Automated Storage Redundancy
# Developed by: Mahmoud Amer
# Targeted for: 3 Disks RAID 5 Setup

# 1. Check for Root (As per your notes)
if [ "$EUID" -ne 0 ]; then
    echo "Error: This fortress requires Root power!"
    exit 1
fi

echo "---   Starting RAID 5 Construction ---"

# 2. Install mdadm if not present (The RAID engine)
echo "[1/4] Checking RAID engine (mdadm)..."
apt-get update -y && apt-get install mdadm -y > /dev/null

# 3. Create RAID 5 (Using sdb, sdc, sdd all =5g)
echo "[2/4] Creating RAID 5 Device ..."
# mdadm --create [Name] --level=[RAID_Level] --raid-devices=[Count] [Disks]
mdadm --create --verbose /dev/md0 --level=5 --raid-devices=3 /dev/sdb /dev/sdc /dev/sdd

# 4. Create File System (Formatting the RAID)
echo "[3/4] Formatting RAID Array to EXT4..."
mkfs.ext4 /dev/md0

# 5. Mounting and Persistence
echo "[4/4] Mounting RAID to /mnt/raid5..."
mkdir -p /mnt/raid5
mount /dev/md0 /mnt/raid5

# Save RAID config so it works after reboot (Pro Step)
mdadm --detail --scan >> /etc/mdadm/mdadm.conf
update-initramfs -u[O

echo "--- ✅ RAID 5 is Online and Protected! ---"
echo "Total Storage: $(df -h /mnt/raid5 | awk 'NR==2 {print $2}')"

