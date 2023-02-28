// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;
import "./interfaces/IFrensMetaHelper.sol";
import "./interfaces/IPmFont.sol";
import "./interfaces/IFrensLogo.sol";
import "./interfaces/IWaves.sol";
import "./interfaces/IFrensStorage.sol";

import "hardhat/console.sol";

contract FrensArt {

    IFrensStorage frensStorage;
    
    constructor(
        IFrensStorage frensStorage_
    ) {
        frensStorage = frensStorage_;
    }

    // Visibility is `public` to enable it being called by other contracts for composition.
    function renderTokenById(uint256 id) public view returns (string memory) {
        console.log("0");
        IFrensMetaHelper frensMetaHelper = IFrensMetaHelper(frensStorage.getAddress(keccak256(abi.encodePacked("contract.address", "FrensMetaHelper"))));
        console.log("1", address(frensMetaHelper));
        IPmFont pmFont = IPmFont(frensStorage.getAddress(keccak256(abi.encodePacked("contract.address", "PmFont"))));
        console.log("2", address(pmFont));
        IWaves waves = IWaves(frensStorage.getAddress(keccak256(abi.encodePacked("contract.address", "Waves"))));
        console.log("3", address(waves));
        IFrensLogo frensLogo = IFrensLogo(frensStorage.getAddress(keccak256(abi.encodePacked("contract.address", "FrensLogo"))));
        console.log("4", address(frensLogo));
        string memory depositString = frensMetaHelper.getDepositStringForId(id);
        string memory pool = frensMetaHelper.getPoolString(id);
        bytes memory permanentMarker = pmFont.getPmFont();
        bytes memory logo = frensLogo.getLogo();
        bytes memory wavesGraphic = waves.getWaves();

        string memory render = string(
            abi.encodePacked(
                "<defs>",
                '<linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">',
                '<stop offset="0%" style="stop-color:#3f19ee;stop-opacity:1" />',
                '<stop offset="100%" style="stop-color:#54dae0;stop-opacity:1" />',
                "</linearGradient>",
                permanentMarker,
                '<rect height="400" width="400" fill="url(#grad1)" />',
                logo,
                wavesGraphic,
                '<text font-size="15.5" x="200" y="163" text-anchor="middle" font-family="Sans,Arial" letter-spacing="6" fill="white">',
                "DEPOSIT",
                "</text>",
                '<text font-size="45" x="200" y="212" text-anchor="middle"  font-weight="910" font-family="Sans,Arial" letter-spacing="-1" fill="white">',
                depositString,
                " ETH ",
                "</text>",
                '<text font-size="18.7" x="200" y="243" text-anchor="middle" font-family="Permanent Marker" fill="white">',
                "FRENS POOL STAKE",
                "</text>",
                '<rect x="27" y="345" height="30" width="346" fill="#4554EA" opacity=".4" />',
                '<text font-size="10" x="200" y="365" text-anchor="middle" font-weight="bold" font-family="Sans,Arial" fill="white">',
                pool,
                "</text>"
            )
        );

        return render;
    }
}

// pragma solidity >=0.8.0 <0.9.0;

// //import "hardhat/console.sol";
// import "./interfaces/IStakingPool.sol";
// import "./interfaces/IFrensPoolShare.sol";
// import "./interfaces/IFrensMetaHelper.sol";
// import "./interfaces/IFrensArt.sol";
// import "./interfaces/IPmFont.sol";
// import "./interfaces/IFrensLogo.sol";
// import "./interfaces/IWaves.sol";
// import "./FrensBase.sol";

// contract FrensArt is IFrensArt, FrensBase {

//   IFrensPoolShare frensPoolShare;

//   constructor(IFrensStorage _frensStorage) FrensBase(_frensStorage){
//     frensPoolShare = IFrensPoolShare(getAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolShare"))));
//     version = 0;
//   }

//   // Visibility is `public` to enable it being called by other contracts for composition.
//   function renderTokenById(uint256 id) public view returns (string memory) {
//     //IStakingPool stakingPool = IStakingPool(payable(getAddress(keccak256(abi.encodePacked("pool.for.id", id)))));
//     IFrensMetaHelper metaHelper = IFrensMetaHelper(getAddress(keccak256(abi.encodePacked("contract.address", "FrensMetaHelper"))));
//     string memory depositString = metaHelper.getDepositStringForId(id);
//     string memory pool = metaHelper.getPoolString(id);
//     //uint shareForId = stakingPool.getDistributableShare(id);
//     //string memory shareString = metaHelper.getEthDecimalString(shareForId);
//     //string memory poolColor = metaHelper.getColor(address(stakingPool));
//     //address ownerAddress = frensPoolShare.ownerOf(id);
//     //string memory textColor = metaHelper.getColor(ownerAddress);
//     //(bool ensExists, string memory ownerEns) = metaHelper.getEns(stakingPool.owner());

//     //permanent marker font definition
//     IPmFont pmFont = IPmFont(getAddress(keccak256(abi.encodePacked("contract.address", "PmFont"))));
//     bytes memory permanentMarker = pmFont.getPmFont();

//     //FRENS Shake logo
//     IFrensLogo frensLogo = IFrensLogo(getAddress(keccak256(abi.encodePacked("contract.address", "FrensLogo"))));
//     bytes memory logo = frensLogo.getLogo();

//     //waves
//     IWaves waves = IWaves(getAddress(keccak256(abi.encodePacked("contract.address", "Waves"))));
//     bytes memory wavesGraphic = waves.getWaves();

//     string memory render = string(abi.encodePacked(
// /*
//       //logo
//       '<image x="100" y="58" xlink:href="data:image/png;base64,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"/>'

//       //curves for text
//       '<path id="curve" d="M93,306 a151,151 0 1,1 1,1 " fill="transparent" />',
//       '<path id="curve2" d="M200,30 a170,170 0 1,0 1,0 " fill="transparent" />',

//       //deposit & claimable text
//       '<text font-size="25"  x="354" text-anchor="middle" fill="#4554EA"   font-family="Sans-Serif" >',
//         '<textPath xlink:href="#curve">',
//           'Deposit: ', depositString, ' Eth ',
//           '<tspan dx="30">',
//             ' Claimable: ', shareString, ' Eth',
//           '</tspan>',
//         '</textPath>',
//       '</text>',

//       //pool owners ENS
//       '<text font-size="25"  x="534" text-anchor="middle" fill="#4554EA" font-family="Sans-Serif" >',
//         '<textPath  xlink:href="#curve2">',
//           ensExists ? 'Pool created by: ' : 'frens.fun',
//           ownerEns,
//           '</textPath>',
//       '</text>'
//       */

//       '<defs>',
//         '<linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">',
//           '<stop offset="0%" style="stop-color:#3f19ee;stop-opacity:1" />',
//           '<stop offset="100%" style="stop-color:#54dae0;stop-opacity:1" />',
//         '</linearGradient>',

//         permanentMarker,

//       '<rect height="400" width="400" fill="url(#grad1)" />',

//       logo,

//       wavesGraphic,

//       '<text font-size="15.5" x="200" y="163" text-anchor="middle" font-family="sans" letter-spacing="6" fill="white">',
//         'DEPOSIT',
//       '</text>',

//       '<text font-size="45" x="200" y="212" text-anchor="middle"  font-weight="910" font-family="Sans,Arial" letter-spacing="-1" fill="white">',
//         depositString, ' ETH ',
//       '</text>',

//       '<text font-size="18.7" x="200" y="243" text-anchor="middle" font-family="Permanent Marker" fill="white">',
//         'FRENS POOL STAKE',
//       '</text>',

//       '<rect x="27" y="345" height="30" width="346" fill="#4554EA" opacity=".4" />',

//       '<text font-size="10" x="200" y="365" text-anchor="middle" font-weight="bold" font-family="Sans,Arial" fill="white">',
//         pool,
//       '</text>'
//     ));

//     return render;
//   }

// }
