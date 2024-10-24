// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import "/home/fadhil/Projects/edupay_contracts/lib/forge-std/src/Script.sol";
import "/home/fadhil/Projects/edupay_contracts/src/SchoolFactory.sol";

contract DeploySchoolFactory is Script {
    function run() external {
        // Start broadcasting the transaction
        vm.startBroadcast();

        // Deploy the SchoolFactory contract
        SchoolFactory schoolFactory = new SchoolFactory();

        // Log the address of the deployed contract
        console.log("SchoolFactory deployed at:", address(schoolFactory));

        // Stop broadcasting the transaction
        vm.stopBroadcast();
    }
}
