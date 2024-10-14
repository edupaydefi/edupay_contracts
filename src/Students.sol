// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

contract studentsContract {
    // Enum to define types of students: School Registered or Freelance
    enum StudentType {
        SchoolRegistered,
        Freelance
    }
    
    // Struct to store student entities
    struct Student {
        string name; // Student's name
        bytes32 emailHash; // Student's email
        bytes32 passwordHash; // Hashed password for security
        uint256 id; // Unique identifier for the student
        address payable studentAddress; // Student's Ethereum address
        StudentType studenttype; // Type of student (registered or freelance)
    }
    
    // Mapping to associate student IDs with their corresponding Student struct
    mapping(uint256 => Student) public students;

    uint256 public studentCount; // Counter for the total number of registered students

    // Event to log student registration
    event studenthasRegistered(string name, uint256 id, string email);
    // Event to log successful login
    event LoginSuccessfull(uint256 id);
    // Event to log failed login attempts
    event LoginFailed(uint256 id);

    // Function to register a new student
    function studentRegister(
        string memory _name, // Name of the student
        string memory _email, // Email of the student
        string memory _password, // Password to be hashed
        uint256 _id, // Unique ID for the student
        StudentType _studenttype // Type of student (registered or freelance)
    ) external returns (string memory) {
        // Ensure that a student with this ID does not already exist
        require(students[_id].studentAddress == address(0), "Student with this id already exist");

        // Hashing the password before storing it for security
        bytes32 passwordHash = keccak256(abi.encodePacked(_password));
        bytes32 emailHash = keccak256(abi.encodePacked(_email));
        
        // Create a new Student instance and store it in the mapping
        students[_id] = Student({
            name: _name, // Assigning name
            emailHash: emailHash, // Assigning email
            passwordHash: passwordHash, // Storing hashed password
            id: _id, // Assigning unique ID
            studentAddress: payable(msg.sender), // Assigning the sender's address
            studenttype: _studenttype // Assigning the student type
        });

        // Increment the total student count
        studentCount++;
        
        // Emit the registration event with student's details
        emit studenthasRegistered(_name, _id, _email);
        
        return "Success: Student Register"; // Return success message
    }

    // Function for students to log in
    function studentLogin(uint256 _id, string memory _password) external {
        // Retrieve the student from the mapping using the provided ID
        Student storage student = students[_id];
        
        // Ensure the student exists
        require(student.studentAddress != address(0), "Student ID not found");

        // Check if the provided password matches the stored password hash
        if (student.passwordHash == keccak256(abi.encodePacked(_password))) {
            emit LoginSuccessfull(_id); // Emit successful login event
        } else {
            emit LoginFailed(_id); // Emit failed login event
            revert("Login failed: Invalid password"); // Revert the transaction for invalid password
        }
    }

    // Function to retrieve student details
    function getStudent(uint256 _id) external view returns(string memory, uint256, StudentType) {
        // Ensure the student exists before attempting to retrieve details
        require(students[_id].id == _id, "Student with this account does not exist");
        
        // Retrieve the student from the mapping
        Student storage student = students[_id];
        
        // Return the student's details
        return (
            student.name, // Student's name
            student.id, // Student's unique ID
            student.studenttype // Student's type (registered or freelance)
        );
    }
}
