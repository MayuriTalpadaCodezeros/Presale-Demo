// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {MyToken} from "src/MyToken.sol";

contract MyTokenScript is Script {
    function setUp() public{}

    function run() public {
        uint256 privatekey = vm.envUint("PRIVATE_KEY");
        address add = vm.addr(privatekey);
        console.log("Account--->",add);
        vm.startBroadcast(privatekey);
        MyToken mytoken = new MyToken();
        console.log("MyToken--->",address(mytoken));
        vm.stopBroadcast();
        // vm.broadcast();
        // new MyToken();
    }
}