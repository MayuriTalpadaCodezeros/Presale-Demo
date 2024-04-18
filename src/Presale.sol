// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Presale is ReentrancyGuard{

    address payable public owner;
    address public tokenaddress ;
    uint256 public registrationfees;
    uint256 public minToken;
    uint256 public rewardamount;
    uint256 public calectedAmount;
    uint256 public goalToken;
    uint256 public goalTime;
    bool public isPresaleDone;
    bool public  presaleStart;
    
    struct InvestorData{
        uint256 amount;
        uint256 totalRewardget;
        bool isregister;
    }
    mapping (address=>InvestorData) public investorData;

    event Deposit(address account, uint256 amount);

    constructor (address _tokenaddress, uint256 _fees){
        owner = payable(msg.sender);
        tokenaddress = _tokenaddress;
        registrationfees = _fees *(10**8);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function register(uint256 _amount) public payable {
        require(msg.value == registrationfees, "Insficient fees transfer");
        require(presaleStart == true, "Presale is not start yet");
        require(isPresaleDone!= true, "Presale is Over");
        require(calectedAmount < goalToken, "Goal token reached");
        require(block.timestamp < goalTime,"Goal time reched");
        require(_amount >= minToken,"Insficient Investment");

        IERC20(tokenaddress).transferFrom(msg.sender,address(this),_amount);

        if (investorData[msg.sender].isregister == true){
            uint256 _totalrewardget= investorData[msg.sender].amount+_amount + rewardamount;
            investorData[msg.sender]= InvestorData(investorData[msg.sender].amount+_amount, _totalrewardget, true);
        }else {
            uint256 _totalrewardget= _amount + rewardamount;
            investorData[msg.sender]= InvestorData(_amount, _totalrewardget, true);
        }

        calectedAmount = calectedAmount + _amount;
    
}

    function setPresale(uint256 _rewardamount, uint256 _goalToken, uint256 _minToken, uint256 _goalTime) onlyOwner public{
        rewardamount = _rewardamount;
        goalToken = _goalToken;
        minToken = _minToken;
        goalTime = _goalTime * 1 minutes ;
        presaleStart = true;
    } 

    function closePresale() onlyOwner public payable {
        require(isPresaleDone == true,"Presale is not complited");
        
        uint value = IERC20(tokenaddress).balanceOf(address(this)) - calectedAmount;
        IERC20(tokenaddress).transfer(owner,value);
        payable(msg.sender).transfer(address(this).balance);
        isPresaleDone == true;
    }

    function withdraw() public {
        require(investorData[msg.sender].isregister == true ,"your are not invester");
        require(investorData[msg.sender].amount != 0, "Amount is 0");

        if (block.timestamp > goalTime){
            IERC20(tokenaddress).transfer(msg.sender,investorData[msg.sender].totalRewardget);
        }else {
            IERC20(tokenaddress).transfer(msg.sender,investorData[msg.sender].amount);
        }

        investorData[msg.sender].amount=0;
    }

    function removeInvestorAdd(address _to) onlyOwner public {
        investorData[_to].isregister = false;
    }

    function isWhitelisted(address _address) public view returns (bool) {
        return investorData[_address].isregister;
    }

}