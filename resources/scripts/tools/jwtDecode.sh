#!/usr/bin/env bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Function to decode base64url
base64url_decode() {
  local input=$1
  local padding=$(printf %$(( (4 - ${#input} % 4) % 4 ))s | tr ' ' =)
  echo "$input$padding" | base64 --decode | jq .
}

# Check if JWT is provided
if [ -z "$1" ]; then
  echo -e "${RED}Error: No JWT provided.${RESET}"
  echo "Usage: $0 <JWT>"
  exit 1
fi

# Split the JWT into its components
IFS='.' read -r header payload signature <<< "$1"

# Reprint the full JWT with color-coded parts
echo -e "${YELLOW}Full JWT:${RESET}"
echo -e "${BLUE}${header}${RESET}.${GREEN}${payload}${RESET}.${RED}${signature}${RESET}"
echo

# Decode and display the parts
echo -e "${YELLOW}Header:${RESET}"
echo -e "${BLUE}"
base64url_decode "$header"
echo -e "${RESET}"

echo -e "${YELLOW}Payload:${RESET}"
echo -e "${GREEN}"
base64url_decode "$payload"
echo -e "${RESET}"

echo -e "${YELLOW}Signature (Base64URL Encoded):${RESET} ${RED}$signature${RESET}"
