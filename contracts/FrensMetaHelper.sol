// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

//import "hardhat/console.sol";
// import "./interfaces/ISSVRegistry.sol";
import "./interfaces/IFrensMetaHelper.sol";
import "./interfaces/IFrensPoolShare.sol";
import "./interfaces/IENS.sol";
import "./interfaces/IReverseResolver.sol";
import "./interfaces/IStakingPool.sol";
import "./interfaces/IFrensStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract FrensMetaHelper is IFrensMetaHelper {
    using Strings for uint256;

    IFrensPoolShare frensPoolShare;
    IFrensStorage frensStorage;

    constructor(IFrensStorage frensStorage_) {
        frensStorage = frensStorage_;
        frensPoolShare = IFrensPoolShare(frensStorage.getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolShare"))));
    }

    function getDepositStringForId(
        uint id
    ) external view returns (string memory) {
        IStakingPool stakingPool = IStakingPool(frensPoolShare.getPoolById(id));
        return getEthDecimalString(stakingPool.depositForId(id));
    }

    function getEthDecimalString(
        uint amountInWei
    ) public pure returns (string memory) {
        string memory leftOfDecimal = (amountInWei / 1 ether).toString();
        uint rightOfDecimal = (amountInWei % 1 ether) / 10 ** 15;
        string memory rod = rightOfDecimal.toString();
        //if(rightOfDecimal < 1000) rod = string.concat("0", rod);
        if (rightOfDecimal < 100) rod = string.concat("0", rod);
        if (rightOfDecimal < 10) rod = string.concat("0", rod);
        return string.concat(leftOfDecimal, ".", rod);
    }

    function getPoolString(uint id) external view returns (string memory) {
        IStakingPool stakingPool = IStakingPool(frensPoolShare.getPoolById(id));
        return Strings.toHexString(uint160(address(stakingPool)), 20);
    }

    // SSV specific
    // function getOperatorsForPool(
    //     address poolAddress
    // ) external view returns (uint32[] memory, string memory) {
    //     bytes memory poolPubKey = getBytes(
    //         keccak256(abi.encodePacked("pubKey", poolAddress))
    //     );
    //     string memory pubKeyString = _iToHex(poolPubKey);
    //     //ISSVRegistry ssvRegistry = ISSVRegistry(getAddress(keccak256(abi.encodePacked("external.contract.address", "SSVRegistry"))));
    //     uint32[] memory poolOperators; // = ssvRegistry.getOperatorsByValidator(poolPubKey);
    //     return (poolOperators, pubKeyString);
    // }

    function _iToHex(
        bytes memory buffer
    ) internal pure returns (string memory) {
        // Fixed buffer size for hexadecimal convertion
        bytes memory converted = new bytes(buffer.length * 2);
        bytes memory _base = "0123456789abcdef";
        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }
        return string(abi.encodePacked("0x", converted));
    }

    function getEns(address addr) external view returns (bool, string memory) {
        IENS ens = IENS(address(frensStorage.getAddress(keccak256(abi.encodePacked("external.contract.address", "ENS")))));

        bytes32 node = _node(addr);
        address revResAddr = ens.resolver(node);
        if (revResAddr == address(0)) return (false, "");
        IReverseResolver reverseResolver = IReverseResolver(revResAddr);
        return (ens.recordExists(node), reverseResolver.name(node));
    }

    function _node(address addr) internal pure returns (bytes32) {
        bytes32 ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;
        return
            keccak256(
                abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr))
            );
    }

    function sha3HexAddress(address addr) private pure returns (bytes32 ret) {
        addr;
        ret; // Stop warning us about unused variables
        assembly {
            let
                lookup
            := 0x3031323334353637383961626364656600000000000000000000000000000000

            for {
                let i := 40
            } gt(i, 0) {

            } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
            }

            ret := keccak256(0, 40)
        }
    }
}
