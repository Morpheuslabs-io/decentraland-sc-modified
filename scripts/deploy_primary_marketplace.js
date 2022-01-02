const PrimaryMarketPlace = artifacts.require("PrimaryMarketPlace.sol");
const execVerifyCmd = require("./publish_code");

/////// Input param ////////
let beneficiary;
let erc20TestContractAddress;
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
    } else {
      beneficiary = "0x342a9269596f0351b5067a32452d6bFBdb435265";
      erc20TestContractAddress = "0xa7F938852B789a11cf6a5c4Cdab002716A197cd5";
    }

    const primaryMarketPlaceContract = await PrimaryMarketPlace.new(
      erc20TestContractAddress,
      beneficiary
    );

    console.log(
      "PrimaryMarketPlace contract address:",
      primaryMarketPlaceContract.address
    );

    // Verify and publish to explorer
    execVerifyCmd(
      "PrimaryMarketPlace",
      primaryMarketPlaceContract.address,
      networkName
    );
  } catch (error) {
    console.log(error);
  }

  callback();

  process.exit(0);
};
