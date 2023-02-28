pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IDepositContract.sol";
import "./interfaces/IFrensPoolShare.sol";
import "./interfaces/IStakingPool.sol";
import "./interfaces/IFrensArt.sol";
import "./interfaces/IFrensOracle.sol";

contract StakingPool is IStakingPool, Ownable {
    event Stake(address depositContractAddress, address caller);
    event DepositToPool(uint amount, address depositer, uint id);

    modifier noZeroValueTxn() {
        require(msg.value > 0, "must deposit ether");
        _;
    }

    modifier maxTotDep() {
        require(
            msg.value + totalDeposits <= 32 ether,
            "total deposits cannot be more than 32 Eth"
        );
        _;
    }

    modifier mustBeAccepting() {
        require(
            currentState == PoolState.acceptingDeposits,
            "not accepting deposits"
        );
        _;
    }

    enum PoolState {
        awaitingValidatorInfo,
        acceptingDeposits,
        staked,
        exited
    }
    PoolState currentState;

    mapping(uint => uint) public depositForId;
    mapping(uint => uint) public frenPastClaim;

    uint public totalDeposits;
    uint public totalClaims;

    uint[] public idsInPool;

    bool public validatorLocked;
    bool public transferLocked;
    bool public validatorSet;

    IFrensArt public artForPool;
    //address depositContractAddress = 0x00000000219ab540356cBB839Cbe05303d7705Fa; //mainnet
    address public depositContractAddress =
        0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b; //goerli

    bytes public pubKey;
    bytes public withdrawal_credentials;
    bytes public signature;
    bytes32 public deposit_data_root;

    IFrensPoolShare frensPoolShare;
    IFrensOracle frensOracle;

    // TODO move these to settings contract
    uint feePercent = 5; //TODO: fix

    constructor(
        address owner_,
        bool validatorLocked_,
        IFrensPoolShare frensPoolShare_,
        IFrensArt _artForPool
    ) {
        artForPool = _artForPool;
        frensPoolShare = frensPoolShare_; //this hardcodes the nft contract to the pool
        validatorLocked = validatorLocked;
        if (validatorLocked_) {
            currentState = PoolState.awaitingValidatorInfo;
        } else {
            currentState = PoolState.acceptingDeposits;
        }
        _transferOwnership(owner_);
    }

    function depositToPool()
        external
        payable
        noZeroValueTxn
        maxTotDep
        mustBeAccepting
    {
        uint id = frensPoolShare.totalSupply();
        depositForId[id] = msg.value;
        totalDeposits += msg.value;
        idsInPool.push(id);
        frenPastClaim[id] = 1; //this avoids future rounding errors in rewardclaims
        frensPoolShare.mint(msg.sender); //mint nft
        emit DepositToPool(msg.value, msg.sender, id);
    }

    function addToDeposit(uint _id) external payable maxTotDep mustBeAccepting {
        require(frensPoolShare.exists(_id), "id does not exist"); //id must exist
        require(
            frensPoolShare.poolByIds(_id) == IStakingPool(this),
            "wrong staking pool for id"
        );
        depositForId[_id] += msg.value;
        totalDeposits += msg.value;
    }

    function stake(
        bytes calldata _pubKey,
        bytes calldata _withdrawal_credentials,
        bytes calldata _signature,
        bytes32 _deposit_data_root
    ) external onlyOwner {
        //if validator info has previously been entered, check that it is the same, then stake
        if (validatorSet) {
            require(keccak256(_pubKey) == keccak256(pubKey), "pubKey mismatch");
        } else {
            //if validator info has not previously been entered, enter it, then stake
            _setPubKey(
                _pubKey,
                _withdrawal_credentials,
                _signature,
                _deposit_data_root
            );
        }
        _stake();
    }

    function stake() external onlyOwner {
        _stake();
    }

    function _stake() internal {
        require(address(this).balance >= 32 ether, "not enough eth");
        require(totalDeposits == 32 ether, "not enough deposits");
        require(currentState == PoolState.acceptingDeposits, "wrong state");
        require(validatorSet, "validator not set");

        currentState = PoolState.staked;
        IDepositContract(depositContractAddress).deposit{value: 32 ether}(
            pubKey,
            withdrawal_credentials,
            signature,
            deposit_data_root
        );
        emit Stake(depositContractAddress, msg.sender);
    }

    function setPubKey(
        bytes calldata _pubKey,
        bytes calldata _withdrawal_credentials,
        bytes calldata _signature,
        bytes32 _deposit_data_root
    ) external onlyOwner {
        _setPubKey(
            _pubKey,
            _withdrawal_credentials,
            _signature,
            _deposit_data_root
        );
    }

    function _setPubKey(
        bytes calldata _pubKey,
        bytes calldata _withdrawal_credentials,
        bytes calldata _signature,
        bytes32 _deposit_data_root
    ) internal {
        //get expected withdrawal_credentials based on contract address
        bytes memory withdrawalCredFromAddr = _toWithdrawalCred(address(this));
        //compare expected withdrawal_credentials to provided
        require(
            keccak256(_withdrawal_credentials) ==
                keccak256(withdrawalCredFromAddr),
            "withdrawal credential mismatch"
        );
        if (validatorLocked) {
            require(currentState == PoolState.awaitingValidatorInfo, "wrong state");
            assert(!validatorSet); //this should never fail
            currentState = PoolState.acceptingDeposits;
        }
        require(currentState == PoolState.acceptingDeposits, "wrong state");
        pubKey = _pubKey;
        withdrawal_credentials = _withdrawal_credentials;
        signature = _signature;
        deposit_data_root = _deposit_data_root;
        validatorSet = true;
    }

    /* not ready for mainnet release?
   function arbitraryContractCall(
         address payable to,
         uint256 value,
         bytes calldata data
     ) external onlyOwner returns (bytes memory) {
       require(getBool(keccak256(abi.encodePacked("allowed.contract", to))), "contract not allowed");
       require(!getBool(keccak256(abi.encodePacked("contract.exists", to))), "cannot call FRENS contracts"); //as an extra insurance incase a contract with write privledges somehow gets whitelisted.
       (bool success, bytes memory result) = to.call{value: value}(data);
       require(success, "txn failed");
       emit ExecuteTransaction(
           msg.sender,
           to,
           value,
           data,
           result
       );
       return result;
     }
 */
    function withdraw(uint _id, uint _amount) external mustBeAccepting {
        require(msg.sender == frensPoolShare.ownerOf(_id), "not the owner");
        require(depositForId[_id] >= _amount, "not enough deposited");
        depositForId[_id] -= _amount;
        totalDeposits -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function claim(uint _id) external {
        require(
            frensPoolShare.poolByIds(_id) == IStakingPool(this),
            "wrong staking pool for id"
        );
        require(
            currentState != PoolState.acceptingDeposits,
            "use withdraw when not staked"
        );
        require(
            address(this).balance > 100,
            "must be greater than 100 wei to claim"
        );
        //has the validator exited?
        bool exited;
        if (currentState != PoolState.exited) {
            //where is frensOracle stored???
            exited = frensOracle.checkValidatorState(address(this));
        } else exited = true;
        //get share for id
        uint amount = _getShare(_id);
        //claim
        frenPastClaim[_id] += amount;
        totalClaims += amount;
        //fee? not applied to exited
        if (feePercent > 0 && !exited) {
            address feeRecipient = 0xa53A6fE2d8Ad977aD926C485343Ba39f32D3A3F6;
            uint feeAmount = (feePercent * amount) / 100;
            if (feeAmount > 1) payable(feeRecipient).transfer(feeAmount - 1); //-1 wei to avoid rounding error issues
            amount = amount - feeAmount;
        }
        payable(frensPoolShare.ownerOf(_id)).transfer(amount);
    }

    function exitPool() external {
        require(msg.sender == address(frensOracle), "must be called by oracle");
        currentState = PoolState.exited;
    }

    /* not ready for mainnet release
  function rageQuit(uint id, uint price) public {
    require(msg.sender == frensPoolShare.ownerOf(id), "not the owner");
    uint deposit = getUint(keccak256(abi.encodePacked("deposit.amount", address(this), id)));
    require(price <= deposit, "cannot set price higher than deposit");
    frensPoolShare.
    IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
    bool success = frensPoolSetter.rageQuit(id, price);
    assert(success);
    
  }
  //TODO:needs a purchase function for ragequit
  function unlockTransfer(uint id) public {
    uint time = getUint(keccak256(abi.encodePacked("rage.time", id))) + 1 weeks;
    require(time >= block.timestamp);
    IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
    bool success = frensPoolSetter.unlockTransfer(id);
    assert(success);
  }

  function burn(uint tokenId) public { //this is only here to test the burn method in frensPoolShare
    address tokenOwner = frensPoolShare.ownerOf(tokenId);
    require(msg.sender == tokenOwner);
    frensPoolShare.burn(tokenId);
  }
*/
    //getters

    //   function getIdsInThisPool() public view returns(uint[] memory) {
    //     return getArray(keccak256(abi.encodePacked("ids.in.pool", address(this))));
    //   }

    function getShare(uint _id) public view returns (uint) {
        require(
            frensPoolShare.poolByIds(_id) == IStakingPool(this),
            "wrong staking pool for id"
        );
        return _getShare(_id);
    }

    function _getShare(uint _id) internal view returns (uint) {
        if (address(this).balance == 0) return 0;
        uint frenDep = depositForId[_id];
        uint frenPastClaims = frenPastClaim[_id];
        uint totFrenRewards = ((frenDep *
            (address(this).balance + totalClaims)) / totalDeposits);
        if (totFrenRewards == 0) return 0;
        uint amount = totFrenRewards - frenPastClaims;
        return amount;
    }

    function getDistributableShare(uint _id) public view returns (uint) {
        if (currentState == PoolState.acceptingDeposits) {
            return 0;
        } else {
            uint share = _getShare(_id);
            if (feePercent > 0 && currentState != PoolState.exited) {
                uint feeAmount = (feePercent * address(this).balance) / 100;
                share = share - feeAmount;
            }
            return share;
        }
    }

    //   function getPubKey() public view returns(bytes memory){
    //     return getBytes(keccak256(abi.encodePacked("pubKey", address(this))));
    //   }

    function getState() public view returns (string memory) {
        if (currentState == PoolState.awaitingValidatorInfo)
            return "awaiting validator info";
        if (currentState == PoolState.staked) return "staked";
        if (currentState == PoolState.acceptingDeposits)
            return "accepting deposits";
        if (currentState == PoolState.exited) return "exited";
        return "state failure"; //should never happen
    }

    //   function getDepositAmount(uint _id) public view returns(uint){
    //     require(getAddress(keccak256(abi.encodePacked("pool.for.id", _id))) == address(this), "wrong staking pool");
    //     return getUint(keccak256(abi.encodePacked("deposit.amount", address(this), _id)));
    //   }

    //   function getTotalDeposits() public view returns(uint){
    //     return getUint(keccak256(abi.encodePacked("total.deposits", address(this))));
    //   }

    function owner()
        public
        view
        override(IStakingPool, Ownable)
        returns (address)
    {
        return super.owner();
    }

    function _toWithdrawalCred(address a) private pure returns (bytes memory) {
        uint uintFromAddress = uint256(uint160(a));
        bytes memory withdralDesired = abi.encodePacked(
            uintFromAddress +
                0x0100000000000000000000000000000000000000000000000000000000000000
        );
        return withdralDesired;
    }

    //   //setters

    // TODO: add access control
    function setOracle(IFrensOracle _oracle) external {
        frensOracle = _oracle;
    }

    function setArt(IFrensArt newArtContract) external onlyOwner {
        IFrensArt newFrensArt = newArtContract;
        string memory newArt = newFrensArt.renderTokenById(1);
        require(bytes(newArt).length != 0, "invalid art contract");
        artForPool = newArtContract;
    }

    // to support receiving ETH by default
    receive() external payable {}

    fallback() external payable {}
}
