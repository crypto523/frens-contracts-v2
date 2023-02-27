// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

//import "hardhat/console.sol";
import "./StakingPool.sol";
// import "./FrensBase.sol";
// import "./interfaces/IStakingPoolFactory.sol";

contract StakingPoolFactory {

  event Create(
    address indexed contractAddress,
    address creator,
    address owner
  );

  constructor(){
    // version = 0;
  }

  function create(
    // address owner_, 
    // bool validatorLocked// ,
    //bool frensLocked, //THESE ARE NOT MAINNET READY YET
    //uint poolMin,
    //uint poolMax
    ) public returns(address) {
    StakingPool stakingPool = new StakingPool();
    // IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
    // bool success = frensPoolSetter.create(address(stakingPool), validatorLocked);//, frensLocked, poolMin, poolMax);
    // assert(success);
    emit Create(address(stakingPool), msg.sender,address(this));
    return(address(stakingPool));
  }


}
