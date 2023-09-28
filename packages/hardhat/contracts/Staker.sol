// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
	// State variables
	ExampleExternalContract public exampleExternalContract;
	mapping(address => uint256) balances;
	uint256 public constant threshold = 1 ether;
	uint256 public deadline = block.timestamp + 30 seconds;
	bool public isOpenForWithdraw = false;
	bool public isExecuted = false;

	// Events
	event Stake(address indexed staker, uint256 indexed amount);

	// Modifiers
	modifier beforeDeadline() {
		require(block.timestamp < deadline, "Deadline is over");
		_;
	}

	modifier afterDeadline() {
		require(block.timestamp >= deadline, "Deadline has not past");
		_;
	}

	constructor(address exampleExternalContractAddress) {
		exampleExternalContract = ExampleExternalContract(
			exampleExternalContractAddress
		);
	}

	function stake() public payable beforeDeadline {
		uint256 stakeAmount = msg.value;
		balances[msg.sender] += stakeAmount;
		emit Stake(msg.sender, stakeAmount);
	}

	function getBalance(address staker) public view returns (uint256) {
		return balances[staker];
	}

	function execute() public afterDeadline {
		require(isExecuted == false, "This function has been executed!");
		if (address(this).balance >= threshold) {
			exampleExternalContract.complete{ value: address(this).balance }();
		} else {
			isOpenForWithdraw = true;
		}
		isExecuted = true;
	}

	function withdraw() public {
		require(isOpenForWithdraw == true, "Not open for withdrawal");
		require(balances[msg.sender] != 0, "No balance to withdraw");
		payable(msg.sender).transfer(balances[msg.sender]);
		balances[msg.sender] -= balances[msg.sender];
	}

	function timeLeft() public view returns (uint256) {
		if (block.timestamp >= deadline) {
			return 0;
		}
		return deadline - block.timestamp;
	}

	// Add the `receive()` special function that receives eth and calls stake()
}
