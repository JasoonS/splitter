pragma solidity ^0.4.4;

contract Splitter {
  address public alice;
  address public bob;
  address public carol;
  uint public last_completed_migration;

  modifier onlyAlice() {
    if (msg.sender == alice) _;
  }

  function Splitter(address _bob, address _carol) {
    alice = msg.sender;
    bob = _bob;
    carol = _carol;
  }
}
