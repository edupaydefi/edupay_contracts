// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./School1.sol";

contract Factory is School {
      struct StudentStruct{
        uint256 id;
string name;
address school;


    }

    event SchoolDeployed(address indexed schoolAddress);
    mapping(address=>address) public deployedContracts;
    mapping(uint256=>StudentStruct) public StudentData;
    mapping (address=>uint256) public Students;
 




   
    constructor(string memory _schoolName, SchoolType _schoolType, SchoolCategory _schoolCategory, uint256 _id) 
        School(_schoolName, _schoolType, _schoolCategory, _id) 
    {

          School newSchool = new School(_schoolName, _schoolType, _schoolCategory, _id);
        emit SchoolDeployed(address(newSchool));
        deployedContracts[msg.sender]= address(newSchool);
    }

    function registerStudent(string memory _name, address payable _school, uint256 _id) public returns (string memory){
        require(StudentData[_id].id != 0, "Student with that ID is already registered!");
StudentStruct memory newStudent= StudentStruct({
    id:_id,
    name:_name,
    school:_school
});
StudentData[_id]=newStudent;
Students[msg.sender]=_id;
return "Successs";


    }
    function payFees(uint256 _studentId, address payable  _to )public payable {
        require(!Students[msg.sender], "You are not registered on the platform yet");
        
         _to.transfer(msg.value);

    }

 
}
