// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {
  AggregatorV3Interface internal priceFeedEthUsd;

  int256 private ethUsdPriceFake = 2000 * 10**8; // remember to divide by 10 ** 8

  constructor() {
    if (block.chainid == 137) {
      // Matic mainnet
      priceFeedEthUsd = AggregatorV3Interface(
        0xF9680D99D6C9589e2a93a78A04A279e509205945
      );
    } else if (block.chainid == 80001) {
      // Matic testnet
      priceFeedEthUsd = AggregatorV3Interface(
        0x0715A7794a1dc8e42615F059dD6e406A6594651A
      );
    } else {
      // Unit-test and thus take it from Matic testnet
      priceFeedEthUsd = AggregatorV3Interface(
        0x0715A7794a1dc8e42615F059dD6e406A6594651A
      );
    }
  }

  function getThePriceEthUsd() public view returns (int256) {
    if (block.chainid == 137 || block.chainid == 80001) {
      (, int256 price, , , ) = priceFeedEthUsd.latestRoundData();
      return price;
    } else {
      // for unit-test
      return ethUsdPriceFake;
    }
  }
}
