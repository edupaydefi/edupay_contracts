// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// Import the `School` contract (assuming it exists in the same directory).
import {School} from "./School.sol";

/// @title Staff Workers Contract
/// @notice This contract allows managing staff workers for a school, including adding, retrieving, and deleting staff information.
/// @dev Inherits from the `School` contract.
contract staffWorkers is School {

    // Define a structure for staff workers.
    struct staffWorkerStruct {
        string name;           // Name of the staff worker
        string department;     // Department where the staff worker is assigned
        uint256 staffID;       // Unique ID of the staff worker
        uint256 salary;        // Salary of the staff worker
        address staffAddress;  // Address of the staff worker (Ethereum address)
    }

    // Mapping of staff workers, where each staff ID maps to the corresponding staff details.
    mapping(uint256 => staffWorkerStruct) public staffworker;

    // Variable to keep track of the number of staff workers.
    uint256 public staffCount;

    /// @notice Adds a new staff member to the contract.
    /// @param _name The name of the staff member.
    /// @param _department The department the staff member works in.
    /// @param _salary The salary of the staff member.
    /// @param _staffAddress The Ethereum address of the staff member.
    /// @param _staffID The unique ID assigned to the staff member.
    /// @return The unique ID of the staff member after successfully adding them.
    function addStaff(
        string memory _name, 
        string memory _department,
        uint256 _salary, 
        address _staffAddress, 
        uint256 _staffID
    ) public returns (uint256) {
        // Create a new staff worker using the provided details.
        staffWorkerStruct memory newStaff = staffWorkerStruct({
            name: _name,
            department: _department,
            salary: _salary,
            staffAddress: _staffAddress,
            staffID: _staffID
        });

        // Add the new staff member to the `staffworker` mapping using the staff ID as the key.
        staffworker[_staffID] = newStaff;

        // Ensure the salary is greater than zero before adding the staff member.
        require(_salary > 0, "The salary must be a positive number");

        // Increment the total staff count.
        staffCount++;

        // Return the staff ID of the newly added staff member.
        return _staffID;
    }

    /// @notice Retrieves the details of a specific staff member by their staff ID.
    /// @param _id The unique ID of the staff member.
    /// @return The staff member's name, department, salary, Ethereum address, and staff ID.
    function getStaff(uint256 _id) public view returns (
        string memory, 
        string memory, 
        uint256, 
        address, 
        uint256
    ) {
        // Ensure the staff member exists by checking their staff ID.
        require(staffworker[_id].staffID != 0, "The ID doesn't exist");

        // Retrieve the staff details from the mapping.
        staffWorkerStruct storage staff = staffworker[_id];

        // Return the staff member's details.
        return (
            staff.name,
            staff.department,
            staff.salary,
            staff.staffAddress,
            staff.staffID
        );
    }

    /// @notice Retrieves a list of all staff members.
    /// @return An array of all staff workers.
    function getAllStaff() public view returns (staffWorkerStruct[] memory) {
        // Initialize an array of `staffWorkerStruct` with the size of `staffCount`.
        staffWorkerStruct[] memory allStaff = new staffWorkerStruct[](staffCount);

        // Populate the array with staff workers from the mapping.
        for (uint256 i = 1; i <= staffCount; i++) {
            allStaff[i - 1] = staffworker[i];
        }

        // Return the list of all staff members.
        return allStaff;
    }

    /// @notice Deletes a staff member by their staff ID.
    /// @param _id The unique ID of the staff member to delete.
    /// @return A message confirming the deletion.
    function deleteStaff(uint256 _id) public returns (string memory) {
        // Ensure the staff member exists before attempting to delete them.
        require(staffworker[_id].staffID != 0, "Staff worker does not exist");

        // Store the staff ID for return confirmation (optional, not used in the message below).
        uint256 _staffid = staffworker[_id].staffID;

        // Delete the staff worker from the mapping.
        delete staffworker[_id];

        // Decrease the total staff count.
        staffCount--;

        // Return a message confirming the deletion of the staff member.
        return "The staff worker with ID of {_staffid} has been deleted.";
    }
}
