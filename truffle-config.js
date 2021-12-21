require("babel-register");
require("@babel/polyfill");

const HDWalletProvider = require("@truffle/hdwallet-provider");

const fs = require("fs");
const path = require("path");

module.exports = {
  contracts_directory: "contracts",
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*",
    },
    ropsten: {
      provider: () => {
        const privatekey = fs
          .readFileSync(`${path.dirname(__filename)}/.secret.ropsten`)
          .toString();
        return new HDWalletProvider(
          privatekey,
          // "https://ropsten.infura.io/v3/34b8cb070feb45619332c8867301bdaa"
          // "wss://ropsten.infura.io/ws/v3/34b8cb070feb45619332c8867301bdaa"
          // "https://eth-ropsten.alchemyapi.io/v2/uPrNsttftKyrZIputd80GsfzXar-NAL3"
          "wss://eth-ropsten.alchemyapi.io/v2/uPrNsttftKyrZIputd80GsfzXar-NAL3"
        );
      },
      network_id: 3,
      confirmations: 3,
      websocket: true,
      timeoutBlocks: 50000,
      networkCheckTimeout: 1000000,
      skipDryRun: true,
      gas: 2000000,
      gasPrice: 2000000000, // 2 Gwei
    },
    ethmainnet: {
      provider: () => {
        const privatekey = fs
          .readFileSync(`${path.dirname(__filename)}/.secret.ethmainnet`)
          .toString();
        return new HDWalletProvider(
          privatekey,
          // "https://mainnet.infura.io/v3/34b8cb070feb45619332c8867301bdaa"
          // "wss://mainnet.infura.io/ws/v3/34b8cb070feb45619332c8867301bdaa"
          // "https://eth-mainnet.alchemyapi.io/v2/ccd5do8Kqn7QHjkrx74pwwlgzo10Rtvh"
          "wss://eth-mainnet.alchemyapi.io/v2/ccd5do8Kqn7QHjkrx74pwwlgzo10Rtvh"
        );
      },
      network_id: 1,
      confirmations: 3,
      websocket: true,
      timeoutBlocks: 50000,
      networkCheckTimeout: 1000000,
      skipDryRun: true,
      gas: 2000000,
    },
    matictestnet: {
      provider: () => {
        const privatekey = fs
          .readFileSync(`${path.dirname(__filename)}/.secret.matictestnet`)
          .toString();
        return new HDWalletProvider(
          privatekey,
          "https://rpc-mumbai.maticvigil.com/"
        );
      },
      network_id: 80001,
      confirmations: 2,
      timeoutBlocks: 50000,
      networkCheckTimeout: 1000000,
      skipDryRun: true,
      gas: 2000000,
      gasPrice: 5000000000, // 5 Gwei
    },
    maticmainnet: {
      provider: () => {
        const privatekey = fs
          .readFileSync(`${path.dirname(__filename)}/.secret.maticmainnet`)
          .toString();
        return new HDWalletProvider(
          privatekey,
          "https://rpc-mainnet.maticvigil.com/"
        );
      },
      network_id: 137,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true,
      gas: 2000000,
      gasPrice: 50000000000, // 50 Gwei
    },
  },
  compilers: {
    solc: {
      version: "0.8.9",
      parser: "solcjs",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200,
        },
      },
    },
  },
  plugins: ["truffle-plugin-verify"],
  api_keys: {
    etherscan: "EP56J7CJ36124YRGZ7S9XSKB5SE3VVRPD1",
  },
};
