// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

//import "hardhat/console.sol";
import "./StakingPool.sol";
// import "./FrensBase.sol";
import "./interfaces/IStakingPoolFactory.sol";
import "./interfaces/IFrensPoolShare.sol";
import "./interfaces/IFrensArt.sol";

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
    address _owner, 
    bool _validatorLocked,
    IFrensArt _frensArt
    //bool frensLocked, //THESE ARE NOT MAINNET READY YET
    //uint poolMin,
    //uint poolMax
    ) public returns(address) {
    StakingPool stakingPool = new StakingPool(
      _owner, 
      _validatorLocked, 
      frensPoolShare,
      _frensArt
      );
    emit Create(address(stakingPool), msg.sender,address(this));
    return(address(stakingPool));
  }



}
