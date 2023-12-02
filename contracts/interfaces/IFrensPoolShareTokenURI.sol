// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;


interface IFrensPoolShareTokenURI {
  function tokenURI ( uint256 id ) external view returns ( string memory );
}
