// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {Presale} from "src/Presale.sol";

contract PresaleScript is Script {
    function setUp() public{}

    function run() public {
        vm.broadcast();
        new Presale(0xcdc9fCa818b36578D3402F31a751EEE383636E0d,2);
    }
}