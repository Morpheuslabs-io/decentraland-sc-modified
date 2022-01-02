// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../common/OwnPauseMeta.sol";
import "./ILANDRegistry.sol";
import "./PriceConsumerV3.sol";

contract PrimaryMarketPlace is PriceConsumerV3, OwnPauseMeta, ReentrancyGuard {
  using SafeERC20 for IERC20;

  // Receive the fund collected
  address payable public _beneficiary;

  // ERC20 token used as payment option
  IERC20 public _erc20Token;

  // ILANDRegistry contract
  ILANDRegistry public _landRegistry;

  // "decimals" is 18
  uint256 constant E18 = 10**18;

  uint256 constant LAND_CATEGORY_CHEAP = 1;
  uint256 constant LAND_CATEGORY_MEDIUM = 2;
  uint256 constant LAND_CATEGORY_EXPENSIVE = 3;
  mapping(uint256 => uint256) public _landCategoryPriceUsdCent;

  // Keep current number of minted land parcels
  uint256 public _landParcelMinted;

  // Update frequently by external background service
  uint256 public _erc20TokenPriceInUsdCent; // 300 == 3 USD (i.e. 1 ERC20 costs 3 USD)

  event EventBuyLandInERC20(
    address buyer,
    uint256 landPriceInERC20Tokens,
    uint256 landCategory,
    int256 landParcelLat,
    int256 landParcelLong
  );
  event EventBuyLandInWETH(
    address buyer,
    uint256 landPriceInWETH,
    uint256 landCategory,
    int256 landParcelLat,
    int256 landParcelLong
  );
  event EventBuyLandInFiat(
    address buyer,
    uint256 landPriceInUsdCent,
    uint256 landCategory,
    int256 landParcelLat,
    int256 landParcelLong
  );

  constructor(address erc20TokenAddress_, address beneficiary_)
    EIP712Base(DOMAIN_NAME, DOMAIN_VERSION, block.chainid)
  {
    require(
      erc20TokenAddress_ != address(0),
      "PrimaryMarketPlace: Invalid erc20TokenAddress_ address"
    );

    require(
      beneficiary_ != address(0),
      "PrimaryMarketPlace: Invalid beneficiary_ address"
    );

    _erc20Token = IERC20(erc20TokenAddress_);

    _beneficiary = payable(beneficiary_);
  }

  function setLandRegistryContractAddress(address landRegistryAddress_)
    external
    isAuthorized
  {
    require(
      landRegistryAddress_ != address(0),
      "PrimaryMarketPlace: Invalid landRegistryAddress_ address"
    );

    _landRegistry = ILANDRegistry(landRegistryAddress_);
  }

  function setLandCategoryPriceUsdCent(
    uint256 landCategory_,
    uint256 landCategoryPriceUsdCent_
  ) public isAuthorized {
    require(
      landCategoryPriceUsdCent_ > 0,
      "PrimaryMarketPlace: Invalid landCategoryPriceUsdCent_"
    );

    require(
      landCategory_ != 0 && landCategory_ != 1 && landCategory_ != 2,
      "PrimaryMarketPlace: Invalid landCategory_"
    );

    _landCategoryPriceUsdCent[landCategory_] = landCategoryPriceUsdCent_;
  }

  function setErc20TokenPriceInUsdCent(uint256 erc20TokenPriceInUsdCent_)
    public
    isAuthorized
  {
    _erc20TokenPriceInUsdCent = erc20TokenPriceInUsdCent_;
  }

  function setBeneficiary(address beneficiary_) external isAuthorized {
    require(
      beneficiary_ != address(0),
      "PrimaryMarketPlace: Invalid beneficiary_ address"
    );
    _beneficiary = payable(beneficiary_);
  }

  // Get price of ETH
  function getEthPriceInUsdCent() public view returns (uint256) {
    uint256 ethPriceInUsdCent = uint256(getCurrentPriceOfETHtoUSD()) * 100;
    return ethPriceInUsdCent;
  }

  function getLandPriceInErc20Tokens(uint256 landCategory_)
    public
    view
    returns (uint256)
  {
    require(landCategory_ > 0, "PrimaryMarketPlace: invalid landCategory_");
    require(
      _landCategoryPriceUsdCent[landCategory_] > 0,
      "PrimaryMarketPlace: land price for this category is not set"
    );

    uint256 landPriceInERC20Tokens = (_landCategoryPriceUsdCent[landCategory_] *
      E18) / _erc20TokenPriceInUsdCent;

    return landPriceInERC20Tokens;
  }

  function getLandPriceInWETH(uint256 landCategory_)
    public
    view
    returns (uint256)
  {
    require(landCategory_ > 0, "PrimaryMarketPlace: invalid landCategory_");
    require(
      _landCategoryPriceUsdCent[landCategory_] > 0,
      "PrimaryMarketPlace: land price for this category is not set"
    );

    uint256 ethPriceInUsdCent = getEthPriceInUsdCent();

    uint256 landPriceInWETH = (_landCategoryPriceUsdCent[landCategory_] * E18) /
      ethPriceInUsdCent;

    return landPriceInWETH;
  }

  // ToDo
  function getLandCategory(int256 landParcelLat_, int256 landParcelLong_)
    public
    view
    returns (uint256)
  {
    require(
      landParcelLat_ != 0 && landParcelLong_ != 0,
      "PrimaryMarketPlace: Invalid landParcelLat_ or landParcelLong_"
    );

    return _landCategoryPriceUsdCent[LAND_CATEGORY_CHEAP];
  }

  // Fiat payment is verified before calling this function with authorized wallet
  // Buy in fiat
  function buyLandInFiat(
    int256 landParcelLat_,
    int256 landParcelLong_,
    address buyer_,
    uint256 landPriceUsdCent_
  ) external whenNotPaused isAuthorized nonReentrant {
    require(
      landParcelLat_ != 0 && landParcelLong_ != 0,
      "PrimaryMarketPlace: Invalid landParcelLat_ or landParcelLong_"
    );

    uint256 landCategory = getLandCategory(landParcelLat_, landParcelLong_);

    _landRegistry.assignNewParcel(landParcelLat_, landParcelLong_, buyer_);

    emit EventBuyLandInFiat(
      buyer_,
      landPriceUsdCent_,
      landCategory,
      landParcelLat_,
      landParcelLong_
    );
  }

  // Buy in ERC20 tokens
  function buyLandInERC20(int256 landParcelLat_, int256 landParcelLong_)
    external
    whenNotPaused
    nonReentrant
  {
    require(
      _erc20TokenPriceInUsdCent > 0,
      "PrimaryMarketPlace: ERC20 token price not set"
    );

    require(
      landParcelLat_ != 0 && landParcelLong_ != 0,
      "PrimaryMarketPlace: Invalid landParcelLat_ or landParcelLong_"
    );

    uint256 landCategory = getLandCategory(landParcelLat_, landParcelLong_);
    uint256 landPriceInERC20Tokens = getLandPriceInErc20Tokens(landCategory);

    // Check if user balance has enough tokens
    require(
      landPriceInERC20Tokens <= _erc20Token.balanceOf(_msgSender()),
      "PrimaryMarketPlace: user balance does not have enough ERC20 tokens"
    );

    // Check if user has approved enough allowance
    require(
      landPriceInERC20Tokens <=
        _erc20Token.allowance(_msgSender(), address(this)),
      "PrimaryMarketPlace: user has not approved enough ERC20 tokens"
    );

    _erc20Token.safeTransferFrom(
      _msgSender(),
      _beneficiary,
      landPriceInERC20Tokens
    );

    _landRegistry.assignNewParcel(
      landParcelLat_,
      landParcelLong_,
      _msgSender()
    );

    emit EventBuyLandInERC20(
      _msgSender(),
      landPriceInERC20Tokens,
      landCategory,
      landParcelLat_,
      landParcelLong_
    );
  }

  function buyLandInWETH(int256 landParcelLat_, int256 landParcelLong_)
    external
    payable
    whenNotPaused
    nonReentrant
  {
    require(
      landParcelLat_ != 0 && landParcelLong_ != 0,
      "PrimaryMarketPlace: Invalid landParcelLat_ or landParcelLong_"
    );

    uint256 landCategory = getLandCategory(landParcelLat_, landParcelLong_);
    uint256 landPriceInWETH = getLandPriceInWETH(landCategory);

    // Check if user-transferred amount is enough
    require(
      msg.value >= landPriceInWETH,
      "PrimaryMarketPlace: user-transferred amount not enough"
    );

    // Transfer msg.value from user wallet to beneficiary
    _beneficiary.transfer(landPriceInWETH);

    _landRegistry.assignNewParcel(
      landParcelLat_,
      landParcelLong_,
      _msgSender()
    );

    emit EventBuyLandInWETH(
      _msgSender(),
      landPriceInWETH,
      landCategory,
      landParcelLat_,
      landParcelLong_
    );
  }

  function getCurrentPriceOfETHtoUSD() public view returns (int256) {
    return getThePriceEthUsd() / 10**8;
  }
}
