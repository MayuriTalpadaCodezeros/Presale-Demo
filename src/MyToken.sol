// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20,Ownable{
    constructor () 
    ERC20("My Tokens","MT") 
    Ownable(msg.sender) 
    {
        _mint(msg.sender, 100000e18);
    }

    function mint(uint256 _amount) public onlyOwner returns(uint256) {
        _mint(msg.sender, _amount);
        return _amount;
    }
}