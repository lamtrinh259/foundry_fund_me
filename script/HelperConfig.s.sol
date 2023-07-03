// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we're on a local anvil chain
// 2. Keep track of contract address across different chains: Sepolia ETH/USD, Mainnet ETH/USD

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

pragma solidity ^0.8.18;

contract HelperConfig is Script {
    // If we're on a local anvil chain, we'll deploy mocks
    // Otherwise, grab the existing address from the live network
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 1900e8;

    struct NetworkConfig {
        address priceFeed;
    }
    NetworkConfig public activeNetworkConfig;

    // address private immutable s_activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    // function activeNetworkConfig() external view returns (address) {
    //     return s_activeNetworkConfig;
    // }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // 1. Deploy the mocks
        // 2. Return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
