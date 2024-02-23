// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FunToken is ERC20 {
    
    constructor() ERC20("fun token", "futa"){}

    function mint(address to, uint amount) external {
        _mint(to, amount);
    }
}