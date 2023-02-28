// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

//import "hardhat/console.sol";
import "./StakingPool.sol";
// import "./FrensBase.sol";
import "./interfaces/IStakingPoolFactory.sol";
import "./interfaces/IFrensPoolShare.sol";
import "./interfaces/IFrensArt.sol";
import "./interfaces/IFrensStorage.sol";
import "@openzeppelin/contracts/access/IAccessControl.sol";

contract StakingPoolFactory is IStakingPoolFactory{
    event Create(
        address indexed contractAddress,
        address creator,
        address owner
    );

    IFrensPoolShare frensPoolShare;
    IFrensStorage frensStorage;

    constructor(IFrensStorage frensStorage_) {
       frensStorage = frensStorage_;
       frensPoolShare = IFrensPoolShare(frensStorage.getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolShare"))));
    }

    function create(
        address _owner,
        bool _validatorLocked
    )
        public
        returns (
            //bool frensLocked, //THESE ARE NOT MAINNET READY YET
            //uint poolMin,
            //uint poolMax
            address
        )
    {
        StakingPool stakingPool = new StakingPool(
            _owner,
            _validatorLocked,
            frensStorage
        );
        // allow this stakingpool to mint shares in our NFT contract
        IAccessControl(address(frensPoolShare)).grantRole(keccak256("MINTER_ROLE"),address(stakingPool));
        emit Create(address(stakingPool), msg.sender, address(this));
        return (address(stakingPool));
    }
}
