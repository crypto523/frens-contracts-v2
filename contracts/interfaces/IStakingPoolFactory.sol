pragma solidity 0.8.20;
//SPDX-License-Identifier: MIT

import "./IFrensArt.sol";

interface IStakingPoolFactory {

  function create(
    address _owner, 
    bool _validatorLocked 
    //bool frensLocked,
    //uint poolMin,
    //uint poolMax
   ) external returns(address);

}
