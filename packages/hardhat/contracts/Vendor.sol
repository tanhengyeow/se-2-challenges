pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {
	// State variables
	YourToken public yourToken;
	uint256 public constant tokensPerEth = 100;

	// Events
	event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
	event SellTokens(
		address seller,
		uint256 amountOfTokens,
		uint256 amountOfETH
	);

	constructor(address tokenAddress) {
		yourToken = YourToken(tokenAddress);
	}

	function buyTokens() public payable {
		// Amount of tokens represented in 1e18
		uint256 amountOfTokens = tokensPerEth * msg.value;
		yourToken.transfer(msg.sender, amountOfTokens);
		emit BuyTokens(msg.sender, msg.value, amountOfTokens);
	}

	function withdraw() public onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}

	function sellTokens(uint256 _amount) public {
		yourToken.transferFrom(msg.sender, address(this), _amount);
		uint256 amountOfEth = _amount / tokensPerEth;
		payable(msg.sender).transfer(amountOfEth);
		emit SellTokens(msg.sender, _amount, amountOfEth);
	}
}
