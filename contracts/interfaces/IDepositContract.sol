
pragma solidity 0.8.20;
//SPDX-License-Identifier: MIT


interface IDepositContract {

    function deposit(
        bytes calldata pubkey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external payable;

    function get_deposit_count() external view returns (bytes memory);

}
