pragma solidity ^0.4.24;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/BountyMarketHaiku.sol";

/// @title Tests for the Market for Haiku Bounties Contract
contract TestBountyMarketHaiku
{
    // Truffle will send us Ether after deploying the contract.
    uint public initialBalance = 10 ether;

    BountyMarketHaiku bountyMarketHaiku = BountyMarketHaiku(DeployedAddresses.BountyMarketHaiku());
    
    // Index of the bounty created by test
    uint bountyIndex;
    // Index of the proposal created by test for above bounty
    uint proposalIndex;
    
    /// @dev Test 1. Test the contract can hold value successfully
    function testContractHasMoney() public
    {
        uint marketBalance = address(this).balance; 
 
        // Compare expected vs actual values
        Assert.equal(initialBalance, marketBalance, "getMarketBalance should return initial balance of contract");
    }

    /// @dev Test 2. Test user can createBounty() successfully
    function testUserCanCreateBounty() public
    {
        bool isLive;
        string memory actualDesc;
        bool isOpen;
        address bountyOwner;
        uint value;
        
        // Create a new bounty with a description and get back its index
        string memory expected = "Write a Haiku about the sea";
        bountyIndex = bountyMarketHaiku.createBounty(expected);
        
        // We now use its index to retrieve its details
        (isLive, actualDesc, isOpen, bountyOwner, value) = bountyMarketHaiku.getBountyDetail(bountyIndex);
        
        // Compare expected vs actual values
        Assert.equal(expected, actualDesc, "createBounty vs getBountyDetail give different descriptions");
    }
    
    /// @dev Test 3. Test user can createProposal() successfully
    function testUserCanCreateProposal() public
    {
        bool isLive;
        string memory actualDesc;
        address proposalOwner;
        bool isPaid;
     
        // Create a new proposal with a description and get back its index 
        string memory expected = "Sun travels elsewhere / calm mandarin orange sea / barnacles embrace";  
        proposalIndex = bountyMarketHaiku.createProposal(bountyIndex, expected);
        
        // We now use its index to retreive its details        
        (isLive, actualDesc, proposalOwner, isPaid) = bountyMarketHaiku.getProposalDetail(bountyIndex, proposalIndex);
        
        // Compare expected vs actual values
        Assert.equal(expected, actualDesc, "createProposal vs getProposalDetail give different descriptions");
    }

    /// @dev Test 4. Test user can approve a proposal (since we created bounty also, we can do it)
    function testUserCanApproveProposal() public
    {
        bool isLive;
        string memory actualDesc;
        address proposalOwner;
        bool isPaid;
        
        // Approve proposal created in test 2 for bounty created in test 1
        bountyMarketHaiku.approveProposal(bountyIndex, proposalIndex);
        
        // We now use its index to retreive its details        
        (isLive, actualDesc, proposalOwner, isPaid) = bountyMarketHaiku.getProposalDetail(bountyIndex, proposalIndex);
        
        // Compare expected result (it should now be marked as paid) vs actual value
        bool expectedIsPaid = true;
        Assert.equal(expectedIsPaid, isPaid, "approveProposal did not set the isPaid flag");
    }

    /// @dev Test 5. Check current pause state (emergency stop) is off
    function testCheckCurrentPauseState() public
    {
        // Compare expected vs actual values
        bool expected = false;
        bool actual = bountyMarketHaiku.paused();
         
        Assert.equal(expected, actual, "Current pause status expected to be false");
    }
    
    /// @dev Test 6. Check current user (test user) cannot switch on the emergency stop, because they did not create original contract
    /// This involves catching the revert/throw from the checks made by the Pausable library see:
    ///   https://medium.com/(at)kscarbrough1/writing-solidity-unit-tests-for-testing-assert-require-and-revert-conditions-using-truffle-2e182d91a40f
    ///   https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol
    function testUserCannotPause() public
    {        
        ThrowProxy throwproxy = new ThrowProxy(address(bountyMarketHaiku)); 
        BountyMarketHaiku(address(throwproxy)).pause();
        bool r = throwproxy.execute.gas(200000)(); 
        Assert.isFalse(r, "User should not be able to pause. Should be false because it should throw!");
        //Assert.isTrue(r, "Should be true because it should NOT throw!");
    }

    /// @dev Test 7. Check current user (test user) cannot kill contract, because they did not create original contract
    /// This involves catching the revert/throw from the checks made by the Pausable library see:
    ///   https://medium.com/(at)kscarbrough1/writing-solidity-unit-tests-for-testing-assert-require-and-revert-conditions-using-truffle-2e182d91a40f
    ///   https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol
    function testUserCannotKill() public
    {        
        ThrowProxy throwproxy = new ThrowProxy(address(bountyMarketHaiku)); 
        BountyMarketHaiku(address(throwproxy)).kill();
        bool r = throwproxy.execute.gas(200000)(); 
        Assert.isFalse(r, "User should not be able to kill. Should be false because it should throw!");
        //Assert.isTrue(r, "Should be true because it should NOT throw!");
    }
}

/// @title Proxy contract for testing throws
/// Copied from https://medium.com/(at)kscarbrough1/writing-solidity-unit-tests-for-testing-assert-require-and-revert-conditions-using-truffle-2e182d91a40f
contract ThrowProxy
{
    address public target;
    bytes data;

    constructor(address _target) public
    {
        target = _target;
    }

    // Prime the data using the fallback function.
    function() public
    {
        data = msg.data;
    }

    function execute() public returns (bool)
    {
        return target.call(data);
    }
}