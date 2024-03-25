// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {StopOnRevertHandler} from "./Handler.t.sol";

contract OpenInvariatnsTest is StdInvariant, Test {
    DeployDSC deployer;
    DSCEngine dsc_engine;
    DecentralizedStableCoin dsc;
    HelperConfig config;
    address weth;
    address wbtc;
    StopOnRevertHandler handler;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, dsc_engine, config) = deployer.run();
        (,, weth, wbtc,) = config.activeNetworkConfig();
        // targetContract(address(dsc_engine));
        handler = new StopOnRevertHandler(dsc_engine, dsc);
        targetContract(address(handler));
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsc_engine));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsc_engine));

        uint256 wethValue = dsc_engine.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcValue = dsc_engine.getUsdValue(wbtc, totalWbtcDeposited);

        console.log("wethValue: ", wethValue);
        console.log("wbtcValue: ", wbtcValue);
        console.log("totalSupply: ", totalSupply);

        assert(wethValue + wbtcValue >= totalSupply);
    }
}
