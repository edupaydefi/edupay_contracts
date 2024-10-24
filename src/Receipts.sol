// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./Student.sol";
import "./School.sol";

interface IStudentContract {
    function students(address) external view returns (
        string memory FirstName,
        string memory LastName,
        uint256 id,
        string memory schools,
        string memory email,
        string memory bio,
        address wallet
    );
    function isLoggedIn(address) external view returns (bool);
}

interface ISchoolContract {
    function schools(address) external view returns (
        string memory name,
        string memory location,
        uint256 id,
        address payable wallet,
        bool isRegistered,
        string memory email
    );
    function isSchoolRegistered(address) external view returns (bool);
}

contract ReceiptContract is Ownable {
    uint256 private _currentReceiptId;
    
    IStudentContract public studentContract;
    ISchoolContract public schoolContract;
    
    struct Receipt {
        uint256 receiptId;
        address student;
        address school;
        uint256 amount;
        string reason;
        uint256 timestamp;
        bool isValid;
    }
    
    // Mappings
    mapping(uint256 => Receipt) public receipts;
    mapping(address => uint256[]) public studentReceipts;
    mapping(address => uint256[]) public schoolReceipts;
    
    // Events
    event ReceiptGenerated(
        uint256 indexed receiptId,
        address indexed student,
        address indexed school,
        uint256 amount,
        string reason,
        uint256 timestamp
    );
    event ReceiptVoided(uint256 indexed receiptId, address indexed voidedBy);
    
    // Custom errors
    error StudentNotLoggedIn();
    error SchoolNotRegistered();
    error InvalidReceiptId();
    error UnauthorizedAccess();
    error ReceiptAlreadyVoided();
    error InvalidAddress();
    
    constructor(address _studentContractAddress, address _schoolContractAddress) Ownable(msg.sender) {
        if(_studentContractAddress == address(0) || _schoolContractAddress == address(0)) 
            revert InvalidAddress();
        studentContract = IStudentContract(_studentContractAddress);
        schoolContract = ISchoolContract(_schoolContractAddress);
        _currentReceiptId = 0;
    }
    
    // Generate a receipt for a payment
    function generateReceipt(
        address _student,
        address _school,
        uint256 _amount,
        string memory _reason
    ) external returns (uint256) {
        // Check if student is logged in
        if (!studentContract.isLoggedIn(_student)) revert StudentNotLoggedIn();
        
        // Check if school is registered
        if (!schoolContract.isSchoolRegistered(_school)) revert SchoolNotRegistered();
        
        // Increment receipt ID
        _currentReceiptId++;
        
        // Create receipt
        Receipt memory newReceipt = Receipt({
            receiptId: _currentReceiptId,
            student: _student,
            school: _school,
            amount: _amount,
            reason: _reason,
            timestamp: block.timestamp,
            isValid: true
        });
        
        // Store receipt
        receipts[_currentReceiptId] = newReceipt;
        studentReceipts[_student].push(_currentReceiptId);
        schoolReceipts[_school].push(_currentReceiptId);
        
        emit ReceiptGenerated(
            _currentReceiptId,
            _student,
            _school,
            _amount,
            _reason,
            block.timestamp
        );
        
        return _currentReceiptId;
    }
    
    // Get all receipts for a student
    function getStudentReceipts(address _student) external view returns (Receipt[] memory) {
        uint256[] memory receiptIds = studentReceipts[_student];
        Receipt[] memory studentReceiptList = new Receipt[](receiptIds.length);
        
        for (uint256 i = 0; i < receiptIds.length; i++) {
            studentReceiptList[i] = receipts[receiptIds[i]];
        }
        
        return studentReceiptList;
    }
    
    // Get all receipts for a school
    function getSchoolReceipts(address _school) external view returns (Receipt[] memory) {
        uint256[] memory receiptIds = schoolReceipts[_school];
        Receipt[] memory schoolReceiptList = new Receipt[](receiptIds.length);
        
        for (uint256 i = 0; i < receiptIds.length; i++) {
            schoolReceiptList[i] = receipts[receiptIds[i]];
        }
        
        return schoolReceiptList;
    }
    
    // Void a receipt (can only be done by the school or contract owner)
    function voidReceipt(uint256 _receiptId) external {
        Receipt storage receipt = receipts[_receiptId];
        
        if (receipt.receiptId == 0) revert InvalidReceiptId();
        if (receipt.school != msg.sender && msg.sender != owner()) revert UnauthorizedAccess();
        if (!receipt.isValid) revert ReceiptAlreadyVoided();
        
        receipt.isValid = false;
        emit ReceiptVoided(_receiptId, msg.sender);
    }
    
    // Get a single receipt by ID
    function getReceipt(uint256 _receiptId) external view returns (Receipt memory) {
        if (receipts[_receiptId].receiptId == 0) revert InvalidReceiptId();
        return receipts[_receiptId];
    }

    // Get current receipt ID
    function getCurrentReceiptId() external view returns (uint256) {
        return _currentReceiptId;
    }

    // Function to check if a receipt exists and is valid
    function isReceiptValid(uint256 _receiptId) external view returns (bool) {
        Receipt memory receipt = receipts[_receiptId];
        return (receipt.receiptId != 0 && receipt.isValid);
    }
}