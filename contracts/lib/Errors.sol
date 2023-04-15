//SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

library Errors {
    error InvalidLendToken();

    error ZeroAmount();

    error UserWithSameInterateAlreadyActive();

    error InvalidBorrowableAmount();

    error CannotBorrow();
}
