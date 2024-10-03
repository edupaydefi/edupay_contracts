// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./School.sol";

contract Factory is School {
    event SchoolDeployed(address indexed schoolAddress);
    mapping(address=>address) public deployedContracts;
   
    constructor(string memory _schoolName, SchoolType _schoolType, SchoolCategory _schoolCategory, uint256 _id) 
        School(_schoolName, _schoolType, _schoolCategory, _id) 
    {

          School newSchool = new School(_schoolName, _schoolType, _schoolCategory, _id);
        emit SchoolDeployed(address(newSchool));
        deployedContracts[msg.sender]= address(newSchool);
    }

    // function deploySchoolContract(
    //     string memory _schoolName,
    //     SchoolType _schoolType,
    //     SchoolCategory _schoolCategory,
    //     uint256 _id
    // ) public returns (address) {
    //     School newSchool = new School(_schoolName, _schoolType, _schoolCategory, _id);
    //     emit SchoolDeployed(address(newSchool));
    //     return address(newSchool);
    // }
}
