pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

//import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC721Enumerable.sol";
import "./interfaces/IDepositContract.sol";
import "./interfaces/IFrensPoolShare.sol";
import "./interfaces/IStakingPool.sol";
import "./interfaces/IFrensClaim.sol";
import "./interfaces/IFrensArt.sol";
import "./interfaces/IFrensPoolSetter.sol";
import "./FrensBase.sol";


//should ownable be replaces with an equivalent in storage/base?
contract StakingPool is IStakingPool, Ownable, FrensBase {

  event Stake(address depositContractAddress, address caller);
  event DepositToPool(uint amount, address depositer);
  event ExecuteTransaction(
            address sender,
            address to,
            uint value,
            bytes data,
            bytes result
        );

  enum State { awaitingValidatorInfo, acceptingDeposits, staked, exited }
  State currentState;

  IFrensPoolShare frensPoolShare;

  constructor(address owner_, bool validatorLocked_, IFrensStorage frensStorage_) FrensBase(frensStorage_){
    address frensPoolShareAddress = getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolShare")));
    frensPoolShare = IFrensPoolShare(frensPoolShareAddress); //this hardcodes the nft contract to the pool
    if(validatorLocked_){
      currentState = State.awaitingValidatorInfo;
    } else {
      currentState = State.acceptingDeposits;
    }
    _transferOwnership(owner_);
    version = 2;
  }

  function depositToPool() external payable {
    require(currentState == State.acceptingDeposits, "not accepting deposits"); //state must be "aceptingDeposits"
    require(msg.value != 0, "must deposit ether"); //cannot generate 0 value nft
    require(getUint(keccak256(abi.encodePacked("total.deposits", address(this)))) + msg.value <= 32 ether, "total deposits cannot be more than 32 Eth"); //limit deposits to 32 eth
    IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
    bool success = frensPoolSetter.depositToPool(msg.value);
    assert(success);
    frensPoolShare.mint(msg.sender); //mint nft
    emit DepositToPool(msg.value,  msg.sender); 
  }

  function addToDeposit(uint _id) external payable {
    require(frensPoolShare.exists(_id), "id does not exist"); //id must exist
    require(getAddress(keccak256(abi.encodePacked("pool.for.id", _id))) == address(this), "wrong staking pool"); //id must be associated with this pool
    require(currentState == State.acceptingDeposits, "not accepting deposits"); //pool must be "acceptingDeposits"
    require(getUint(keccak256(abi.encodePacked("total.deposits", address(this)))) + msg.value <= 32 ether, "total deposits cannot be more than 32 Eth"); //limit deposits to 32 eth
    IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
    bool success = frensPoolSetter.addToDeposit(_id, msg.value);
    assert(success);
  }

  function stake(
    bytes calldata pubKey,
    bytes calldata withdrawal_credentials,
    bytes calldata signature,
    bytes32 deposit_data_root
  ) external onlyOwner{
    //if validator info has previously been entered, check that it is the same, then stake
    if(getBool(keccak256(abi.encodePacked("validator.set", address(this))))){
      bytes memory pubKeyFromStorage = getBytes(keccak256(abi.encodePacked("pubKey", address(this)))); 
      require(keccak256(pubKeyFromStorage) == keccak256(pubKey), "pubKey mismatch");
    }else { //if validator info has not previously been enteren, enter it, then stake
      setPubKey(
        pubKey,
        withdrawal_credentials,
        signature,
        deposit_data_root
      );
    }
    stake();
  }

  function stake() public {
    require(address(this).balance >= 32 ether, "not enough eth"); 
    require(currentState == State.acceptingDeposits, "wrong state");
    require(getBool(keccak256(abi.encodePacked("validator.set", address(this)))), "validator not set");
    uint value = 32 ether;
    bytes memory pubKey = getBytes(keccak256(abi.encodePacked("pubKey", address(this))));
    bytes memory withdrawal_credentials = getBytes(keccak256(abi.encodePacked("withdrawal_credentials", address(this))));
    bytes memory signature = getBytes(keccak256(abi.encodePacked("signature", address(this))));
    bytes32 deposit_data_root = getBytes32(keccak256(abi.encodePacked("deposit_data_root", address(this))));
    address depositContractAddress = getAddress(keccak256(abi.encodePacked("external.contract.address", "DepositContract")));
    currentState = State.staked;
    IDepositContract(depositContractAddress).deposit{value: value}(pubKey, withdrawal_credentials, signature, deposit_data_root);
    emit Stake(depositContractAddress, msg.sender);
  }

  function setPubKey(
    bytes calldata pubKey,
    bytes calldata withdrawal_credentials,
    bytes calldata signature,
    bytes32 deposit_data_root
  ) public{
    //get expected withdrawal_credentials based on contract address
    bytes memory withdrawalCredFromAddr = _toWithdrawalCred(address(this));
    //compare expected withdrawal_credentials to provided
    require(keccak256(withdrawal_credentials) == keccak256(withdrawalCredFromAddr), "withdrawal credential mismatch");
    if(getBool(keccak256(abi.encodePacked("validator.locked", address(this))))){
      require(currentState == State.awaitingValidatorInfo, "wrong state");
      assert(!getBool(keccak256(abi.encodePacked("validator.set", address(this))))); //this should never fail
      currentState = State.acceptingDeposits;
    }
    require(currentState == State.acceptingDeposits, "wrong state");
    IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
    bool success = frensPoolSetter.setPubKey(pubKey, withdrawal_credentials, signature, deposit_data_root);
    assert(success);
  }

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

  function withdraw(uint _id, uint _amount) external {
    require(currentState == State.acceptingDeposits, "cannot withdraw once staked");//TODO: this may need to be more restrictive
    require(msg.sender == frensPoolShare.ownerOf(_id), "not the owner");
    require(getUint(keccak256(abi.encodePacked("deposit.amount", _id))) >= _amount, "not enough deposited");
    IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
    bool success = frensPoolSetter.withdraw(_id, _amount);
    assert(success);
    payable(msg.sender).transfer(_amount);
  }

  //TODO: think about other options for distribution
  //TODO: should this include an option to swap for SSV and pay operators?
  //TODO: is this where we extract fes?
  function distribute() public {
    require(currentState != State.acceptingDeposits, "use withdraw when not staked");
    _distribute();
      }

  function _distribute() internal {
    uint contractBalance = address(this).balance;
    require(contractBalance > 100, "minimum of 100 wei to distribute");
    IFrensClaim frensClaim = IFrensClaim(getAddress(keccak256(abi.encodePacked("contract.address", "FrensClaim"))));
    uint[] memory idsInPool = getIdsInThisPool();
    for(uint i=0; i<idsInPool.length; i++) {
      uint id = idsInPool[i];
      address tokenOwner = frensPoolShare.ownerOf(id);
      uint share = _getShare(id, contractBalance);
      IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
      bool success = frensPoolSetter.distribute(tokenOwner, share);
      assert(success);
    }
    payable(address(frensClaim)).transfer(contractBalance); //dust -> claim contract instead of pools - the gas to calculate and leave dust in pool >> lifetime expected dust/pool

  }

  function claim() external {
    claim(msg.sender);
  }

  function claim(address claimant) public {
    IFrensClaim frensClaim = IFrensClaim(getAddress(keccak256(abi.encodePacked("contract.address", "FrensClaim"))));
    frensClaim.claim(claimant);
  }

  function distributeAndClaim() external {
    distribute();
    claim(msg.sender);
  }

  function distributeAndClaimAll() external {
    distribute();
    uint[] memory idsInPool = getIdsInThisPool();
    for(uint i=0; i<idsInPool.length; i++) { //this is expensive for large pools
      uint id = idsInPool[i];
      address tokenOwner = frensPoolShare.ownerOf(id);
      claim(tokenOwner);
    }
  }

  function exitPool() external onlyOwner{
    if(address(this).balance > 100){
      _distribute(); 
    }
    currentState = State.exited;

    //TODO: what else needs to be in here (probably a limiting modifier and/or some requires) maybe add an arbitrary call to an external contract is enabled?
    //TODO: is this where we extract fees?
    
  }

  function rageQuit(uint id) public {
    require(msg.sender == frensPoolShare.ownerOf(id), "not the owner");
    /*this needs logic to set a price, 
      *allow this contract to transfer the NFT, 
      *allow a purchase (will require a method), 
      *and start a timer,
      *once the timer has expired, the owner can call a method that has the following code to unlock it
    */
    IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
    bool success = frensPoolSetter.unlockTransfer(id);
    assert(success);
  }

  //getters

  function _getShare(uint _id, uint _contractBalance) internal view returns(uint) {
    uint depAmt = getUint(keccak256(abi.encodePacked("deposit.amount", _id)));
    uint totDeps = getUint(keccak256(abi.encodePacked("total.deposits", address(this))));
    if(depAmt == 0) return 0;
    uint calcedShare =  _contractBalance * depAmt / totDeps;
    if(calcedShare > 1){
      return(calcedShare - 1); //steal 1 wei to avoid rounding errors drawing balance negative
    }else return 0;
  }

  function getIdsInThisPool() public view returns(uint[] memory) {
    return getArray(keccak256(abi.encodePacked("ids.in.pool", address(this))));
  }

  function getShare(uint _id) public view returns(uint) {
    uint contractBalance = address(this).balance;
    return _getShare(_id, contractBalance);
  }

  function getDistributableShare(uint _id) public view returns(uint) {
    if(currentState == State.acceptingDeposits) {
      return 0;
    } else {
      return(getShare(_id));
    }
  }

  function getPubKey() public view returns(bytes memory){
    return getBytes(keccak256(abi.encodePacked("validator.public.key", address(this))));
  }

  function getState() public view returns(string memory){
    if(currentState == State.awaitingValidatorInfo) return "awaiting validator info";
    if(currentState == State.staked) return "staked";
    if(currentState == State.acceptingDeposits) return "accepting deposits";
    if(currentState == State.exited) return "exited";
    return "state failure"; //should never happen
  }

  function getDepositAmount(uint _id) public view returns(uint){
    return getUint(keccak256(abi.encodePacked("deposit.amount", _id)));
  }

  function getTotalDeposits() public view returns(uint){
    return getUint(keccak256(abi.encodePacked("total.deposits", address(this))));
  }

  function owner() public view override(IStakingPool, Ownable) returns (address){
    return super.owner();
  }

  function _toWithdrawalCred(address a) private pure returns (bytes memory) {
    uint uintFromAddress = uint256(uint160(a));
    bytes memory withdralDesired = abi.encodePacked(uintFromAddress + 0x0100000000000000000000000000000000000000000000000000000000000000);
    return withdralDesired;
  }

  //setters

  function setArt(address newArtContract) external onlyOwner { //do we want the owner to be able to change the art on a whim?
    IFrensArt newFrensArt = IFrensArt(newArtContract);
    string memory newArt = newFrensArt.renderTokenById(1);
    require(bytes(newArt).length != 0, "invalid art contract");
    IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
    bool success = frensPoolSetter.setArt(newArtContract);
    assert(success);
  }

  // to support receiving ETH by default
  receive() external payable {}

  fallback() external payable {}
}
