// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "@forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/FundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 SEND_VALUE = 0.1 ether;

    function setUp() public {
        // fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, 10 ether);
    }

    function testMinimunDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutMinimunETH() public {
        vm.expectRevert(); // proxima linha deve falhar
        fundMe.fund(); // correto seria: fundMe.fund{value:10e18}();
    }

    modifier funded() {
        vm.prank(USER); // todas tx agora sao feitas pelo USER
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesUserBalance() public funded {
        uint256 amountFundedByUser = address(fundMe).balance;
        assertEq(amountFundedByUser, SEND_VALUE);
    }

    function testAddFunderToFundersList() public funded {
        address user = fundMe.getFunderByIndex(0);
        assertEq(user, USER);
    }

    function testOnlyOwnerWithdraws() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawSingleFund() public funded {
        // pre
        uint256 pre_balance_owner = fundMe.getOwner().balance;
        uint256 pre_balance_fundMe = address(fundMe).balance;

        // act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // post
        uint256 post_balance_owner = fundMe.getOwner().balance;
        uint256 post_balance_fundMe = address(fundMe).balance;
        assertEq(post_balance_fundMe, 0);
        assertEq(post_balance_owner, pre_balance_fundMe + pre_balance_owner);
    }

    function testWithdrawMultipleFunders() public funded {
        // pre
        uint160 fundersLength = 10;
        uint160 fundersIndex = 1;

        for (uint160 i = fundersIndex; i < fundersLength; i++) {
            hoax(address(i), SEND_VALUE); // combinacao do vm.prank() e do vm.deal(): criar varios funders
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 pre_balance_owner = fundMe.getOwner().balance;
        uint256 pre_balance_fundMe = address(fundMe).balance;

        // act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // post
        uint256 post_balance_owner = fundMe.getOwner().balance;
        uint256 post_balance_fundMe = address(fundMe).balance;
        assertEq(post_balance_fundMe, 0);
        assertEq(post_balance_owner, pre_balance_fundMe + pre_balance_owner);
    }
}
