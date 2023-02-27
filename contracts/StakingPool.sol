
contract StakingPool {

  constructor(){
  }

}

// pragma solidity >=0.8.0 <0.9.0;
// //SPDX-License-Identifier: MIT

// //import "hardhat/console.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/interfaces/IERC721Enumerable.sol";
// import "./interfaces/IDepositContract.sol";
// import "./interfaces/IFrensPoolShare.sol";
// import "./interfaces/IStakingPool.sol";
// import "./interfaces/IFrensArt.sol";
// import "./interfaces/IFrensPoolSetter.sol";
// import "./interfaces/IFrensOracle.sol";
// import "./FrensBase.sol";


// contract StakingPool is IStakingPool, Ownable, FrensBase {

//   event Stake(address depositContractAddress, address caller);
//   event DepositToPool(uint amount, address depositer, uint id);
//   event ExecuteTransaction(
//             address sender,
//             address to,
//             uint value,
//             bytes data,
//             bytes result
//         );

//   enum State { awaitingValidatorInfo, acceptingDeposits, staked, exited }
//   State currentState;

//   IFrensPoolShare frensPoolShare;

//   constructor(address owner_, bool validatorLocked_, IFrensStorage frensStorage_) FrensBase(frensStorage_){
//     address frensPoolShareAddress = getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolShare")));
//     frensPoolShare = IFrensPoolShare(frensPoolShareAddress); //this hardcodes the nft contract to the pool
    
//     if(validatorLocked_){
//       currentState = State.awaitingValidatorInfo;
//     } else {
//       currentState = State.acceptingDeposits;
//     }
//     _transferOwnership(owner_);
//     version = 0;
//   }

//   function depositToPool() external payable {
//     require(currentState == State.acceptingDeposits, "not accepting deposits"); //state must be "aceptingDeposits"
//     require(msg.value != 0, "must deposit ether"); //cannot generate 0 value nft
//     require(getUint(keccak256(abi.encodePacked("total.deposits", address(this)))) + msg.value <= 32 ether, "total deposits cannot be more than 32 Eth"); //limit deposits to 32 eth
//     IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
//     bool success = frensPoolSetter.depositToPool(msg.value);
//     assert(success);
//     uint id = getUint(keccak256(abi.encodePacked("token.id"))); //retrieve token id
//     frensPoolShare.mint(msg.sender); //mint nft
//     emit DepositToPool(msg.value,  msg.sender, id); 
//   }
  

//   function addToDeposit(uint _id) external payable {
//     require(frensPoolShare.exists(_id), "id does not exist"); //id must exist
//     require(currentState == State.acceptingDeposits, "not accepting deposits"); //pool must be "acceptingDeposits"
//     require(getUint(keccak256(abi.encodePacked("total.deposits", address(this)))) + msg.value <= 32 ether, "total deposits cannot be more than 32 Eth"); //limit deposits to 32 eth
//     IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
//     bool success = frensPoolSetter.addToDeposit(_id, msg.value);
//     assert(success);
//   }

//   function stake(
//     bytes calldata pubKey,
//     bytes calldata withdrawal_credentials,
//     bytes calldata signature,
//     bytes32 deposit_data_root
//   ) external onlyOwner{
//     //if validator info has previously been entered, check that it is the same, then stake
//     if(getBool(keccak256(abi.encodePacked("validator.set", address(this))))){
//       bytes memory pubKeyFromStorage = getBytes(keccak256(abi.encodePacked("pubKey", address(this)))); 
//       require(keccak256(pubKeyFromStorage) == keccak256(pubKey), "pubKey mismatch");
//     }else { //if validator info has not previously been entered, enter it, then stake
//       _setPubKey(
//         pubKey,
//         withdrawal_credentials,
//         signature,
//         deposit_data_root
//       );
//     }
//     _stake();
//   }

//   function stake() external onlyOwner{
//     _stake();
//   }

//   function _stake() internal {
//     require(address(this).balance >= 32 ether, "not enough eth"); 
//     require(currentState == State.acceptingDeposits, "wrong state");
//     require(getBool(keccak256(abi.encodePacked("validator.set", address(this)))), "validator not set");
//     bytes memory pubKey = getBytes(keccak256(abi.encodePacked("pubKey", address(this))));
//     bytes memory withdrawal_credentials = getBytes(keccak256(abi.encodePacked("withdrawal_credentials", address(this))));
//     bytes memory signature = getBytes(keccak256(abi.encodePacked("signature", address(this))));
//     bytes32 deposit_data_root = getBytes32(keccak256(abi.encodePacked("deposit_data_root", address(this))));
//     address depositContractAddress = getAddress(keccak256(abi.encodePacked("external.contract.address", "DepositContract")));
//     currentState = State.staked;
//     IDepositContract(depositContractAddress).deposit{value: 32 ether}(pubKey, withdrawal_credentials, signature, deposit_data_root);
//     emit Stake(depositContractAddress, msg.sender);
//   }

//   function setPubKey(
//     bytes calldata pubKey,
//     bytes calldata withdrawal_credentials,
//     bytes calldata signature,
//     bytes32 deposit_data_root
//   ) external onlyOwner{
//     _setPubKey(pubKey, withdrawal_credentials, signature, deposit_data_root);
//   }

//   function _setPubKey(
//     bytes calldata pubKey,
//     bytes calldata withdrawal_credentials,
//     bytes calldata signature,
//     bytes32 deposit_data_root
//   ) internal{
//     //get expected withdrawal_credentials based on contract address
//     bytes memory withdrawalCredFromAddr = _toWithdrawalCred(address(this));
//     //compare expected withdrawal_credentials to provided
//     require(keccak256(withdrawal_credentials) == keccak256(withdrawalCredFromAddr), "withdrawal credential mismatch");
//     if(getBool(keccak256(abi.encodePacked("validator.locked", address(this))))){
//       require(currentState == State.awaitingValidatorInfo, "wrong state");
//       assert(!getBool(keccak256(abi.encodePacked("validator.set", address(this))))); //this should never fail
//       currentState = State.acceptingDeposits;
//     }
//     require(currentState == State.acceptingDeposits, "wrong state");
//     IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
//     bool success = frensPoolSetter.setPubKey(pubKey, withdrawal_credentials, signature, deposit_data_root);
//     assert(success);
//   }
// /* not ready for mainnet release?
//   function arbitraryContractCall(
//         address payable to,
//         uint256 value,
//         bytes calldata data
//     ) external onlyOwner returns (bytes memory) {
//       require(getBool(keccak256(abi.encodePacked("allowed.contract", to))), "contract not allowed");
//       require(!getBool(keccak256(abi.encodePacked("contract.exists", to))), "cannot call FRENS contracts"); //as an extra insurance incase a contract with write privledges somehow gets whitelisted.
//       (bool success, bytes memory result) = to.call{value: value}(data);
//       require(success, "txn failed");
//       emit ExecuteTransaction(
//           msg.sender,
//           to,
//           value,
//           data,
//           result
//       );
//       return result;
//     }
// */
//   function withdraw(uint _id, uint _amount) external {
//     require(currentState == State.acceptingDeposits, "cannot withdraw once staked");
//     require(msg.sender == frensPoolShare.ownerOf(_id), "not the owner");
//     require(getUint(keccak256(abi.encodePacked("deposit.amount", address(this), _id))) >= _amount, "not enough deposited");
//     IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
//     bool success = frensPoolSetter.withdraw(_id, _amount);
//     assert(success);
//     payable(msg.sender).transfer(_amount);
//   }

//    function claim(uint id) external {
//     require(getAddress(keccak256(abi.encodePacked("pool.for.id", id))) == address(this), "wrong staking pool");
//     require(currentState != State.acceptingDeposits, "use withdraw when not staked");
//     require(address(this).balance > 100, "must be greater than 100 wei to claim");
//     //has the validator exited?
//     bool exited;
//     if(currentState != State.exited){
//       IFrensOracle frensOracle = IFrensOracle(getAddress(keccak256(abi.encodePacked("contract.address", "FrensOracle"))));
//       exited = frensOracle.checkValidatorState(address(this));
//     } else exited = true;
//     //get share for id
//     uint amount = _getShare(id);
//     //claim
//     IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
//     bool success = frensPoolSetter.claim(id, amount, exited);
//     assert(success);
//     //fee? not applied to exited
//     uint feePercent = getUint(keccak256(abi.encodePacked("protocol.fee")));
//     if(feePercent > 0 && !exited){
//       address feeRecipient = getAddress(keccak256(abi.encodePacked("fee.recipient")));
//       uint feeAmount = feePercent * amount / 100;
//       if(feeAmount > 1) payable(feeRecipient).transfer(feeAmount-1); //-1 wei to avoid rounding error issues
//       amount = amount - feeAmount;
//     }
//     payable(frensPoolShare.ownerOf(id)).transfer(amount);
//   }

//   function exitPool() external {
//     require(msg.sender == getAddress(keccak256(abi.encodePacked("contract.address", "FrensOracle"))), "must be called by oracle");
//     currentState = State.exited;
//   }
// /* not ready for mainnet release
//   function rageQuit(uint id, uint price) public {
//     require(msg.sender == frensPoolShare.ownerOf(id), "not the owner");
//     uint deposit = getUint(keccak256(abi.encodePacked("deposit.amount", address(this), id)));
//     require(price <= deposit, "cannot set price higher than deposit");
//     frensPoolShare.
//     IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
//     bool success = frensPoolSetter.rageQuit(id, price);
//     assert(success);
    
    
//   }
//   //TODO:needs a purchase function for ragequit
//   function unlockTransfer(uint id) public {
//     uint time = getUint(keccak256(abi.encodePacked("rage.time", id))) + 1 weeks;
//     require(time >= block.timestamp);
//     IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
//     bool success = frensPoolSetter.unlockTransfer(id);
//     assert(success);
//   }
  

//   function burn(uint tokenId) public { //this is only here to test the burn method in frensPoolShare
//     address tokenOwner = frensPoolShare.ownerOf(tokenId);
//     require(msg.sender == tokenOwner);
//     frensPoolShare.burn(tokenId);
//   }
// */
//   //getters

//   function getIdsInThisPool() public view returns(uint[] memory) {
//     return getArray(keccak256(abi.encodePacked("ids.in.pool", address(this))));
//   }

//   function getShare(uint _id) public view returns(uint) {
//     require(getAddress(keccak256(abi.encodePacked("pool.for.id", _id))) == address(this), "wrong staking pool");
//     return _getShare(_id);
//   }

//   function _getShare(uint _id) internal view returns(uint) {
//     if(address(this).balance == 0) return 0;
//     uint frenDep = getUint(keccak256(abi.encodePacked("deposit.amount", address(this), _id)));
//     uint totDep = getUint(keccak256(abi.encodePacked("total.deposits", address(this))));
//     uint frenPastClaims = getUint(keccak256(abi.encodePacked("fren.past.claims", address(this), _id)));
//     uint totPastClaims = getUint(keccak256(abi.encodePacked("total.claims", address(this))));
//     uint totFrenRewards = (frenDep * (address(this).balance + totPastClaims) / totDep);
//     if(totFrenRewards == 0) return 0;
//     uint amount = totFrenRewards - frenPastClaims;
//     return amount;
//   }

//   function getDistributableShare(uint _id) public view returns(uint) {
//     if(currentState == State.acceptingDeposits) {
//       return 0;
//     } else {
//       uint share = _getShare(_id);
//        //fee? not applied to exited
//       uint feePercent = getUint(keccak256(abi.encodePacked("protocol.fee")));
//       if(feePercent > 0 && currentState != State.exited){
//         uint feeAmount = feePercent * address(this).balance / 100;
//         share = share - feeAmount;
//       }
//     return share;
//     }
//   }

//   function getPubKey() public view returns(bytes memory){
//     return getBytes(keccak256(abi.encodePacked("pubKey", address(this))));
//   }

//   function getState() public view returns(string memory){
//     if(currentState == State.awaitingValidatorInfo) return "awaiting validator info";
//     if(currentState == State.staked) return "staked";
//     if(currentState == State.acceptingDeposits) return "accepting deposits";
//     if(currentState == State.exited) return "exited";
//     return "state failure"; //should never happen
//   }

//   function getDepositAmount(uint _id) public view returns(uint){
//     require(getAddress(keccak256(abi.encodePacked("pool.for.id", _id))) == address(this), "wrong staking pool");
//     return getUint(keccak256(abi.encodePacked("deposit.amount", address(this), _id)));
//   }

//   function getTotalDeposits() public view returns(uint){
//     return getUint(keccak256(abi.encodePacked("total.deposits", address(this))));
//   }

//   function owner() public view override(IStakingPool, Ownable) returns (address){
//     return super.owner();
//   }

//   function _toWithdrawalCred(address a) private pure returns (bytes memory) {
//     uint uintFromAddress = uint256(uint160(a));
//     bytes memory withdralDesired = abi.encodePacked(uintFromAddress + 0x0100000000000000000000000000000000000000000000000000000000000000);
//     return withdralDesired;
//   }

//   //setters

//   function setArt(address newArtContract) external onlyOwner { 
//     IFrensArt newFrensArt = IFrensArt(newArtContract);
//     string memory newArt = newFrensArt.renderTokenById(1);
//     require(bytes(newArt).length != 0, "invalid art contract");
//     IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
//     bool success = frensPoolSetter.setArt(newArtContract);
//     assert(success);
//   }

//   function resetArt() external onlyOwner {
//     IFrensPoolSetter frensPoolSetter = IFrensPoolSetter(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolSetter"))));
//     bool success = frensPoolSetter.setArt(address(0));
//     assert(success);
//   }

//   // to support receiving ETH by default
//   receive() external payable {}

//   fallback() external payable {}
// }
