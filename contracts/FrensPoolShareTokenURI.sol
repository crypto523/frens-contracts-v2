// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

//import "hardhat/console.sol";
import "./interfaces/IStakingPool.sol";
import "./interfaces/IFrensPoolShare.sol";
// import "./interfaces/IFrensMetaHelper.sol";
import "./interfaces/IFrensArt.sol";
import "./interfaces/IFrensPoolShareTokenURI.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "base64-sol/base64.sol";

contract FrensPoolShareTokenURI is IFrensPoolShareTokenURI {
    using Strings for uint256;

    IFrensPoolShare frensPoolShare;

    constructor(IFrensPoolShare _frensPoolShare) {
        frensPoolShare = _frensPoolShare;
    }

    function tokenURI(uint256 id) public view returns (string memory) {
        require(frensPoolShare.exists(id), "id does not exist");
        IStakingPool stakingPool = frensPoolShare.getPoolById(id);
        //    IFrensMetaHelper metaHelper = IFrensMetaHelper(getAddress(keccak256(abi.encodePacked("contract.address", "FrensMetaHelper"))));
        string memory poolState = stakingPool.getState();
        return (poolState);
    }
    //     function tokenURI(uint256 id) public view returns (string memory) {
    //       require(frensPoolShare.exists(id), "id does not exist");
    //       address poolAddress = getAddress(keccak256(abi.encodePacked("pool.for.id", id)));
    //       IStakingPool stakingPool = IStakingPool(payable(poolAddress));
    //       IFrensMetaHelper metaHelper = IFrensMetaHelper(getAddress(keccak256(abi.encodePacked("contract.address", "FrensMetaHelper"))));
    //       string memory poolState = stakingPool.getState();
    //       string memory depositString = metaHelper.getDepositStringForId(id);
    //       uint shareForId = stakingPool.getDistributableShare(id);
    //       string memory shareString = metaHelper.getEthDecimalString(shareForId);
    //       string memory stakingPoolAddress = Strings.toHexString(uint160(poolAddress), 20);
    //       (/*uint32[] memory poolOperators*/, string memory pubKeyString) = metaHelper.getOperatorsForPool(poolAddress);
    //       string memory name = string(abi.encodePacked('fren pool share #',id.toString()));
    //       string memory description = string(abi.encodePacked(
    //         'this fren has a deposit of ',depositString,
    //         ' Eth in pool ', stakingPoolAddress,
    //         ', with claimable balance of ', shareString, ' Eth'));
    //       string memory image = Base64.encode(bytes(generateSVGofTokenById(id, poolAddress)));
    //       (bool ensExists, string memory ownerEns) = metaHelper.getEns(stakingPool.owner());
    //       string memory creator = ensExists ? ownerEns : Strings.toHexString(uint160(stakingPool.owner()), 20);

    //       return
    //         string(
    //           abi.encodePacked(
    //             'data:application/json;base64,',
    //             Base64.encode(
    //               bytes(
    //                 abi.encodePacked(
    //                   '{"name":"',
    //                   name,
    //                   '", "description":"',
    //                   description,
    //                   '", "external_url":"https://frens.fun/token/',
    //                   id.toString(),
    //                   '", "attributes": [{"trait_type": "pool", "value":"',
    //                   stakingPoolAddress,
    //                   '"},{"trait_type": "validator public key", "value": "',
    //                   pubKeyString,
    //                   '"},{"trait_type": "deposit", "value": "',
    //                   depositString, ' Eth',
    //                   '"},{"trait_type": "claimable", "value": "',
    //                   shareString, ' Eth',
    //                   '"},{"trait_type": "pool state", "value": "',
    //                   poolState,
    //                   '"},{"trait_type": "pool creator", "value": "',
    //                   creator,
    //                  // '"},{"trait_type": "operator1", "value": "',
    //                  // poolOperators.length == 0 ? "Not Set" : uint(poolOperators[0]).toString(),
    //                  // '"},{"trait_type": "operator2", "value": "',
    //                  // poolOperators.length == 0 ? "Not Set" : uint(poolOperators[1]).toString(),
    //                  // '"},{"trait_type": "operator3", "value": "',
    //                  // poolOperators.length == 0 ? "Not Set" : uint(poolOperators[2]).toString(),
    //                  // '"},{"trait_type": "operator4", "value": "',
    //                  // poolOperators.length == 0 ? "Not Set" : uint(poolOperators[3]).toString(),
    //                   '"}], "image": "',
    //                   'data:image/svg+xml;base64,',
    //                   image,
    //                   '"}'
    //                 )
    //               )
    //             )
    //           )
    //         );
    //     }

    //     function generateSVGofTokenById(uint256 id, address pool) internal view returns (string memory) {
    //       address artForPool  = getAddress(keccak256(abi.encodePacked("pool.specific.art.address", pool)));
    //       IFrensArt frensArt;
    //       if(artForPool == address(0)) {
    //         frensArt = IFrensArt(getAddress(keccak256(abi.encodePacked("contract.address", "FrensArt"))));
    //       } else {
    //         frensArt = IFrensArt(artForPool);
    //       }
    //       string memory svg = string(abi.encodePacked(
    //         '<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">',
    //           frensArt.renderTokenById(id),
    //         '</svg>'
    //       ));

    //       return svg;
    //     }
}
