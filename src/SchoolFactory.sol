// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./Student.sol";
import "./School.sol";
import "./Receipts.sol";

contract StudentSystemFactory is Ownable {
    // Deployed contract addresses
    address public studentContractAddress;
    address public schoolContractAddress;
    address public receiptContractAddress;

    // USDC token address
    address public usdcAddress;

    // Flag to check if contracts have been deployed
    bool public contractsDeployed = false;

    // Events
    event ContractsDeployed(
        address indexed studentContract,
        address indexed schoolContract,
        address indexed receiptContract
    );

    constructor(address _usdcAddress) Ownable(msg.sender) {
        require(_usdcAddress != address(0), "Invalid USDC address");
        usdcAddress = _usdcAddress;
    }

    // Deploy all contracts in the correct order
    function deployContracts() external onlyOwner {
        require(!contractsDeployed, "Contracts have already been deployed.");

        // 1. Deploy Student Contract
        StudentContract studentContract = new StudentContract();
        studentContractAddress = address(studentContract);

        // 2. Deploy School Contract
        SchoolContract schoolContract = new SchoolContract();
        schoolContractAddress = address(schoolContract);

        // 3. Deploy Receipt Contract (which depends on both Student and School contracts)
        ReceiptContract receiptContract = new ReceiptContract(
            studentContractAddress,
            schoolContractAddress
        );
        receiptContractAddress = address(receiptContract);

        // Set the flag to true after deployment
        contractsDeployed = true;

        emit ContractsDeployed(
            studentContractAddress,
            schoolContractAddress,
            receiptContractAddress
        );
    }

    // Getter functions
    function getDeployedAddresses() external view returns (
        address student,
        address school,
        address receipt
    ) {
        return (
            studentContractAddress,
            schoolContractAddress,
            receiptContractAddress
        );
    }
}
