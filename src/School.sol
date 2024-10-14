// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// Importing the staff and contractors contracts
//import "./staff.sol"; // Importing the staffWorkers contract
import "./Contractors.sol"; // Importing the SchoolContractors contract

// Main contract that combines functionalities from staffWorkers and SchoolContractors
contract School is SchoolContractors {

    // Enum representing the categories of schools
    enum SchoolCategory {
        PUBLIC,   // Represents public schools
        PRIVATE   // Represents private schools
    }

    // Enum representing the types of schools
    enum SchoolType {
        PRIMARY,  // Represents primary schools
        HIGHSCHOOL, // Represents high schools
        COLLEGE    // Represents colleges
    }

    // Struct representing the details of a school
    struct SchoolDetails {
        uint256 id;                     // Unique identifier for the school
        address schoolAddress;          // Address of the school (contract deployer)
        string schoolName;              // Name of the school
        SchoolType schoolType;          // Type of the school (PRIMARY, HIGHSCHOOL, COLLEGE)
        SchoolCategory schoolCategory;   // Category of the school (PUBLIC, PRIVATE)
    }

    // Public variable to track the total funds received by the school
    uint256 public totalFunds;

    // Mapping to store school details by their unique ID
    mapping(uint256 => SchoolDetails) private schoolDetails;

    // Mapping to track whether a school has been registered by an address
    mapping(address => bool) private registeredSchools; 

    // Event emitted when a new school is registered
    event registeredSchool(string _schoolname);

    // Constructor to initialize a new school
    constructor (
        string memory _schoolName,      // School name provided at deployment
        SchoolType _schoolType,         // School type (PRIMARY, HIGHSCHOOL, COLLEGE)
        SchoolCategory _schoolCategory,  // School category (PUBLIC, PRIVATE)
        uint256 _id                     // Unique ID for the school
    ) {
        // Ensure the sender has not already registered a school
        require(!registeredSchools[msg.sender], "An address can only register one school");

        // Creating a new instance of SchoolDetails
        SchoolDetails memory newSchool = SchoolDetails({
            schoolAddress: msg.sender,  // Setting the address of the school to the sender's address
            id: _id,                   // Assigning the provided ID
            schoolName: _schoolName,   // Assigning the provided school name
            schoolType: _schoolType,    // Assigning the provided school type
            schoolCategory: _schoolCategory // Assigning the provided school category
        });

        // Storing the new school's details in the mapping
        schoolDetails[_id] = newSchool;  
        registeredSchools[msg.sender] = true; // Marking the sender's address as registered

        // Emitting the event for the newly registered school
        emit registeredSchool(_schoolName);
    }

    // Function to retrieve the details of a school by its unique ID
    function getSchool(uint256 _id) public view returns (SchoolDetails memory) {
        return schoolDetails[_id]; // Returning the school details from the mapping
    }
    
    // Function to receive funds (Ether) sent to the contract
    function receiveFunds() public payable {
        require(msg.value > 0, "No Ether sent."); // Ensure that the value sent is greater than zero
        totalFunds += msg.value; // Accumulate the received funds to totalFunds
    }
}
