const PrimaryMarketPlace = artifacts.require("PrimaryMarketPlace.sol");
const ILANDRegistry = artifacts.require("ILANDRegistry.sol");

//// Input params /////
const PRIMARY_MARKETPLACE_CONTRACT_ADDRESS =
  "0x44517DCeC3c5839Ac5Ff4De18944E1C6f1c2ae8F"; // proxy

const LAND_REGISTRY_CONTRACT_ADDRESS =
  "0x843729bBb5bD497f03Be9073BeE98E8B01E293c0"; // proxy
//////////////////////

module.exports = async function (callback) {
  try {
    const primaryMarketPlaceContract = await PrimaryMarketPlace.at(
      PRIMARY_MARKETPLACE_CONTRACT_ADDRESS
    );

    const landRegistryContract = await ILANDRegistry.at(
      LAND_REGISTRY_CONTRACT_ADDRESS
    );

    console.log(
      "PrimaryMarketPlace contract address:",
      primaryMarketPlaceContract.address
    );

    console.log(
      "landRegistryContract contract address:",
      landRegistryContract.address
    );

    let tx = await primaryMarketPlaceContract.setLandRegistryContractAddress(
      LAND_REGISTRY_CONTRACT_ADDRESS
    );

    console.log(
      `primaryMarketPlaceContract.setLandRegistryContractAddress Transaction: ${tx.receipt.transactionHash}`
    );

    // LandRegistry needs to authorize PrimaryMarketPlace
    tx = await landRegistryContract.authorizeDeploy(
      PRIMARY_MARKETPLACE_CONTRACT_ADDRESS
    );

    console.log(
      `landRegistryContract.authorizeDeploy Transaction: ${tx.receipt.transactionHash}`
    );
  } catch (error) {
    console.log(error);
  }

  callback();

  process.exit(0);
};
