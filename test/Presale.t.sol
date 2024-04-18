// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Presale} from "src/Presale.sol";
import {MyToken} from "src/MyToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PresaleTest is Test {
    Presale public presale;
    MyToken public mytoken;
    
    function setUp () public{
        mytoken = new MyToken();
        presale = new Presale(address(mytoken),2);
    }

    // Receive ETH from wallet
    receive() external payable {}

    // // Check how much ETH available for test
    // function testLogBalance() public {
    //     console.log("ETH balance", address(presale).balance / 1e18);
    // }

    // function testFailWithdrawNotOwner() public {
    //     vm.prank(address(1));
    //     wallet.withdraw(1);
    // }

    // function _send() private {
    //     (bool ok,)= address(presale);
    //     require(ok, "Failed to send Ether");
    // }

    function testPresaleTokenAddress_1() view public {
        // presale.tokenaddress();
        assertEq(address(mytoken),presale.tokenaddress(),"Address 1");
    }

    function testFailPresaleTokenAddress_0() view public {
        assertEq(address(0x0),presale.tokenaddress(),"Address 0");
    }

    function testregistrationfees() view public {
        uint value = 2e18;
        console.log(presale.registrationfees());
        assertEq(value,presale.registrationfees(),"registration fees");
    }

    function testregistrationfees_0() view public {
        uint value = 0;
        assertNotEq(value,presale.registrationfees(),"registration fees");
    }


    function testStartPresaleSuccess() public {
        // Set the sender as the owner
        vm.startPrank(address(presale.owner()));
        presale.setPresale(20, 200, 5, 50);
        assertTrue(presale.presaleStart(), "Presale should be started");    
    }

    function testFailSetPresaleFail() public {
        vm.prank(address(0x3));
        presale.setPresale(100, 100, 10, 50);
    }

    function testFailSetPresaleArgRToken() public {
        vm.prank(address(presale.owner()));
        presale.setPresale(0, 100, 10, 50);
        assertGt(presale.rewardamount(),0,"Reward Token should be more than 0");
    }

    function testFailSetPresaleArgGToken() public {
        vm.prank(address(presale.owner()));
        presale.setPresale(1000, 0, 10, 50);
        assertGt(presale.goalToken(),0,"Goal Token should be more than 0");
    }

    function testSetPresaleArgGTime() public {
        vm.prank(address(presale.owner()));
        presale.setPresale(1000, 100, 0, 50);
        assertGt(presale.goalTime(),0 minutes,"Goal time should be more than 0");
    }

    function testInsufficientFees() public {
        vm.expectRevert("Insficient fees transfer");
        uint fees = 2 ether;
        presale.register{value:fees - 1}(1);
    }

    function testFailPresaleNotStarted() public {
        bool status = presale.presaleStart();
        assertNotEq(status, false,"Presale is not started yet!");
        uint fees = 2 ether;
        presale.register{value:fees}(1);
    }

    function testPresaleIsNotDone() public {
        vm.prank(address(presale.owner()));
        presale.setPresale(10, 200, 10, 50);
        vm.prank(address(0x1));
        bool status = presale.isPresaleDone();
        assertNotEq(status, true,"Presale is Complited!");
        mytoken.approve(address(presale),10);
        uint fees = 2 ether;
        presale.register{value:fees}(10);
    }

    function testFailPresaleIsDone() public {
        vm.prank(address(presale.owner()));
        presale.setPresale(10, 200, 10, 50);
        vm.prank(address(0x1));
        bool status = presale.isPresaleDone();
        assertNotEq(status, false,"Presale is Complited!");
        mytoken.approve(address(presale),10);
        uint fees = 2 ether;
        presale.register{value:fees}(10);
    }

    function testRegister() public {
        vm.prank(address(presale.owner()));
        presale.setPresale(10, 200 , 1, 50);
        vm.prank(address(0x1));
        bool status = presale.isPresaleDone();
        assertNotEq(status, true,"Presale is Complited!");
        mytoken.approve(address(presale),100e18);
        uint fees = 2 ether;
        presale.register{value: fees }(30);
        
        // console.log(presale.userdata[0x1].isregister);
        // assertEq(presale.userdata(address(0x1)),1,"Registration should be 1");
    }

    function testTokenGoalreched() public{
        vm.prank(address(presale.owner()));
        presale.setPresale(10, 200 , 1, 50);
        vm.prank(address(0x1));
        assertLe(presale.calectedAmount(),presale.goalToken(),"Presale reched to Goal Token");
    }

    function testTimeGoalreched() public {
        vm.prank(address(presale.owner()));
        presale.setPresale(10, 200 , 1, 50);
        vm.prank(address(0x1));
        assertLe(block.timestamp,presale.goalTime(),"Presale time is over");
    }

    function testFailClosePresale() public payable{
        vm.prank(address(presale.owner()));
        presale.setPresale(10, 200, 1, 50);
        vm.prank(address(0x1));
        bool status = presale.isPresaleDone();
        console.log (status);
        assertEq(status, true,"Presale is Complited!");
        mytoken.approve(address(presale),100e18);
        uint fees = 2 ether;
        presale.register{value: fees }(30);

        vm.prank(address(presale.owner()));
        console.log("before------>",address(presale.owner()).balance);

        presale.closePresale();

        console.log("after------>",address(presale.owner()).balance);
    }

    function testWithdraw() public {
        vm.prank(address(presale.owner()));
        presale.setPresale(10, 200, 1, 50);
        vm.prank(address(0x1)); 
        bool status = presale.isPresaleDone();
        assertNotEq(status, true,"Presale is Complited!");
        mytoken.approve(address(presale),100e18);
        uint fees = 2 ether;
        presale.register{value: fees }(30);   
        presale.withdraw();
    }
    
}