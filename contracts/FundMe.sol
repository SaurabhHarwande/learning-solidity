//SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;
    
    uint256 public minimumUsd = 50;
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 usdAmount = msg.value.getConversionRate();
        require(usdAmount >= minimumUsd, "You need to send atleast $50 worth of ether");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }
    function withdraw() public onlyOwner {
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call { value: address(this).balance } ("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Sender is not owner!");
        _;
    }
}