// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import "src/cdf_reference.sol";
import {Gaussian} from "solstat/Gaussian.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface IHuffCDF {
    function cdf(int256 x, int256 mean, int256 deviation) external pure returns (int256);
}

contract CounterTest is Test {
    CDF private cdf;
    IHuffCDF private huffCdf;

    function setUp() external {
        cdf = new CDF();
        huffCdf = IHuffCDF(HuffDeployer.deploy("HuffCDF"));
    }

    function testFuzz_cdf(int256 x) external view {
        x = bound(x, -6.26 ether, 6.26 ether);

        int256 goal = Gaussian.cdf(x);
        //int256 val = cdf._erfc(x);
        int256 val = huffCdf.cdf(x, 0, 1e18);
        console.log(goal);
        console.log(val);

        int256 max = goal > val ? goal : val;
        int256 min = goal > val ? val : goal;

        assertLe(max - min, 1e10); // 10**-8 * 10**18 = 10**10
    }

    function testGas() external view {
        uint256 gc = 0;
        uint256 gas_left;
        int256 prec = 1e16;
        
        // Solstat
        for(int i = -7 ether; i <= 7 ether; i += prec) {
            gas_left = gasleft();
            Gaussian.cdf(i);
            gc = gc + (gas_left-gasleft());
        }
        uint256 avg_solstat = gc / uint256(14 ether / prec + 1);
        
        gc = 0;

        // This
        for(int i = -7 ether; i <= 7 ether; i += prec) {
            gas_left = gasleft();
            huffCdf.cdf(i, 0, 1e18);
            gc = gc + (gas_left-gasleft());
        }
        uint256 avg_this = gc / uint256(14 ether / prec + 1);

        console.log("Average Solstat gas for x in [-7e18, 7e18]:");
        console.log(avg_solstat);
        console.log("Average HuffCdf gas for the same x (including STATICCALL preparation, usage and data verification):");
        console.log(avg_this);
	console.log("Actually the runtime gas used is *~321 units*, which can be verified using foundry debugger");
    }

    function test_CDFArbitraryParameters() external view {
	int256 goal = 736742020000000000;
        int256 val = huffCdf.cdf(2e18, 0.1e18, 3e18);

	int256 max = goal > val ? goal : val;
        int256 min = goal > val ? val : goal;

        assertLe(max - min, 1e10); // 10**-8 * 10**18 = 10**10
    }
}
