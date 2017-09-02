pragma solidity ^0.4.15;

contract Splitter {
    address public owner;
    bool public killed;
    bool public paused;
    mapping (address => uint) public balances;
    mapping (bytes32 => Payees) public splitterGroups;

    event LogWithdrawal(address indexed payee, uint amount);
    event LogCreateSplitterGroup(address indexed alice, address indexed bob, address indexed carol, bytes32 groupId);
    event LogSplitToAddres(address indexed alice, address indexed bob, address indexed carol, uint totalAmount);
    event LogKill(uint blockNumber, string reasonForKill);
    event LogPause(uint blockNumber, string reasonForPause);
    event LogResume(uint blockNumber);

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

        LogSplitToAddres(msg.sender, bob, carol, msg.value);
    }

    function groupSplit(bytes32 groupId)
        external
        payable
        isActive
    {
        split(splitterGroups[groupId].bob, splitterGroups[groupId].carol);
    }

    function createGroup(address bob, address carol, bytes32 groupId)
        public
        isActive
    {
        require(!splitterGroups[groupId].exists);

        splitterGroups[groupId] = Payees(true, bob, carol);

        LogCreateSplitterGroup(msg.sender, bob, carol, groupId);
    }

    function withdrawl()
        returns(bool)
    {
        uint toSend = balances[msg.sender];
        balances[msg.sender] = 0;
        if (msg.sender.send(balances[msg.sender])) {
            LogWithdrawal(msg.sender, toSend);
            return true;
        } else {
            balances[msg.sender] = toSend;
            return false;
        }
    }

    function pause(string reason)
        external
    {
        LogPause(block.number, reason);
        paused = true;
    }

    function resume()
        external
    {
        LogResume(block.number);
        paused = false;
    }

    function kill(string reason)
        external
    {
        LogPause(block.number, reason);
        killed = true;
    }
}
