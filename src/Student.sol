// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./School.sol";
import "./Receipts.sol";

contract StudentContract is Ownable {
    //INITIALIZE THE CONSTRUCTOR
    //USDC TOKEN ADDRESS onArbitrum = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831
    //Mainnet USDC ON ARBITRUM address public usdcAddress = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address public usdcAddress = 0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d;

    IERC20 public usdcToken;

    constructor()Ownable(msg.sender){
        usdcToken = IERC20(usdcAddress);
    }
    //the struct containing students details
    struct StudentStruct {
        string FirstName;
        string LastName;
        uint256 id;
        string schools;
        string email;
        string bio;
        address payable wallet;
    }
    mapping(address => bool) public isLoggedIn;
    mapping(address => StudentStruct) public students;
    uint256 public studentCount;

    event StudentHasRegistered(string FirstName, uint256 id, address wallet);
    event studentLogin(string FirstName, uint256 id, address wallet);
    event studentLoggedOut(string FirstName, uint256 id, address wallet);
    event StudentProfileUpdated(address indexed student, string FirstName, uint256 id);
    event StudentDeletedProfile(address indexed student);
    event paymentConfirmed(address indexed student, address indexed school, uint256 amount, string reason);
    event FundsReceived(address indexed student, uint256 amount);

    modifier onlyLoggedIn() {
    if (!isLoggedIn[msg.sender]) revert StudentMustBeLoggedIn();
    _;
}



    //Custom error messages to useA
    error StudentAlreadyRegistered();
    error StudentNotRegistered();
    error StudentMustBeLoggedIn();
    error AmountMustBeGreaterThanZero();
    error InvalidID();


    function RegisterStudent(
        string memory _firstname,
        string memory _lastname,
        uint256 _id,
        string memory _schools,
        string memory _bio,
        string memory _email
    ) external  returns (string memory){
        require(students[msg.sender].wallet == address(0), "The student has already been registered ");
        if (students[msg.sender].wallet != address(0)) revert StudentAlreadyRegistered();
        require(students[msg.sender].id == 0, "The Id already exists");
        require(_id != 0, "The Id cannot be zero.");
        students[msg.sender] = StudentStruct({
            id: _id,
            wallet: payable(msg.sender),
            schools: _schools,
            FirstName: _firstname,
            LastName: _lastname,
            bio: _bio,
            email: _email
        });
        studentCount++;
        emit StudentHasRegistered(_firstname, _id, msg.sender);
        return "Student registered successfuly";
    }
    function deleteStudent() external onlyLoggedIn returns (string memory){
        if (students[msg.sender].wallet == address(0)) revert StudentNotRegistered();
        delete students[msg.sender];
        isLoggedIn[msg.sender] = false;
        studentCount--;
        emit StudentDeletedProfile(msg.sender);
        return "Successfully deleted students details";
    }

    function LoginStudent() external  returns(string memory, uint256, address){
        //check if the studentis Registered
        //require(students[msg.sender].wallet != address(0),"Student has not registred");
         if (students[msg.sender].wallet == address(0)) revert StudentNotRegistered();
         
        StudentStruct memory student = students[msg.sender];
        // Mark the student as logged in
        isLoggedIn[msg.sender] = true;
        emit studentLogin(student.FirstName, student.id, student.wallet);

        return (student.FirstName, student.id, student.wallet);
    }
    function LogOutStudent() external onlyLoggedIn returns (string memory){
        // require(isLoggedIn[msg.sender],"Student is not logged in");
        if (!isLoggedIn[msg.sender]) revert StudentMustBeLoggedIn();
        StudentStruct memory student = students[msg.sender];
        isLoggedIn[msg.sender] = false;
        emit studentLoggedOut(student.FirstName, student.id, student.wallet);
        return "Logged Out SuccessFully";
    }


    function updateProfile(
        string memory _firstname,
        string memory _lastname,
        uint256 _id,
        address payable _wallet,
        string memory _email,
        string memory _bio,
        string memory _schools
    ) external onlyLoggedIn returns (string memory){
        //require(students[msg.sender].wallet != address(0), "Student not registered.");
        if (students[msg.sender].wallet == address(0)) revert StudentNotRegistered();
        if (!isLoggedIn[msg.sender]) revert StudentMustBeLoggedIn();
        students[msg.sender].FirstName = _firstname;
        students[msg.sender].LastName = _lastname;
        students[msg.sender].id = _id;
        students[msg.sender].wallet = _wallet;
        students[msg.sender].email = _email;
        students[msg.sender].bio = _bio;
        students[msg.sender].schools = _schools;

        emit StudentProfileUpdated(msg.sender, _firstname, _id);
        return "Updated successfully";
    }
    function getStudentDetail(address _wallet) public view returns(StudentStruct memory){
        if (students[msg.sender].wallet == address(0)) revert StudentNotRegistered();
        if (!isLoggedIn[msg.sender]) revert StudentMustBeLoggedIn();
         require(_wallet == msg.sender, "Can only view own details");
        return students[_wallet];
    }


    function makePayment(
        address payable _schoolAddress,
        uint256 _amount,
        string memory _reason
    ) external onlyLoggedIn payable returns (address, uint256, string memory){
        // require(isLoggedIn[msg.sender], "Student must be logged in");
        // require(students[msg.sender].wallet != address(0), "Student not registered");
        // require(_amount > 0, "Amount must be greater than zero");
        if (students[msg.sender].wallet == address(0)) revert StudentNotRegistered();
        if (!isLoggedIn[msg.sender]) revert StudentMustBeLoggedIn();
        if (_amount <= 0) revert AmountMustBeGreaterThanZero();

        bool success = usdcToken.transferFrom(msg.sender, _schoolAddress, _amount);
        require(success,"USDC transfer failed");

        emit paymentConfirmed(msg.sender, _schoolAddress, _amount, _reason);
        emit FundsReceived(msg.sender, msg.value);
        return (_schoolAddress, _amount, _reason);
    }

      // Fallback function to receive Ether
    receive() external payable {}

     function getBalance() public view returns (uint) {
        if (students[msg.sender].wallet == address(0)) revert StudentNotRegistered();
        if (!isLoggedIn[msg.sender]) revert StudentMustBeLoggedIn();

        return address(this).balance;
       
    }
    function requestFunds() external  view  onlyLoggedIn returns (address){
        return msg.sender;
    }

    
}
