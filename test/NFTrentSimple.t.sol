// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.21 <0.9.0;

import { PRBTest } from "@prb/test/PRBTest.sol";
import { console2 } from "forge-std/console2.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { NFTrent } from "../src/NFTrentSimple.sol";


contract FooTest is PRBTest, StdCheats {
    NFTrent internal nftrent;

    /// @dev A function invoked before each test case is run.
    function setUp() public virtual {
        // Instantiate the contract-under-test.
        nftrent = new NFTrent(
        "MyNFT",
        "NFT",
        "url-metadado",
        10000,
        1 ether);
    }

    function testEvery()public{
       
        // fund the donator and use that address to call functions
        vm.deal(address(1), 5 ether);
        vm.prank(address(1));
        nftrent.mint{value: 1 ether}(); 
        nftrent.balanceOf(address(1));

        vm.warp(1641080800);
        vm.prank(address(1));
        nftrent.setUser(0,address(2),1641080800 + 30 days);
        
        vm.warp(1641080800); /// coloque: + 33 days que vai dar o erro
        vm.prank(address(2));
        nftrent.useBenefiti(0);

        uint256 balanceAfter = address(2).balance;
        console2.log(balanceAfter);


    }

}