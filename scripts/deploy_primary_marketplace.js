const PrimaryMarketPlace = artifacts.require("PrimaryMarketPlace.sol");
const execVerifyCmd = require("./publish_code");

/////// Input param ////////
let beneficiary;
let erc20TestContractAddress;
let wethAddress;
////////////////////////////

const networkIdName = {
  137: "maticmainnet",
  80001: "matictestnet",
};

module.exports = async function (callback) {
  try {
    const networkId = await web3.eth.net.getId();
    const networkName = networkIdName[networkId];

    console.log("networkName:", networkName);

    if (networkName === "maticmainnet") {
      beneficiary = "";
      erc20TestContractAddress = "";
      wethAddress = "0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619";
    } else {
      beneficiary = "0x342a9269596f0351b5067a32452d6bFBdb435265";
      erc20TestContractAddress = "0xa7F938852B789a11cf6a5c4Cdab002716A197cd5";
      wethAddress = "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa";
    }

    const primaryMarketPlaceContract = await PrimaryMarketPlace.new(
      beneficiary,
      wethAddress,
      erc20TestContractAddress
    );

    console.log(
      "PrimaryMarketPlace contract address:",
      primaryMarketPlaceContract.address
    );

    // Verify and publish to explorer
    // execVerifyCmd(
    //   "PrimaryMarketPlace",
    //   primaryMarketPlaceContract.address,
    //   networkName
    // );
  } catch (error) {
    console.log(error);
  }

  callback();

  process.exit(0);
};
