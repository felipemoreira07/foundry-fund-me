// SPDX-License_identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "@forge-std/src/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // antes do vm.startBroadcast(), sem custo, nao e uma transacao real
        HelperConfig helperConfig = new HelperConfig();
        (address priceFeed, ) = helperConfig.activeNetworkConfig();

        // depois do vm.startBroadcast(), com custo, uma transacao real
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
