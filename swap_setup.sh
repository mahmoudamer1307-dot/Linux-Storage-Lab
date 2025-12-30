#!/bin/bash


# 1. We need to Create a 1GB swap file so will 
echo "Step 1: Creating 1GB swap file..."
sudo fallocate -l 1G /swapfile

# 2. Set the correct permissions
echo "Step 2: Setting secure permissions (600)..."
sudo chmod 600 /swapfile

# 3. Set up the swap area
echo "Step 3: Formatting the file as swap..."
sudo mkswap /swapfile

# 4. Enable the swap file
echo "Step 4: Activating the swap file..."
sudo swapon /swapfile

# 5. Backup fstab and add the swap entry for persistence
echo "Step 5: Making swap permanent in /etc/fstab..."
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# 6. Verify the status
echo "Final Step: Displaying memory and swap status..."
free -h

#END


