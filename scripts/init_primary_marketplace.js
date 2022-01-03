const PrimaryMarketPlace = artifacts.require("PrimaryMarketPlace.sol");
const ILANDRegistry = artifacts.require("ILANDRegistry.sol");

//// Input params /////
const PRIMARY_MARKETPLACE_CONTRACT_ADDRESS =
  "0x778584B9Ee5b717490b5bD483cdD557695e01D53"; //"0x1Bf48CF9029373D4c01ac0F7af2d7c0Cb43615FD";

const LAND_CATEGORY = 1;
const LAND_CATEGORY_PRICE_USDCENT = 100; // 1 USD

const ERC20_TOKEN_PRICE_USDCENT = 10; // 0.1 USD

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

    tx = await primaryMarketPlaceContract.setLandCategoryPriceUsdCent(
      LAND_CATEGORY,
      LAND_CATEGORY_PRICE_USDCENT
    );

    console.log(
      `primaryMarketPlaceContract.setLandCategoryPriceUsdCent Transaction: ${tx.receipt.transactionHash}`
    );

    tx = await primaryMarketPlaceContract.setErc20TokenPriceInUsdCent(
      ERC20_TOKEN_PRICE_USDCENT
    );

    console.log(
      `primaryMarketPlaceContract.setErc20TokenPriceInUsdCent Transaction: ${tx.receipt.transactionHash}`
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
