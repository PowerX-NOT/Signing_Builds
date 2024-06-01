#!/bin/bash

# Define colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Source the generate.sh script to extract the value of $O
source generate.sh

# Ensure that $O is set and not empty
if [ -z "$O" ]; then
    echo -e "${RED}Error: Variable \$O is not set or empty. Please set it in generate.sh.${NC}"
    exit 1
fi

if [ -z "$subject" ]; then
    echo -e "${RED}Error: Variable \$subject is not set or empty. Please set it in generate.sh.${NC}"
    exit 1
fi

if [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}Error: Variable \$subject is not set or empty. Please set it in generate.sh.${NC}"
    exit 1
fi

rm -rf ~/$O.pem
rm -rf ~/.android-certs

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

# Generate a 4096-bit RSA private key using traditional format and place it in the home directory
echo -e "${GREEN}Generating a 4096-bit RSA private key in the home directory...${NC}"
echo
openssl genrsa -traditional -out ~/$O.pem 4096
echo -e "${YELLOW}RSA private key path: $PRIVATE_KEY${NC}"

# Create a directory for Android certificates if it doesn't exist
echo
echo -e "${GREEN}Creating directory ~/.android-certs...${NC}"
echo
mkdir -p ~/.android-certs

# Copy the generate.sh script to the Android certificates directory
echo -e "${GREEN}Copying generate.sh to ~/.android-certs/...${NC}"
echo
cp generate.sh ~/.android-certs/

# Change to the Android certificates directory
echo -e "${GREEN}Changing directory to ~/.android-certs/...${NC}"
echo
cd ~/.android-certs/

# Make the generate.sh script executable
echo -e "${RED}Making generate.sh executable...${NC}"
echo
chmod +x generate.sh

# Execute the generate.sh script
echo -e "${GREEN}Executing generate.sh...${NC}"
echo
./generate.sh

echo -e "${YELLOW}Your Subject: $subject${NC}"

# Remove the generate.sh script after execution
echo
echo -e "${GREEN}Removing generate.sh...${NC}"
echo
rm -f generate.sh

echo -e "${RED}PRIVATE KEYs GENERATED${NC}"
echo
echo -e "${YELLOW}Now copy build.sh your ROM source directory${NC}"
