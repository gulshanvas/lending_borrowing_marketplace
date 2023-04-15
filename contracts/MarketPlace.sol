// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "./lib/Errors.sol";

contract MarketPlace {
    using SafeERC20 for IERC20;

    /** storage */

    IERC20 public usdt;

    IERC20 public uni;

    IERC20 public WETH;

    struct lenderInfo {
        IERC20 lendToken;
        uint256 amount;
        uint256 interestRate;
    }

    mapping(address => lenderInfo) public lender;

    constructor(IERC20 _usdt, IERC20 _uni, IERC20 _WETH) public {
        usdt = _usdt;
        uni = _uni; 
        WETH = _WETH;
    }

    function lend(
        IERC20 _lendToken,
        uint256 _lendAmount,
        uint256 _rate
    ) external {
        if (_lendToken != usdt || _lendToken != uni) {
            revert Errors.InvalidLendToken();
        }

        if (_lendAmount == 0) {
            revert Errors.ZeroAmount();
        }

        _lendToken.safeTransferFrom(msg.sender, address(this), _lendAmount);

        lender[msg.sender] = lenderInfo({
            lendToken: _lendToken,
            amount: _lendAmount,
            interestRate: _rate
        });
    }
}
