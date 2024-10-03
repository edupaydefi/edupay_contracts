// SPDX-License-Identifier: MIT
<<<<<<< HEAD
pragma solidity ^0.8.0;


contract School {
    enum SchoolCategory {
=======
pragma solidity ^0.8.27;
import "./staff.sol";
import "./Contractors.sol";
contract School is staffWorkers,SchoolContractors{
        enum SchoolCategory {
>>>>>>> 67cbaf681c24ae118ea65b3635139b47f6c4c816
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
uint256  public totalFunds;
    mapping(uint256 => SchoolDetails) private  schoolDetails;
    mapping(address => bool) private  registeredSchools; 
    event registeredSchool(string _schoolname);

  constructor (
        string memory _schoolName, 
        SchoolType _schoolType, 
        SchoolCategory _schoolCategory, 
        uint256 _id
    )  {
       
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

        emit registeredSchool(_schoolName);

       
    }

    function getSchool(uint256 _id) public view returns (SchoolDetails memory) {
       
        return schoolDetails[_id];
    }
    
  function receiveFunds() public payable {
        require(msg.value > 0, "No Ether sent.");
        totalFunds += msg.value;
       
    }

}