// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

//import "hardhat/console.sol";
import "./StakingPool.sol";
// import "./FrensBase.sol";
import "./interfaces/IStakingPoolFactory.sol";
import "./interfaces/IFrensPoolShare.sol";

contract StakingPoolFactory is IStakingPoolFactory {

  event Create(
    address indexed contractAddress,
    address creator,
    address owner
  );

  IFrensPoolShare frensPoolShare;

  constructor(IFrensPoolShare frensPoolShare_){
    frensPoolShare = frensPoolShare_;
    // version = 0;
  }

  function create(
    address owner_, 
    bool validatorLocked// ,
    //bool frensLocked, //THESE ARE NOT MAINNET READY YET
    //uint poolMin,
    //uint poolMax
    ) public returns(address) {
    StakingPool stakingPool = new StakingPool(owner_, validatorLocked, frensPoolShare);
    emit Create(address(stakingPool), msg.sender,address(this));
    return(address(stakingPool));
  }



}
