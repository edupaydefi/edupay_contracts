// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// Smart contract for managing school contractors and their contracts
contract SchoolContractors {

    // Enum to represent the different statuses of a contractor's contract
    enum ContractStatus {
        Pending,    // Contract is yet to be approved
        Approved,   // Contract has been approved
        Paid        // Contractor has been paid for the contract
    }

    // Struct to hold details for each contractor
    struct Contractor {
        string name;                       // Contractor's name
        uint256 contractorID;              // Unique ID for the contractor
        address payable contractorAddress; // Contractor's wallet address (payable)
        string description;                // Description of the contract
        uint256 price;                     // Amount agreed upon for the contract
        uint256 startContract;             // Start date of the contract (timestamp)
        uint256 endContract;               // End date of the contract (timestamp)
        ContractStatus status;             // Status of the contract (Pending, Approved, Paid)
    }

    // Counter to keep track of the total number of contractors
    uint256 public contractorsCount;

    // Mapping to store contractor data, where the key is the contractor's ID
    mapping(uint256 => Contractor) public contractorsData;

    // Event to log when a new contract is added
    event ContractAdded(
        string name,
        uint256 contractorID,
        string description,
        uint256 price,
        uint256 startContract,
        uint256 endContract,
        address payable contractorAddress,
        ContractStatus status
    );

    // Event to log when an existing contractor's details are updated
    event ContractorUpdated(
        uint256 contractorID,
        string name,
        string description,
        uint256 price,
        uint256 startContract,
        uint256 endContract,
        ContractStatus status
    );

    // Function to add a new contractor and store their contract details
    function addContractor(
        string memory _name,
        uint256 _contractorID,
        string memory _description,
        uint256 _price,
        uint256 _startContract,
        uint256 _endContract,
        address payable _contractorAddress,
        ContractStatus _status
    ) public returns (string memory) {
        // Check that the contractor ID is unique (i.e., contractor not already registered)
        require(contractorsData[_contractorID].contractorID != _contractorID, "The contractor has already been registered");

        // Validate start and end contract dates
        require(_isValidTimestamp(_startContract), "Invalid start date.");
        require(_isValidTimestamp(_endContract), "Invalid end date.");
        require(_startContract < _endContract, "Start date must be before the end date.");

        // Create a new contractor object with the provided details
        Contractor memory newContractor = Contractor({
            name: _name,
            contractorID: _contractorID,
            contractorAddress: _contractorAddress,
            description: _description,
            price: _price,
            startContract: _startContract,
            endContract: _endContract,
            status: _status
        });

        // Store the new contractor's details in the mapping
        contractorsData[_contractorID] = newContractor;
        contractorsCount++; // Increment the contractor count

        // Emit the ContractAdded event with relevant details
        emit ContractAdded(
            _name,
            _contractorID,
            _description,
            _price,
            _startContract,
            _endContract,
            _contractorAddress,
            _status
        );

        // Return a success message
        return string(abi.encodePacked("The contractor with the ID of ", _contractorID, " has been successfully added."));
    }

    // Function to update an existing contractor's details
    function updateContractor(
        uint256 _contractorID,
        string memory _name,
        string memory _description,
        uint256 _price,
        uint256 _startContract,
        uint256 _endContract,
        ContractStatus _status
    ) public returns (string memory) {
        // Ensure that the contractor exists by checking their ID
        require(contractorsData[_contractorID].contractorID != 0, "Contractor does not exist");

        // Validate start and end dates for the contract
        require(_isValidTimestamp(_startContract), "Invalid start date.");
        require(_isValidTimestamp(_endContract), "Invalid end date.");
        require(_startContract < _endContract, "Start date must be before the end date.");

        // Retrieve the contractor details from the mapping and update them
        Contractor storage contractor = contractorsData[_contractorID];
        contractor.name = _name;
        contractor.description = _description;
        contractor.price = _price;
        contractor.startContract = _startContract;
        contractor.endContract = _endContract;
        contractor.status = _status;

        // Emit the ContractorUpdated event with the updated details
        emit ContractorUpdated(
            _contractorID,
            _name,
            _description,
            _price,
            _startContract,
            _endContract,
            _status
        );

        // Return a success message
        return "Contractor details updated successfully.";
    }

    // Function to retrieve details of a contractor by their ID
    function getContractor(uint256 _id) public view returns (uint256, string memory, address, string memory, ContractStatus) {
        // Ensure that the contractor exists by checking their ID
        require(contractorsData[_id].contractorID != 0, "The id does not exist");

        // Retrieve the contractor details
        Contractor storage contractor = contractorsData[_id];

        // Return the relevant contractor information
        return (
            contractor.contractorID,
            contractor.name,
            contractor.contractorAddress,
            contractor.description,
            contractor.status
        );
    }

    // Function to delete a contractor by their ID
    function deleteContractor(uint256 _id) public returns (string memory) {
        // Ensure that the contractor exists by checking their ID
        require(contractorsData[_id].contractorID != 0, "The id is not found");

        // Remove the contractor from the mapping
        delete contractorsData[_id];
        contractorsCount--; // Decrement the contractor count

        // Return a success message
        return "Deleted";
    }

    // Internal function to validate a timestamp (it must be in the future)
    function _isValidTimestamp(uint256 timestamp) internal view returns (bool) {
        return (timestamp > block.timestamp); // Ensure the provided timestamp is greater than the current time
    }
}
