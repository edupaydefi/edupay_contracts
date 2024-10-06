//SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract staff {
    enum employeeStatus {
        Active,
        Terminated,
        Retired,
        Suspended,
        Resigned
    }

    enum employeePosition {
        Manager,
        Supervisor,
        Worker
    }

    enum EmploymentType {
        FullTime,
        PartTime,
        Contract,
        Temporary,
        Internship,
        Volunteer
    }

    struct employeeStruct {
        string name;
        uint256 id;
        uint256 salary;
        string department;
        address payable employeeAddress;

        employeeStatus status;
        employeePosition position;
        EmploymentType employmentType;
    }

    mapping(uint256 => employeeStruct) private  employees;
    uint256 public employeeCount;
   //mapping(uint256 => uint256)  employeeCounts;

   event employeeAdded(uint256 indexed _id, string _name, uint256 _salary, string _department, address _employeeAddress, employeeStatus _status, employeePosition _position, EmploymentType _employmentType);

   function addEmployee(
    string memory _name,
    uint256 _salary,
    uint256 _id,
    string memory _department,
    address payable _employeeAddress,
    employeeStatus _status,
    employeePosition _position,
    EmploymentType _employmentType
   ) public returns(string memory){
    require(_salary > 0, "Salary must be greater than zero");
    require(_employeeAddress != address(0), "Invalid employee address");
    require(_employeeAddress != employees[_id].employeeAddress, "Employee already exists");
    require(_id != employees[_id].id, "The Id already exists");
    require(bytes(_name).length > 0, "Name cannot be empty");
    require(bytes(_department).length > 0, "Department cannot be empty");

    employeeCount++;

    //employeeCount[_id];
    employeeStruct memory newEmployee = employeeStruct({
        name: _name,
        id: _id,
        salary: _salary,
        department: _department,
        employeeAddress: _employeeAddress,
        status: _status,
        position: _position,
        employmentType: _employmentType
    });

     employees[_id] = newEmployee;
     emit employeeAdded(_id, _name, _salary, _department, _employeeAddress, _status, _position, _employmentType);
    return "Employee added successfully";
   }

   function getEmployee(uint256 _id)public view returns(string memory, uint256, uint256, string memory, address, employeeStatus, employeePosition, EmploymentType){
    employeeStruct storage employee = employees[_id];
    return (
        employee.name,
        employee.id,
        employee.salary,
        employee.department,
        employee.employeeAddress,
        employee.status,
        employee.position,
        employee.employmentType
    );
   }
   function getAllEmployees() public view returns (employeeStruct[] memory) {
    employeeStruct[] memory allEmployee = new employeeStruct[](employeeCount);
    uint256 count = 0;
    for(uint256 i = 0; i < employeeCount; i++){
        allEmployee[count] = employees[i];
        count++;
    }
    return allEmployee;
   }

   
}
