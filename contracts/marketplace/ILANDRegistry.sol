// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ILANDRegistry {
  function authorizeDeploy(address beneficiary) external;

  // LAND can be assigned by the owner
  function assignNewParcel(
    int256 x,
    int256 y,
    address beneficiary
  ) external;

  function assignMultipleParcels(
    int256[] memory x,
    int256[] memory y,
    address beneficiary
  ) external;

  // After one year, LAND can be claimed from an inactive public key
  function ping() external;

  // LAND-centric getters
  function encodeTokenId(int256 x, int256 y) external pure returns (uint256);

  function decodeTokenId(uint256 value) external pure returns (int256, int256);

  function exists(int256 x, int256 y) external view returns (bool);

  function ownerOfLand(int256 x, int256 y) external view returns (address);

  function ownerOfLandMany(int256[] memory x, int256[] memory y)
    external
    view
    returns (address[] memory);

  function landOf(address owner)
    external
    view
    returns (int256[] memory, int256[] memory);

  function landData(int256 x, int256 y) external view returns (string memory);

  // Transfer LAND
  function transferLand(
    int256 x,
    int256 y,
    address to
  ) external;

  function transferManyLand(
    int256[] memory x,
    int256[] memory y,
    address to
  ) external;

  // Update LAND
  function updateLandData(
    int256 x,
    int256 y,
    string memory data
  ) external;

  function updateManyLandData(
    int256[] memory x,
    int256[] memory y,
    string memory data
  ) external;

  // Authorize an updateManager to manage parcel data
  function setUpdateManager(
    address _owner,
    address _operator,
    bool _approved
  ) external;

  // Events

  event Update(
    uint256 indexed assetId,
    address indexed holder,
    address indexed operator,
    string data
  );

  event UpdateOperator(uint256 indexed assetId, address indexed operator);

  event UpdateManager(
    address indexed _owner,
    address indexed _operator,
    address indexed _caller,
    bool _approved
  );

  event DeployAuthorized(address indexed _caller, address indexed _deployer);

  event DeployForbidden(address indexed _caller, address indexed _deployer);

  event SetLandBalanceToken(
    address indexed _previousLandBalance,
    address indexed _newLandBalance
  );
}
