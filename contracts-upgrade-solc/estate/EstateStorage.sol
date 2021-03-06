// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "../minimeToken/IMinimeToken.sol";

contract LANDRegistry {
  function decodeTokenId(uint256 value) external pure returns (int256, int256);

  function updateLandData(
    int256 x,
    int256 y,
    string memory data
  ) external;

  function setUpdateOperator(uint256 assetId, address operator) external;

  function setManyUpdateOperator(uint256[] memory landIds, address operator)
    external;

  function ping() public;

  function ownerOf(uint256 tokenId) public returns (address);

  function safeTransferFrom(
    address,
    address,
    uint256
  ) public;

  function updateOperator(uint256 landId) public returns (address);
}

contract EstateStorage {
  bytes4 internal constant InterfaceId_GetMetadata =
    bytes4(keccak256("getMetadata(uint256)"));
  bytes4 internal constant InterfaceId_VerifyFingerprint =
    bytes4(keccak256("verifyFingerprint(uint256,bytes)"));

  LANDRegistry public registry;

  // From Estate to list of owned LAND ids (LANDs)
  mapping(uint256 => uint256[]) public estateLandIds;

  // From LAND id (LAND) to its owner Estate id
  mapping(uint256 => uint256) public landIdEstate;

  // From Estate id to mapping of LAND id to index on the array above (estateLandIds)
  mapping(uint256 => mapping(uint256 => uint256)) public estateLandIndex;

  // Metadata of the Estate
  mapping(uint256 => string) internal estateData;

  // Operator of the Estate
  mapping(uint256 => address) public updateOperator;

  // From account to mapping of operator to bool whether is allowed to update content or not
  mapping(address => mapping(address => bool)) public updateManager;

  // Land balance minime token
  IMiniMeToken public estateLandBalance;

  // Registered balance accounts
  mapping(address => bool) public registeredBalance;
}
