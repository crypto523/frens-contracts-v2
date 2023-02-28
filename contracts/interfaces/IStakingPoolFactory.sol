pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

interface IStakingPoolFactory {

  function create(
    address owner_, 
    bool validatorLocked//,
    //bool frensLocked,
    //uint poolMin,
    //uint poolMax
   ) external returns(address);

}
