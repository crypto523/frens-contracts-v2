pragma solidity 0.8.20;
//SPDX-License-Identifier: MIT

contract FakeSSVNetwork{
    mapping(address=>address) public feeRecipient;

    function setFeeRecipientAddress(address _newFeeRecipient) public {
        feeRecipient[msg.sender] = _newFeeRecipient;
    }
}