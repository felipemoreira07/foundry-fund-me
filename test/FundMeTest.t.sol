// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "@forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/FundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() public {
        // fundMe = new FundMe();
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimunDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testSepoliaPriceFeed() public view {
        address price = fundMe.price();
        assertEq(price, 0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }
}
