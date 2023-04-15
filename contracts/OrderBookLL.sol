// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

import "./lib/Errors.sol";

// Add reentrancy guard
contract OrderBookLL {
    using SafeERC20 for IERC20;

    /** storage */

    uint256 public constant LTV = 90;
    uint256 public constant ETH_USDT = 4;
    uint256 public constant ETH_UNI = 2;
    uint256 public constant PER_DAY_IN_SECS = 86400;

    IERC20 public usdt;

    IERC20 public uni;

    IERC20 public WETH;

    struct Node {
        uint256 interestRate;
        uint256 availableAmount;
        uint256 amountBorrowed;
        address user;
        uint256 time;
        bytes32 next;
    }

    struct Borrower {
        uint256 amount;
        uint256 time;
        uint256 interestRate;
    }

    struct Lender {
        uint256 amount;
        uint256 time;
        uint256 interestRate;
    }

    mapping(address => Borrower[]) public lenders;
    mapping(address => Lender[]) public borrowers;

    struct User {
        uint256 collateral;
        mapping(address => uint256) borrowedAmount;
        mapping(address => bool) userInterest;
    }

    mapping(address => User) public userInfo;

    mapping(bytes32 => Node) public usdtLend;
    mapping(bytes32 => Node) public uniLend;
    bytes32 public usdtHead;
    bytes32 public uniHead;
    bytes32 public usdtTail;
    bytes32 public uniTail;
    uint256 public usdtSize;
    uint256 public uniSize;

    constructor(IERC20 _usdt, IERC20 _uni, IERC20 _WETH) {
        usdtHead = keccak256(abi.encode(0));
        uniHead = keccak256(abi.encode(0));
        usdtTail = keccak256(abi.encode(0));
        uniTail = keccak256(abi.encode(0));
        usdtSize = 0;
        uniSize = 0;

        usdt = _usdt;
        uni = _uni;
        WETH = _WETH;
    }

    modifier isValidBorrowToken(IERC20 _borrowToken) {
        require(
            _borrowToken == uni || _borrowToken == usdt,
            "Invalid Borrow Token"
        );
        _;
    }

    /**
     * Method is used by lender to lend amount with custom interest rate.
     *
     * @param _interestRate Rate at which amount is lend
     * @param _amount Total amount to be lend
     * @param _lendToken usdt or uni token address
     */
    function lend(
        uint256 _interestRate,
        uint256 _amount,
        IERC20 _lendToken
    ) public {
        User storage _userInfo = userInfo[msg.sender];

        bool alreadyLendSameToken = _userInfo.userInterest[address(_lendToken)];

        if (alreadyLendSameToken) {
            revert Errors.UserWithSameInterateAlreadyActive();
        }

        // User can only lend usdt and uni
        if (_lendToken != uni || _lendToken != usdt) {
            revert Errors.InvalidLendToken();
        }

        _lendToken.transferFrom(msg.sender, address(this), _amount);

        userInfo[msg.sender].userInterest[(address(_lendToken))] = true;

        bytes32 _newNodeHash = keccak256(abi.encode(_interestRate, msg.sender));
        Node memory node = Node(
            _interestRate,
            _amount,
            0,
            msg.sender,
            block.timestamp,
            _newNodeHash
        );

        if (address(_lendToken) == address(uni)) {
            (uniHead, uniTail) = interestRateLL(
                _interestRate,
                msg.sender,
                node,
                uniLend,
                _newNodeHash,
                uniSize,
                usdtHead,
                usdtTail
            );
            ++uniSize;
        }
        if (address(_lendToken) == address(usdt)) {
            (usdtHead, usdtTail) = interestRateLL(
                _interestRate,
                msg.sender,
                node,
                usdtLend,
                _newNodeHash,
                usdtSize,
                usdtHead,
                usdtTail
            );
            ++usdtSize;
        }
    }

    /**
     * It is used to put the Lend info to a sorted Linked list.
     */
    function interestRateLL(
        uint256 _interestRate,
        address _user,
        Node memory node,
        mapping(bytes32 => Node) storage nodes,
        bytes32 _newNodeHash,
        uint256 size,
        bytes32 head,
        bytes32 tail
    ) internal returns (bytes32, bytes32) {
        if (size == 0) {
            head = keccak256(abi.encode(_interestRate, _user));
            tail = keccak256(abi.encode(_interestRate, _user));
            nodes[tail] = node;
        } else if (_interestRate <= nodes[head].interestRate) {
            Node memory oldHead = nodes[head];
            head = _newNodeHash;
            nodes[head] = node;
            nodes[head].next = keccak256(
                abi.encode(oldHead.interestRate, oldHead.user)
            );
        } else if (_interestRate >= nodes[tail].interestRate) {
            Node memory oldTail = nodes[tail];
            nodes[tail].next = _newNodeHash;
            tail = _newNodeHash;

            // nodes[tail].next = keccak256(abi.encode(_interestRate, _user));
            nodes[tail] = node;
        } else {
            bytes32 nodeToCheck = head;
            bytes32 prevNode;
            bool inserted = false;
            for (uint256 i = 1; i <= size; i++) {
                Node memory _node = nodes[nodeToCheck];
                if (_node.interestRate >= _interestRate) {
                    // bytes32 prevNodeHash = prevNode;
                    // Node memory prevNode = nodes[prevNode];

                    nodes[prevNode].next = _newNodeHash;
                    nodes[_newNodeHash] = node;
                    nodes[_newNodeHash].next = keccak256(
                        abi.encode(_node.interestRate, _node.user)
                    );
                    // nodes[prevNode].next = keccak256(abi.encode(tail + 1, _user));
                    // nodes[tail + 1] = node;
                    // nodes[tail + 1].next = keccak256(abi.encode(nodeToCheck, _user));
                    // tail += 1;
                    inserted = true;
                    break;
                }
                prevNode = nodeToCheck;
                nodeToCheck = nodes[nodeToCheck].next;
            }
            require(inserted, "Node not inserted");
        }

        return (head, tail);
    }

    function claimInterest() external {}

    /**
     * It is used by borrower to a token.
     */
    function borrow(
        uint256 _borrowAmount,
        IERC20 _borrowToken
    ) external isValidBorrowToken(_borrowToken) {
        uint256 maxLTVInETH = calculateBorrowableAmount(
            userInfo[msg.sender].collateral
        );

        // TODO: interest to be paid for open positions as well ?

        // to avoid stack too deep
        {
            uint256 usdtAlreadyBorrowed = userInfo[msg.sender].borrowedAmount[
                address(usdt)
            ];

            uint256 uniAlreadyBorrowed = userInfo[msg.sender].borrowedAmount[
                address(uni)
            ];

            uint256 inputAmountInETH;
            if (usdt == _borrowToken) {
                inputAmountInETH = _borrowAmount / ETH_USDT;
            } else {
                inputAmountInETH = _borrowAmount / ETH_UNI;
            }

            uint256 usdtInETH = usdtAlreadyBorrowed / ETH_USDT;
            uint256 uniInETH = uniAlreadyBorrowed / ETH_UNI;

            if ((usdtInETH + uniInETH + inputAmountInETH) <= maxLTVInETH) {
                revert Errors.InvalidBorrowableAmount();
            }
        }

        bool isBorrowAmountAvailable;
        if (address(_borrowToken) == address(usdt)) {
            (, isBorrowAmountAvailable) = findUsdtBorrowAmountWithMinInterest(
                _borrowAmount
            );
        } else if (address(_borrowToken) == address(uni)) {
            (, isBorrowAmountAvailable) = findUniBorrowAmountWithMinInterest(
                _borrowAmount
            );
        }

        userInfo[msg.sender].borrowedAmount[
            address(_borrowToken)
        ] += _borrowAmount;
    }

    function findUniBorrowAmountWithMinInterest(
        uint256 _borrowAmount
    ) internal returns (uint256[] memory, bool) {
        bytes32 nodeToCheck = uniHead;
        uint256[] memory interestRates;
        uint256 remainingAmount = _borrowAmount;
        for (uint256 i = 1; i <= uniSize; i++) {
            Node memory node = uniLend[nodeToCheck];
            uint256 availableAmount = node.availableAmount;
            // base case
            if (availableAmount == remainingAmount) {
                interestRates[i] = (node.interestRate);
                uniLend[nodeToCheck].amountBorrowed += node.availableAmount;
                uniLend[nodeToCheck].availableAmount = 0;
                break;
            } else if (remainingAmount > availableAmount) {
                interestRates[i] = (node.interestRate);
                uniLend[nodeToCheck].availableAmount = 0;
                uniLend[nodeToCheck].amountBorrowed += node.availableAmount;
                remainingAmount -= availableAmount;
            } else {
                remainingAmount = 0;
                uniLend[nodeToCheck].availableAmount = 0;
                uniLend[nodeToCheck].amountBorrowed += node.availableAmount;
            }
            nodeToCheck = uniLend[nodeToCheck].next;
        }

        if (remainingAmount == 0) {
            return (interestRates, true);
        }

        return (interestRates, false);
    }

    /** 
     * Interest rate calculation for each borrower that he/she needs to pay.
     */
    function calculateBorrowerInterestRate(
        address _borrower
    ) public returns (uint256) {
        Lender[] memory totalLenders = borrowers[_borrower];

        uint256 totalInterestAmount;

        for (uint256 i = 0; i < totalLenders.length; i++) {
            Lender memory _lender = totalLenders[i];

            // scaling up is done to avoid precision loss
            uint256 interestAmount = ((_lender.interestRate * _lender.amount) *
                1e38) / 100;

            uint256 interestAmountPerSec = interestAmount /
                (PER_DAY_IN_SECS * 365);

            uint256 timeDiff = block.timestamp - _lender.time;

            totalInterestAmount += (interestAmountPerSec * timeDiff);
        }

        return totalInterestAmount;
    }

    /**
     * Method returns whether amount can be borrowed
     */
    function isUniBorrowAmountWithMinInterest(
        uint256 _borrowAmount
    ) public view returns (uint256[] memory, bool) {
        bytes32 nodeToCheck = uniHead;
        uint256[] memory interestRates;
        uint256 remainingAmount = _borrowAmount;
        for (uint256 i = 1; i <= uniSize; i++) {
            Node memory node = uniLend[nodeToCheck];
            uint256 availableAmount = node.availableAmount;
            // base case
            if (availableAmount == remainingAmount) {
                interestRates[i] = (node.interestRate);
                break;
            } else if (remainingAmount > availableAmount) {
                interestRates[i] = (node.interestRate);
                remainingAmount -= availableAmount;
            } else {
                remainingAmount = 0;
            }
            nodeToCheck = uniLend[nodeToCheck].next;
        }

        if (remainingAmount == 0) {
            return (interestRates, true);
        }

        return (interestRates, false);
    }

    /**
     * It is used to traverse through usdt LL to find whether amount
     * can be borrowed or not.
     */
    function findUsdtBorrowAmountWithMinInterest(
        uint256 _borrowAmount
    ) internal returns (uint256[] memory, bool) {
        bytes32 nodeToCheck = usdtHead;
        uint256[] memory interestRates;
        uint256 remainingAmount = _borrowAmount;
        uint256 borrowerIndex;
        for (uint256 i = 1; i <= usdtSize; i++) {
            Node memory node = usdtLend[nodeToCheck];
            uint256 availableAmount = node.availableAmount;

            // base case
            if (availableAmount == remainingAmount) {
                interestRates[i] = (node.interestRate);
                usdtLend[nodeToCheck].amountBorrowed += node.availableAmount;
                usdtLend[nodeToCheck].availableAmount = 0;

                borrowers[msg.sender][borrowerIndex].amount = availableAmount;
                borrowers[msg.sender][borrowerIndex].time = block.timestamp;
                borrowers[msg.sender][borrowerIndex].interestRate = node
                    .interestRate;
                remainingAmount = 0;
                break;
            } else if (remainingAmount > availableAmount) {
                interestRates[i] = (node.interestRate);
                usdtLend[nodeToCheck].availableAmount = 0;
                usdtLend[nodeToCheck].amountBorrowed += node.availableAmount;
                remainingAmount -= availableAmount;

                borrowers[msg.sender][borrowerIndex].amount = availableAmount;
                borrowers[msg.sender][borrowerIndex].time = block.timestamp;
                borrowers[msg.sender][borrowerIndex].interestRate = node
                    .interestRate;
            } else {
                // remaining amount is less than node's amount.
                remainingAmount = 0;
                uniLend[nodeToCheck].availableAmount = 0;
                uniLend[nodeToCheck].amountBorrowed += node.availableAmount;

                borrowers[msg.sender][borrowerIndex].amount = availableAmount;
                borrowers[msg.sender][borrowerIndex].time = block.timestamp;
                borrowers[msg.sender][borrowerIndex].interestRate = node
                    .interestRate;

                break;
            }
            nodeToCheck = usdtLend[nodeToCheck].next;
        }

        if (remainingAmount == 0) {
            return (interestRates, true);
        }

        return (interestRates, false);
    }

    /**
     * It is used to calculate max allowed borrow amount.
     * @param _amount total amount that is borrowed
     * @param _token Token in which amount is borrowed
     */
    function maxAllowedBorrowBasedOnToken(
        uint256 _amount,
        IERC20 _token
    ) public view returns (uint256) {
        uint256 factor;

        if (address(usdt) == address(_token)) {
            factor = ETH_USDT;
        } else {
            factor = ETH_UNI;
        }

        return _amount * factor;
    }

    /**
     * It allows to add collateral by borrower.
     */
    function addCollateral(uint256 _amount) external {
        uint256 borrowableAmount = calculateBorrowableAmount(_amount);

        if (borrowableAmount == 0) {
            revert Errors.InvalidBorrowableAmount();
        }

        WETH.transferFrom(msg.sender, address(this), _amount);

        userInfo[msg.sender].collateral += _amount;
    }

    /**
     * Calculates total allowed borrwable amount.
     * @param _collateral Total amount of collateral by used
     */
    function calculateBorrowableAmount(
        uint256 _collateral
    ) public pure returns (uint256) {
        return (_collateral * LTV) / 100;
    }

    /**
     * Get uni node by index.
     */
    function getUniNode(uint256 _index) public view returns (uint256, address) {
        require(_index <= uniSize, "Invalid index");
        bytes32 nodeToGet = uniHead;
        for (uint256 i = 1; i <= _index; i++) {
            nodeToGet = uniLend[nodeToGet].next;
        }
        return (uniLend[nodeToGet].interestRate, uniLend[nodeToGet].user);
    }

    /**
     * Get usdt node by index.
     */
    function getUsdtNode(
        uint256 _index
    ) public view returns (uint256, address) {
        require(_index <= usdtSize, "Invalid index");
        bytes32 nodeToGet = usdtHead;
        for (uint256 i = 1; i <= _index; i++) {
            nodeToGet = usdtLend[nodeToGet].next;
        }
        return (usdtLend[nodeToGet].interestRate, usdtLend[nodeToGet].user);
    }
}
