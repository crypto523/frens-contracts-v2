pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "./interfaces/IStakingPool.sol";
import "./interfaces/IFrensOracle.sol";
import "./interfaces/IFrensStorage.sol";

contract FrensOracle is IFrensOracle {

    mapping(bytes => bool) public isExiting;

    IFrensStorage frensStorage;

    constructor(IFrensStorage frensStorage_) {
        frensStorage = frensStorage_;
    }

    function checkValidatorState(address poolAddress) external returns(bool) {
        IStakingPool pool = IStakingPool(poolAddress);
        bytes memory pubKey = pool.pubKey();
        if(isExiting[pubKey]){
            pool.exitPool();
        }
        return isExiting[pubKey];
    }

   function setExiting(bytes memory pubKey, bool _isExiting) external {
        require(msg.sender == frensStorage.getGuardian(), "must be guardian");
        isExiting[pubKey] = _isExiting;
   }
    
}