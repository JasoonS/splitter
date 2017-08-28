pragma solidity ^0.4.16;

contract Splitter {
    address public owner;
    bool public killed;
    bool public paused;
    mapping (address => uint) public balances;
    mapping (bytes12 => Payees) public splitterGroups; 

    struct Payees {
        bool exists;
        address bob;
        address carol;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier isAlive() {
        require(!killed);
        _;
    }

    modifier isActive() {
        require(!killed);
        require(!paused);
        _;
    }

    function Splitter() {
        killed = false;
        paused = false;
    }
    
    function split(address bob, address carol) 
        public
        payable
        isActive
    {
        uint splitAmount = msg.value/2;
        
        if (msg.value%2 == 1) {
            balances[msg.sender] += 1;
        }
        balances[bob] += splitAmount;
        balances[carol] += splitAmount;
    }

    function split(bytes12 groupId) 
        external
        payable
        isActive
    {
        split(splitterGroups[groupId].bob, splitterGroups[groupId].bob);
    }
    
    function createGroup(address bob, address carol, bytes12 groupId) 
        public
        isActive
    {
        require(!splitterGroups[groupId].exists);
        
        splitterGroups[groupId] = Payees(true, bob, carol);
    }

    function withdrawl()
        returns(bool)
    {
        if (msg.sender.send(balances[msg.sender])) {
            balances[msg.sender] = 0;
            return true;
        } else {
            return false;
        }
    }

    function pause()
        external
    {
        paused = true;
    }

    function resume()
        external
    {
        paused = false;
    }

    function kill()
        external
    {
        killed = true;
    }
}
