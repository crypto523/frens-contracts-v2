// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IStakingPool{

  function owner() external view returns (address);

  function depositToPool() external payable;

  function addToDeposit(uint _id) external payable;

  function withdraw(uint _id, uint _amount) external;

  //function distribute() external;

  //function distributeAndClaim() external;

  //function distributeAndClaimAll() external;

  function claim(uint id) external;

  function getIdsInThisPool() external view returns(uint[] memory);

  function getShare(uint _id) external view returns(uint);

  function getDistributableShare(uint _id) external view returns(uint);

  function getPubKey() external view returns(bytes memory);

  function setPubKey(
    bytes calldata pubKey,
    bytes calldata withdrawal_credentials,
    bytes calldata signature,
    bytes32 deposit_data_root
    ) external;

  function getState() external view returns(string memory);

  function getDepositAmount(uint _id) external view returns(uint);

  function stake(
    bytes calldata pubkey,
    bytes calldata withdrawal_credentials,
    bytes calldata signature,
    bytes32 deposit_data_root
  ) external;

  function stake() external;

    function exitPool() external;

}
