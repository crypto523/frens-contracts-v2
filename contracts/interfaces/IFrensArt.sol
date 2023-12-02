pragma solidity 0.8.20;
//SPDX-License-Identifier: MIT

interface IFrensArt {
  function renderTokenById(uint256 id) external view returns (string memory);
}
