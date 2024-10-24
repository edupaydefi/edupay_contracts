
---

# EduPay Contracts

EduPay is a decentralized contract system designed to manage educational institutions, students, and receipts in a secure, transparent manner. The contracts ensure that each component—students, schools, and receipts—is deployed only once to maintain uniqueness, governed by a factory contract.

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Deploying the Contracts](#deploying-the-contracts)
- [Testing](#testing)
- [Usage](#usage)
- [License](#license)

## Overview

This repository contains smart contracts for managing an education payment system. The contracts include:
- **StudentContract**: Handles student registration and data.
- **SchoolContract**: Manages school registration and associated details.
- **ReceiptContract**: Records payment receipts between schools and students.
  
The `StudentSystemFactory` contract ensures that each contract type is deployed only once.

## Project Structure

```bash
├── src
│   ├── Student.sol            # Manages students
│   ├── School.sol             # Manages schools
│   └── Receipts.sol           # Records payments between students and schools
├── test
│   ├── Student.t.sol          # Test cases for Student contract
│   ├── School.t.sol           # Test cases for School contract
│   └── Receipts.t.sol         # Test cases for Receipt contract
├── script
│   ├── Deploy.s.sol           # Deployment script for contracts
├── foundry.toml               # Foundry configuration file
├── .env.example               # Environment variables template
├── README.md                  # Project documentation
└── lib                        # Libraries (OpenZeppelin, etc.)
```

## Features

- **One-time Contract Deployment**: Deploy contracts for students, schools, and receipts exactly once.
- **Decentralized Factory System**: Deploy multiple contracts from a central factory for easy management.
- **Automated Receipts**: Keep track of payments between schools and students.

## Tech Stack

- **Solidity**: Smart contract programming language.
- **Foundry**: Ethereum smart contract development framework.
- **OpenZeppelin**: Secure library for reusable Solidity code.
- **Ethers.js**: Library for interacting with the Ethereum blockchain.

## Prerequisites

- [Foundry](https://github.com/foundry-rs/foundry) (latest version)
- [Node.js](https://nodejs.org/en/) (optional, for auxiliary tools)
- [Solidity](https://soliditylang.org/) (v0.8.0 or higher)
- [Forge](https://book.getfoundry.sh/forge/) (testing framework)

### Setting Up Foundry

If you don’t have Foundry installed, run:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

## Setup

1. Clone the repository:

```bash
git clone https://github.com/edupaydefi/edupay_contracts.git
cd edupay_contracts
```

2. Install dependencies:

```bash
forge install
```

3. Set up environment variables:

```bash
cp .env.example .env
# Update .env with your details if necessary
```

## Deploying the Contracts

To deploy the contracts, use the provided Foundry script:

1. Configure your environment in `.env` (e.g., private key, RPC URL).
2. Deploy the contracts using Forge:

```bash
forge script script/Deploy.s.sol:Deploy --broadcast --verify --rpc-url $RPC_URL
```

3. This will deploy the `StudentSystemFactory` contract, which will in turn deploy the `StudentContract`, `SchoolContract`, and `ReceiptContract`.

4. The deployed contract addresses will be displayed upon successful deployment.

## Testing

To run tests:

1. Ensure that Foundry is properly set up with `forge`.
2. Run the test suite:

```bash
forge test
```

This will execute all test cases in the `test/` directory and provide detailed feedback on the functionality and security of the contracts.

## Usage

Once the contracts are deployed, you can interact with them through the `StudentSystemFactory`:

- **Deploy Contracts**: Call `deployContracts()` to initialize and deploy the student, school, and receipt contracts.
- **Fetch Deployed Addresses**: Use `getDeployedAddresses()` to retrieve the addresses of the deployed contracts.

You can interact with the contracts via a web3 interface (e.g., Ethers.js) or directly through the command line.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.

---

### Additional Notes:
1. Ensure that `.env.example` contains necessary variables such as `RPC_URL` and `PRIVATE_KEY`.
2. Update the deployment steps if there are any network-specific requirements (e.g., for testnets like Goerli or mainnet).
3. Provide a detailed section on "Usage" if the contracts have specific methods that should be called during interaction.