// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.21 <0.9.0;

import { NFTrent } from "../src/NFTrentSimple.sol";

import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract Deploy is BaseScript {
    function run() public broadcast returns (NFTrent nftrent) {
       nftrent = new NFTrent(
        "MyNFT",
        "NFT",
        "url-metadado",
        10000,
        1 ether);
    }
}
