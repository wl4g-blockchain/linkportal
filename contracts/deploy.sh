#!/bin/bash
set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Load environment variables
source .env

# Network selection menu
select_network() {
    echo -e "${YELLOW}Select target network:${NC}"
    echo "1) Ethereum Mainnet"
    echo "2) Sepolia Testnet"
    echo "3) Avalanche Mainnet"
    echo "4) Avalanche Fuji"
    echo "5) Optimism Mainnet"
    echo "6) Optimism Goerli"
    # Not implemented yet?
    #echo "7) BSC Mainnet"
    #echo "8) BSC Testnet"
    
    read -p "Enter choice (1-8): " choice
    
    case $choice in
        1) export CHAIN_ID=1 ;;
        2) export CHAIN_ID=11155111 ;;
        3) export CHAIN_ID=43114 ;;
        4) export CHAIN_ID=43113 ;;
        5) export CHAIN_ID=10 ;;
        6) export CHAIN_ID=420 ;;
        7) export CHAIN_ID=56 ;;
        8) export CHAIN_ID=97 ;;
        *) echo -e "${RED}Invalid choice${NC}" && exit 1 ;;
    esac
}

# Deploy function
deploy() {
    echo -e "${YELLOW}Starting deployment...${NC}"
    
    # Get RPC URL based on network
    RPC_URL_VAR="RPC_URL_${CHAIN_ID}"
    RPC_URL=${!RPC_URL_VAR}
    
    if [ -z "$RPC_URL" ]; then
        echo -e "${RED}Error: RPC URL not found for chain ID ${CHAIN_ID}${NC}"
        exit 1
    }
    
    # Deploy contracts
    forge script script/DeployRealEstate.s.sol:DeployRealEstateScript \
        --rpc-url ${RPC_URL} \
        --broadcast \
        --verify \
        -vvvv \
        --etherscan-api-key ${ETHERSCAN_API_KEY} \
        --slow
}

# Main execution
select_network
deploy

echo -e "${GREEN}Deployment process completed!${NC}"