// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AirDrop {

    address private owner;
    IERC20 public airdropToken;

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "it's not valid token Address");
        owner = msg.sender;
        airdropToken = IERC20(_tokenAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can airdrop");
        _;
    }
    
    function doAirDrop(address[] memory _address, uint256 _amount) onlyOwner public {
        for (uint256 i = 0; i < _address.length; i++) {
            address _to = payable(_address[i]);
            airdropToken.transferFrom(msg.sender, _to, _amount);
        }
    }

    function changeOwner(address _owner) onlyOwner public {
        require(_owner != address(0), "it's not valid Address");
        owner = payable(_owner);
    }

    function getOwner() external view returns (address) {
        address _owner = owner;
        return _owner;
    }
}