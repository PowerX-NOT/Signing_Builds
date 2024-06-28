#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No color

# Function to check if the entered size is valid
is_valid_size() {
    [[ $1 =~ ^[0-9]+[KMG]?$ ]] && return 0 || return 1
}

# Prompt the user for the desired size of /tmp
echo -e "${YELLOW}Enter the desired size for /tmp (e.g., 16G for 16 gigabytes):${NC}"
read -p "> " TMP_SIZE

# Validate the entered size
if ! is_valid_size "$TMP_SIZE"; then
    echo -e "${RED}Invalid size format. Please enter a valid size (e.g., 16G, 2048M).${NC}"
    exit 1
fi

# Check the current usage of /tmp
CURRENT_USAGE=$(df -k /tmp | tail -1 | awk '{print $3}')
REQUIRED_SIZE=$(echo "$CURRENT_USAGE * 1.1" | bc)  # Adding 10% buffer
REQUIRED_SIZE=${REQUIRED_SIZE%.*}

# Convert user input size to kilobytes for comparison
SIZE_IN_KB=$(echo "$TMP_SIZE" | sed 's/[KMG]$/\*1024^(&)/; s/K/0/; s/M/1/; s/G/2/')
SIZE_IN_KB=$(bc <<< "$SIZE_IN_KB")

# Ensure the specified size is greater than the current usage
if (( SIZE_IN_KB < REQUIRED_SIZE )); then
    echo -e "${RED}The specified size ($TMP_SIZE) is too small for the current usage. Please specify a size larger than ${REQUIRED_SIZE}K.${NC}"
    exit 1
fi

# Backup /etc/fstab
if sudo cp /etc/fstab /etc/fstab.bak; then
    echo -e "${GREEN}Backup of /etc/fstab created.${NC}"
else
    echo -e "${RED}Failed to create backup of /etc/fstab.${NC}"
    exit 1
fi

# Check if /tmp entry exists in /etc/fstab
if grep -q "tmpfs\s\+/tmp" /etc/fstab; then
    # Modify the existing entry
    sudo sed -i "s|tmpfs\s\+/tmp\s\+tmpfs\s\+defaults,size=[^,]*|tmpfs /tmp tmpfs defaults,size=${TMP_SIZE}|g" /etc/fstab
    echo -e "${GREEN}/etc/fstab entry for /tmp modified.${NC}"
else
    # Add a new entry for /tmp
    echo "tmpfs /tmp tmpfs defaults,size=${TMP_SIZE} 0 0" | sudo tee -a /etc/fstab
    echo -e "${GREEN}New entry for /tmp added to /etc/fstab.${NC}"
fi

# Reload the systemd configuration
sudo systemctl daemon-reload
echo -e "${GREEN}systemd configuration reloaded.${NC}"

# Ensure /tmp is mounted before trying to remount it
if mountpoint -q /tmp; then
    # Remount /tmp with the new size
    sudo mount -o remount,size=${TMP_SIZE} /tmp
    echo -e "${GREEN}/tmp remounted with the new size.${NC}"
else
    echo -e "${RED}/tmp is not mounted. Trying to mount it.${NC}"
    sudo mount /tmp
    echo -e "${GREEN}/tmp mounted successfully.${NC}"
    sudo mount -o remount,size=${TMP_SIZE} /tmp
    echo -e "${GREEN}/tmp remounted with the new size.${NC}"
fi

# Verify the new size
df -h /tmp
echo -e "${GREEN}The size of /tmp has been set to ${TMP_SIZE} and remounted successfully.${NC}"

