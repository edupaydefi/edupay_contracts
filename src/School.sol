// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./Student.sol";
import "./Receipts.sol";

contract SchoolContract is Ownable {
    // USDC Token setup
    address public usdcAddress = 0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d;
    IERC20 public usdcToken;

    constructor() Ownable(msg.sender) {
        usdcToken = IERC20(usdcAddress);
    }

    struct SchoolStruct {
        string name;
        string location;
        uint256 id;
        address payable wallet;
        bool isRegistered;
        string email;
        string description;
        string category;
        uint256 registrationDate;
        uint256 balance;
    }

    // State variables
    mapping(address => SchoolStruct) public schools;
    mapping(address => bool) public isSchoolRegistered;
    mapping(address => bool) public isLoggedIn;
    uint256 private _currentSchoolId;

    // Events
    event SchoolSelfRegistered(address indexed schoolAddress, string name, uint256 id, uint256 timestamp);
    event SchoolProfileUpdated(address indexed school, string name, uint256 timestamp);
    event SchoolDeregistered(address indexed school, uint256 timestamp);
    event PaymentReceived(address indexed from, address indexed school, uint256 amount, string reason);
    event PaymentSent(address indexed from, address indexed to, uint256 amount, string reason);
    event SchoolLoggedIn(address indexed school, uint256 timestamp);
    event SchoolLoggedOut(address indexed school, uint256 timestamp);

    // Custom errors
    error SchoolAlreadyRegistered();
    error SchoolNotRegistered();
    error SchoolAlreadyLoggedIn();
    error SchoolNotLoggedIn();
    error InsufficientBalance();
    error InvalidAmount();
    error TransferFailed();
    error InvalidAddress();
    error EmptyStringNotAllowed();

    // Modifiers
    modifier onlyRegisteredSchool() {
        if (!isSchoolRegistered[msg.sender]) revert SchoolNotRegistered();
        _;
    }

    modifier onlyLoggedInSchool() {
        if (!isLoggedIn[msg.sender]) revert SchoolNotLoggedIn();
        _;
    }

    modifier validString(string memory str) {
        if (bytes(str).length == 0) revert EmptyStringNotAllowed();
        _;
    }

    // Self-registration function for schools
    function registerSchool(
        string memory _name,
        string memory _location,
        string memory _email,
        string memory _description,
        string memory _category
    ) external 
      validString(_name)
      validString(_email) 
      returns (uint256) {
        if (isSchoolRegistered[msg.sender]) revert SchoolAlreadyRegistered();
        if (msg.sender == address(0)) revert InvalidAddress();

        _currentSchoolId++;

        schools[msg.sender] = SchoolStruct({
            name: _name,
            location: _location,
            id: _currentSchoolId,
            wallet: payable(msg.sender),
            isRegistered: true,
            email: _email,
            description: _description,
            category: _category,
            registrationDate: block.timestamp,
            balance: 0
        });

        isSchoolRegistered[msg.sender] = true;

        emit SchoolSelfRegistered(msg.sender, _name, _currentSchoolId, block.timestamp);
        return _currentSchoolId;
    }

    function loginSchool() external onlyRegisteredSchool returns (string memory, uint256, address) {
        if (isLoggedIn[msg.sender]) revert SchoolAlreadyLoggedIn();
        
        SchoolStruct memory school = schools[msg.sender];
        isLoggedIn[msg.sender] = true;
        
        emit SchoolLoggedIn(msg.sender, block.timestamp);
        return (school.name, school.id, school.wallet);
    }

    function logoutSchool() external onlyLoggedInSchool returns (string memory) {
        isLoggedIn[msg.sender] = false;
        emit SchoolLoggedOut(msg.sender, block.timestamp);
        return "Logged Out Successfully";
    }

    function updateSchoolProfile(
        string memory _name,
        string memory _location,
        string memory _email,
        string memory _description,
        string memory _category
    ) external 
      onlyRegisteredSchool 
      onlyLoggedInSchool 
      validString(_name)
      validString(_email)
      returns (bool) {
        SchoolStruct storage school = schools[msg.sender];
        
        school.name = _name;
        school.location = _location;
        school.email = _email;
        school.description = _description;
        school.category = _category;

        emit SchoolProfileUpdated(msg.sender, _name, block.timestamp);
        return true;
    }

    function deregisterSchool() external onlyRegisteredSchool onlyLoggedInSchool {
        require(schools[msg.sender].balance == 0, "Withdraw all funds before deregistering");
        delete schools[msg.sender];
        isSchoolRegistered[msg.sender] = false;
        isLoggedIn[msg.sender] = false;
        emit SchoolDeregistered(msg.sender, block.timestamp);
    }

    // Payment functions
    function payStaff(address payable _staffAddress, uint256 _amount, string memory _reason) 
        external 
        onlyRegisteredSchool 
        onlyLoggedInSchool 
        returns (string memory) 
    {
        if (_amount == 0) revert InvalidAmount();
        if (schools[msg.sender].balance < _amount) revert InsufficientBalance();

        bool success = usdcToken.transfer(_staffAddress, _amount);
        if (!success) revert TransferFailed();

        schools[msg.sender].balance -= _amount;

        emit PaymentSent(msg.sender, _staffAddress, _amount, _reason);
        return "Paymen successfullt to staff";
    }

    // Receive Payment functions
    function receivePayment() 
        external 
        view
        onlyRegisteredSchool 
        onlyLoggedInSchool 
        returns (address payable) 
    {
        
        return schools[msg.sender].wallet ;
    }

    function withdrawFunds(uint256 _amount) 
        external 
        onlyRegisteredSchool 
        onlyLoggedInSchool 
    {
        if (_amount == 0) revert InvalidAmount();
        if (schools[msg.sender].balance < _amount) revert InsufficientBalance();

        bool success = usdcToken.transfer(msg.sender, _amount);
        if (!success) revert TransferFailed();

        schools[msg.sender].balance -= _amount;
        emit PaymentSent(address(this), msg.sender, _amount, "Withdrawal");
    }

    // View functions
    function getSchoolBalance() external view onlyRegisteredSchool onlyLoggedInSchool returns (uint256) {
        return schools[msg.sender].balance;
    }

    function getSchoolDetails() external view onlyRegisteredSchool onlyLoggedInSchool returns (SchoolStruct memory) {
        return schools[msg.sender];
    }

    function verifySchool(address _schoolAddress) external view returns (bool, string memory) {
        if (!isSchoolRegistered[_schoolAddress]) {
            return (false, "School not registered");
        }
        return (true, schools[_schoolAddress].name);
    }

    // Receive function for direct payments
    receive() external payable {
        if (!isSchoolRegistered[msg.sender]) revert SchoolNotRegistered();
        schools[msg.sender].balance += msg.value;
        emit PaymentReceived(msg.sender, address(this), msg.value, "Direct Transfer");
    }
}