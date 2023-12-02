pragma solidity 0.8.20;
//SPDX-License-Identifier: MIT

///@title Permanent Marker Font
///@author 0xWildhare and Frens Team
///@dev returns the styling for the permanent marker font in the svg Art as bytes

contract PmFont {
  function getPmFont() external pure returns (bytes memory){
    return(
      abi.encodePacked('<style>',
          '@font-face{',
                'font-family:"Permanent Marker";',
                'src:url(data:application/font-woff;charset=utf-8;base64,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) format("woff"); ',
                'font-weight:normal;',
                'font-style:normal;}',
        '</style>',
      '</defs>')
    );
  }
}
