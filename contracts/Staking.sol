// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {

    // tokens used for staking and rewards
    IERC20 private token;
    address private owner;

    uint128 private _idCounter;

    // EVENTS

    event Stake(
        address indexed user,
        uint256 indexed id,
        uint256 indexed stakedAmount,
        uint256 stakingPeriod,
        uint256 startTime
    );

    event Withdraw(
        address indexed user,
        uint256 indexed id,
        uint256 stakedAmount,
        uint256 indexed withdrawAmount,
        uint256 stakingPeriod,
        uint256 startTime,
        uint256 endTime
    );

    // MODIFIERS

    modifier stakingPeriodEnded(address _user, uint256 id) {
        uint256 startTime = _userStakingInfo[_user][id].startTime;
        uint256 stakingPeriod = _userStakingInfo[_user][id]
            .stakingPeriod;
        uint256 timePassed = block.timestamp - startTime;

        require(
            timePassed >= stakingPeriod,
            "The current staking period has not ended"
        );
        _;
    }

    modifier validId(address _user, uint256 id) {
        require(
            (_userStakingInfo[_user])[id].stakedAmount > 0,
            "Invalid id"
        );
        _;
    }

    modifier validAmount(uint256 amount) {
        require(amount > 0, "Amount must be greater than 0");
        _;
    }

    modifier validStakingPeriod(uint256 stakingPeriod) {
        require(stakingPeriod > 0, "StakingPeriod must be greater than 0");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can airdrop");
        _;
    }

    // STRUCT, MAPPING

    struct StakingInfo {
        uint256 id;
        uint256 stakedAmount;
        uint256 stakingPeriod;
        uint256 startTime;
        uint256 reward;
    }

    mapping(address => StakingInfo[]) private _userStakingInfo;

    // CONSTRUCTOR

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "it's not valid token Address");
        owner = msg.sender;
        token = IERC20(_tokenAddress);
    }
    // STATE-CHANGING PUBLIC FUNCTIONS

    function getOwner() external view returns (address) {
        address _owner = owner;
        return _owner;
    }

    function changeOwner(address _owner) onlyOwner public {
        require(owner != address(0), "it's not valid Address");
        owner = payable(_owner);
    }

    function withdrawableAmount(
        uint256 id
    ) public view virtual validId(msg.sender, id) stakingPeriodEnded(msg.sender, id) returns (uint256) {
        return _withdrawableAmount(id, msg.sender);
    }

    function stake(
        address[] memory _address,
        uint256 amount,
        uint256 stakingPeriod,
        uint256 reward
    ) public virtual validAmount(amount) validStakingPeriod(stakingPeriod) onlyOwner() {
        for (uint256 i = 0; i < _address.length; i++) {
            _stake(_address[i], amount, stakingPeriod, reward);
        }
    }

    function withdrawAll(
        uint256 id
    ) public virtual validId(msg.sender, id) stakingPeriodEnded(msg.sender, id) {
        _withdrawAll(id, msg.sender);
    }

    function withdraw(
        uint256 id,
        uint256 withdrawAmount
    )
        public
        virtual
        validId(msg.sender, id)
        validAmount(withdrawAmount)
        stakingPeriodEnded(msg.sender, id)
    {
        _withdraw(withdrawAmount, id, msg.sender);
    }

    function getUserStakingInfo(
    ) public view virtual returns (StakingInfo[] memory) {
        return _userStakingInfo[msg.sender];
    }

    // INTERNAL FUNCTIONS

    function _stake(address _user, uint256 amount, uint256 stakingPeriod, uint256 _reward) internal {
        uint256 counter = _idCounter;

        token.transferFrom(owner, address(this), amount + stakingPeriod * _reward);
        _userStakingInfo[_user].push(
            StakingInfo(counter, amount, stakingPeriod, block.timestamp, _reward)
        );
        ++_idCounter;
        emit Stake(_user, counter, amount, block.timestamp, stakingPeriod);
    }

    function _withdrawAll(uint256 id, address _user) internal {
        StakingInfo storage stakingInfo = _userStakingInfo[_user][id];
        uint256 withdrawableAmount_ = _withdrawableAmount(id, _user);

        delete _userStakingInfo[_user][id];
        token.transfer(_user, withdrawableAmount_);

        emit Withdraw(
            _user,
            id,
            stakingInfo.stakedAmount,
            withdrawableAmount_,
            stakingInfo.stakingPeriod,
            stakingInfo.startTime,
            block.timestamp
        );
    }

    function _withdraw(uint256 withdrawAmount, uint256 id,  address _user) internal {
        StakingInfo storage stakingInfo = _userStakingInfo[_user][id];
        uint256 withdrawableAmount_ = _withdrawableAmount(id, _user);

        require(
            withdrawAmount <= withdrawableAmount_,
            "Withdraw amount exceeds the withdrawable amount"
        );
        uint256 stakedAmount = stakingInfo.stakedAmount;
        uint256 stakingPeriod = stakingInfo.stakingPeriod;
        uint256 startTime = stakingInfo.startTime;
        _userStakingInfo[_user][id].stakedAmount = withdrawableAmount_ - withdrawAmount;
        _userStakingInfo[_user][id].reward = 0;

        token.transfer(_user, withdrawAmount);

        emit Withdraw(
            _user,
            id,
            stakedAmount,
            withdrawAmount,
            stakingPeriod,
            startTime,
            block.timestamp
        );
    }

    function _withdrawableAmount(uint256 id, address _user) internal view returns (uint256) {
        StakingInfo storage stakingInfo = _userStakingInfo[_user][id];
        uint256 _stakingPeriod = stakingInfo.stakingPeriod;
        uint256 _reward = stakingInfo.reward;

        uint256 amountWhenStakingPeriodEnds = stakingInfo.stakedAmount + _reward * _stakingPeriod;

        return amountWhenStakingPeriodEnds;
    }
}