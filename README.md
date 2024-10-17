# ANOME ecosystem

## Overview
This project contains the implementation of the ANOME ecosystem, an ERC20 token deployed on the Ethereum blockchain.

## Requirements
- Node.js
- Hardhat or Truffle
- Solidity ^0.8.20
- Ganache or Infura (for connecting to the Ethereum testnet/mainnet)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/soulstar9792/ANOME.git
   cd ANOME
2. Install dependencies:
   ```bash
   npm install
3. Set up environment variables: Create a .env file in the root directory and add the following:
   ```bash
   INFURA_API_KEY=your-infura-api-key
   MNEMONIC="your mnemonic here"

## Deploying to Rinkeby
 - Compile Contracts
   ```bash
   npx hardhat compile
   ```
 - Deploy Contracts
   ```bash
   npx hardhat run scripts/deploy.js --network rinkeby 
 
 - Testing
   ```bash
   npx hardhat test

 - Interact with Deployed Contract
   ```bash
   npx hardhat run scripts/interact.js --network rinkeby