#!/bin/bash

# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Source the generate.sh script to extract the value of $O
source generate.sh

# Ensure that $O, $subject, and $PRIVATE_KEY are set and not empty
if [ -z "$O" ] || [ -z "$subject" ] || [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}Error: One or more variables (\$O, \$subject, or \$PRIVATE_KEY) are not set or empty. Please set them in generate.sh.${NC}"
    exit 1
fi

# Exit immediately if a command exits with a non-zero status
set -e

# Function to handle errors
handle_error() {
    local lineno="$1"
    local msg="$2"
    echo -e "${RED}Error on line $lineno: $msg${NC}"
    exit 1
}
trap 'handle_error ${LINENO} "$BASH_COMMAND"' ERR

# Check if the RSA private key and Android certificates directory exist
if [ -f ~/$O.pem ] && [ -d ~/.android-certs ]; then
    echo
    echo -e "${YELLOW}The RSA private key and Android certificates directory already exist.${NC}"
    read -p "Do you want to regenerate the RSA private key? (y/n): " choice
    case "$choice" in
        y|Y )
            read -p "Do you want to take a backup? (y/n): " backup_choice
            case "$backup_choice" in
                y|Y )
                    echo -e "${GREEN}Taking backup and regenerating RSA private key...${NC}"
                    backup_dir=~/.backup_keys/$(date +%m-%d)/$(date +%s)
                    mkdir -p "$backup_dir"
                    mv ~/$O.pem "$backup_dir/"
                    mv ~/.android-certs "$backup_dir/"
                    ;;
                n|N )
                    echo -e "${RED}Skipping backup and regenerating RSA private key.${NC}"
                    ;;
                * )
                    echo -e "${RED}Invalid choice. Aborting.${NC}"
                    exit 1
                    ;;
            esac
            ;;
        n|N )
            echo -e "${RED}Aborting.${NC}"
            exit 0
            ;;
        * )
            echo -e "${RED}Invalid choice. Aborting.${NC}"
            exit 1
            ;;
    esac
fi

# Generate a 4096-bit RSA private key using traditional format and place it in the home directory
echo
echo -e "${GREEN}Generating a 4096-bit RSA private key in the home directory...${NC}"
echo
openssl genrsa -traditional -out ~/$O.pem 4096
echo -e "${YELLOW}RSA private key path: $PRIVATE_KEY${NC}"

# Create a directory for Android certificates if it doesn't exist
echo
echo -e "${GREEN}Creating directory ~/.android-certs...${NC}"
echo
mkdir -p ~/.android
