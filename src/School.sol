// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract School {
    enum SchoolCategory {
        PUBLIC,
        PRIVATE
    }

    enum SchoolType {
        PRIMARY,
        HIGHSCHOOL,
        COLLEGE
    }

    struct SchoolDetails {
        uint256 id;
        address schoolAddress;
        string schoolName;
        SchoolType schoolType;
        SchoolCategory schoolCategory;
    }

    mapping(uint256 => SchoolDetails) private  schoolDetails;
    mapping(address => bool) private  registeredSchools; 
    event registeredSchool(string _schoolname);

    function registerSchool(
        string memory _schoolName, 
        SchoolType _schoolType, 
        SchoolCategory _schoolCategory, 
        uint256 _id
    ) public returns (SchoolDetails memory) {
       
        require(!registeredSchools[msg.sender], "An address can only register one school");

        SchoolDetails memory newSchool = SchoolDetails({
            schoolAddress: msg.sender,
            id: _id,
            schoolName: _schoolName,
            schoolType: _schoolType,
            schoolCategory: _schoolCategory
        });

        schoolDetails[_id] = newSchool;  
        registeredSchools[msg.sender] = true;  

        emit registeredSchool(_schoolname);

        return newSchool;
    }

    function getSchool(uint256 _id) public view returns (SchoolDetails memory) {
       
        return schoolDetails[_id];
    }

     function receiveFunds() public payable {
        require(msg.value > 0, "No Ether sent.");
        totalFunds += msg.value;
        emit PaymentReceived(msg.sender, msg.value);
    }
}
