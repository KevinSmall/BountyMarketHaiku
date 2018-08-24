pragma solidity ^0.4.24;

// Library to allow emergency stop pattern
// See https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol
// In remix use:
// import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
// In truffle use:
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

/// @title Bounty Market for Haiku
/// @author Kevin Small kevin_small@hotmail.com 
contract BountyMarketHaiku is Pausable
{
    uint constant MAXBOUNTY = 16;
    uint constant MAXPROPOSAL = 4;

    struct BountyStruct  
    {
        bool isLive;
        string desc;
        bool isOpen;
        address bountyOwner;
        uint value;
        ProposalStruct[MAXPROPOSAL] proposals;
    }
    struct ProposalStruct
    {
        bool isLive;
        string desc;
        address proposalOwner;
        bool isPaid;
    }
    
    // State
    BountyStruct[MAXBOUNTY] private bounties;
    mapping (address => uint) private pendingWithdrawals;
    
    // Events
    // Log bounty creation, detail and value
    event LogBountyCreated(uint bountyIndex, string bountyDesc, uint bountyValue);
    // Log that bounty has been closed, along with the winning proposal
    event LogBountyClosedByProposal(uint bountyIndex, string bountyDesc, uint proposalIndex, string proposalDesc);
    
    constructor () public payable
    {
        // Some test data - a bounty worth 0 ether
        bounties[0].isLive = true;
        bounties[0].desc = "Write me a Haiku about grass";
        bounties[0].isOpen = true;
        bounties[0].bountyOwner = msg.sender;
        bounties[0].value = 0; 
        
        // Some test data - a couple of proposals
        bounties[0].proposals[0].isLive = true;
        bounties[0].proposals[0].desc = "Jade blades in summer / sleeping grey through winter / jewels on bare feet";
        bounties[0].proposals[0].proposalOwner = msg.sender;
        bounties[0].proposals[0].isPaid = false;
        
        bounties[0].proposals[1].isLive = true;
        bounties[0].proposals[1].desc = "Freshly mown grass / clinging to my shoes / my muddled thoughts";
        bounties[0].proposals[1].proposalOwner = msg.sender;
        bounties[0].proposals[1].isPaid = false;
    }

    /// @notice Tells us how much Wei is available in the market, remaining to be paid out.
    /// @dev Balance is read from contract address.
    /// @return Total Wei held by this contract.
    function getMarketBalance() public view
    returns(uint marketBalance)
    {
       return address(this).balance;
    }
    
    /// @notice Count how many bounties are live and not yet paid.
    /// @dev Uses bounties array .isOpen flag.
    /// @return Count of open bounties (unpaid bounties).
    function getCountOpenBounties() public view
    returns(uint)
    {
        uint counter = 0;
        uint arrayLength = bounties.length;
        for (uint i=0; i<arrayLength; i++)
        {
          if (bounties[i].isOpen == true)
          {
             // Fill this bounty
             counter++;
          }
        }
        return counter;
    }

    /// @notice Create a new bounty, passing a description of the Haiku required and some Ether to pay people who do the work.
    /// @dev Even if no Wei sent, a bounty is created, just with zero value. Will revert if market is full.
    /// @param desc Description of the Haiku topic.
    /// @return bountyIndex A bounty index.
    function createBounty(string desc) public payable
    returns(uint bountyIndex)
    {
        // Search for vacant slot in market
        uint arrayLength = bounties.length;
        for (uint i=0; i<arrayLength; i++)
        {
          if ((bounties[i].isLive == false))
          {
             // Fill this bounty
             bounties[i].isLive = true;
             bounties[i].desc = desc;
             bounties[i].isOpen = true;
             bounties[i].bountyOwner = msg.sender;
             bounties[i].value = msg.value;
             emit LogBountyCreated(i, desc, msg.value);
             return i;
          }
        }
        revert("Bounty market is full, only MAXBOUNTY bounties allowed");
    }
    
    /// @notice Get a list bools telling us if a bounty is open or not. The indices correspond to the bounty index.
    /// For example if this funtion returns "true, true, false, false...etc" then calling getBountyDetail(0) and getBountyDetail(1)
    /// will give full details of the open bounties (that is those with indices 0 and 1, matching the bool list).
    /// @dev Uses .isOpen flag to determine if bounty open or not.
    /// @return bountyIsOpen An array of bools, indices corresponding to bountyIndices.
    function getListOpenBounties() public view
    returns(bool[MAXBOUNTY] bountyIsOpen)
    {
        uint arrayLength = bounties.length;
        for (uint i=0; i<arrayLength; i++)
        {
            bountyIsOpen[i] = bounties[i].isOpen;
        }
    }

    /// @notice Get a list bools showing which bounties belong to the caller. The indices correspond to the bounty index.
    /// For example if this funtion returns "true, true, false, false...etc" then calling getBountyDetail(0) and getBountyDetail(1)
    /// will give full details of the bounties that the caller owns (that is those with indices 0 and 1, matching the bool list).
    /// @dev Compares msg.sender with .bountyOwner address to determine if bounty belongs to the caller or not.
    /// @return bountyIsMine An array of bools, indices corresponding to bountyIndices.
    function getListMyBounties() public view
    returns(bool[MAXBOUNTY] bountyIsMine)
    {
        uint arrayLength = bounties.length;
        for (uint i=0; i<arrayLength; i++)
        {
            if (bounties[i].bountyOwner == msg.sender)
            {
                bountyIsMine[i] = true;
            }
            else
            {
                bountyIsMine[i] = false;
            }
        }
    }
        
    /// @notice Get bounty detail for the passed index. Index is zero based.
    /// @dev Would prefer to return a struct once Solidity allows it.
    /// @return Details of the bounty.
    function getBountyDetail(uint bountyIndex) public view
    returns(bool isLive, string desc, bool isOpen, address bountyOwner, uint value)
    {
        // guard values
        require(bountyIndex < MAXBOUNTY, "bountyIndex exceeds MAXBOUNTY");
        
        isLive = bounties[bountyIndex].isLive; 
        desc = bounties[bountyIndex].desc; 
        isOpen = bounties[bountyIndex].isOpen; 
        bountyOwner = bounties[bountyIndex].bountyOwner; 
        value = bounties[bountyIndex].value; 
    }

    /// @notice Get bounty description for the passed index. Index is zero based.
    /// @return Description of the bounty.
    function getBountyDesc(uint bountyIndex) public view
    returns(string desc)
    {
        // guard values
        require(bountyIndex < MAXBOUNTY, "bountyIndex exceeds MAXBOUNTY");   
        desc = bounties[bountyIndex].desc; 
     }

    /// @notice Gets most details about all bounties
    /// @dev Can you believe we cannot yet return an array of strings? I can.
    /// So the descriptions string list doesnt get included. Use getBountyDetail to get that per index.
    /// @return Arrays of bounty fields (but not the string description)
    function getBountyDetailAll() public view
    returns(uint[MAXBOUNTY] bIndex, bool[MAXBOUNTY] bIsOpen, address[MAXBOUNTY] bOwner, uint[MAXBOUNTY] bValue)
    {
        uint arrayLength = bounties.length;
        for (uint i=0; i<arrayLength; i++)
        {
            bIndex[i] = i;
            bIsOpen[i] = bounties[i].isOpen;
            bOwner[i] = bounties[i].bountyOwner;
            bValue[i] = bounties[i].value;
        }
    }

    /// @notice Create a new proposal for the specified bounty
    /// @dev Does bounds checking on index passed, reverts on failure.
    /// @return Proposal index number
    function createProposal(uint bountyIndex, string desc) public
    returns(uint proposalId)
    {
        // Guard values
        require(bountyIndex < MAXBOUNTY, "bountyIndex exceeds MAXBOUNTY");
        
        // Search for vacant slot in market
        uint arrayLength = bounties[bountyIndex].proposals.length;
        for (uint i=0; i<arrayLength; i++)
        {
          if ((bounties[bountyIndex].proposals[i].isLive == false))
          {
             // Fill this proposal
             bounties[bountyIndex].proposals[i].isLive = true;
             bounties[bountyIndex].proposals[i].desc = desc;
             bounties[bountyIndex].proposals[i].proposalOwner = msg.sender;
             bounties[bountyIndex].proposals[i].isPaid = false;
             return i;
          }
        }
        revert("Proposal market is full for this bounty, only MAXPROPOSAL proposals allowed");
    }
   
    /// @notice Gets all the fields for a single proposal for the passed bounty
    /// @dev Does bounds checking on index passed, reverts on failure.
    /// @param bountyIndex Index of the bounty in bounties array.
    /// @return array of bools showing which proposals are live, indexed by proposalIndex.
    function getListProposalsForBounty(uint bountyIndex) public view
    returns(bool[MAXPROPOSAL] proposalsLive)
    {
        // Guard values
        require(bountyIndex < MAXBOUNTY, "bountyIndex exceeds MAXBOUNTY");
        
        uint arrayLength = bounties[bountyIndex].proposals.length;
        for (uint i=0; i<arrayLength; i++)
        {
            proposalsLive[i] =  bounties[bountyIndex].proposals[i].isLive;
        }
    }
    
    /// @notice Gets all the fields for a single proposal for the passed bounty
    /// @dev Would prefer to return a struct once Solidity allows it.
    /// @param bountyIndex Index of the bounty in bounties array.
    /// @param proposalIndex Index of the proposal for this bounty in the proposals array.
    function getProposalDetail(uint bountyIndex, uint proposalIndex) public view
    returns(bool risLive, string rdesc, address rproposalOwner, bool risPaid)
    {
        // Guard values
        require(bountyIndex < MAXBOUNTY, "bountyIndex exceeds MAXBOUNTY");
        require(proposalIndex < MAXPROPOSAL, "bountyIndex exceeds MAXPROPOSAL");
        
        ProposalStruct[MAXPROPOSAL] memory pa = bounties[bountyIndex].proposals;
        risLive = pa[proposalIndex].isLive; 
        rdesc = pa[proposalIndex].desc; 
        rproposalOwner = pa[proposalIndex].proposalOwner; 
        risPaid = pa[proposalIndex].isPaid; 
    }
    
    /// @notice Bounty owners can approve proposals they like, which prepares the payment and closes the bounty.
    /// Payee must call makeWithdrawal() after this.
    /// @dev Payment is handled with pull method, so payee must call makeWithdrawal() later.
    /// @param bountyIndex Index of the bounty in bounties array.
    /// @param proposalIndex Index of the proposal for this bounty in the proposals array.    
    function approveProposal(uint bountyIndex, uint proposalIndex) public
    {
        // Guard values
        require(bountyIndex < MAXBOUNTY, "bountyIndex exceeds MAXBOUNTY");
        require(proposalIndex < MAXPROPOSAL, "bountyIndex exceeds MAXPROPOSAL");
        
        // Can only be approved by the bounty owner
        require(msg.sender == bounties[bountyIndex].bountyOwner, "Only the bounty owner can approve a proposal");
        
        // We use pull model for payments
        address luckyProposalOwner = bounties[bountyIndex].proposals[proposalIndex].proposalOwner;
        pendingWithdrawals[luckyProposalOwner] += bounties[bountyIndex].value;
        
        // Regard it as paid (proposal owner can take it whenever)
        bounties[bountyIndex].isLive = true;  // can now re-use this slot
        bounties[bountyIndex].isOpen = false;
        bounties[bountyIndex].proposals[proposalIndex].isLive = false;
        bounties[bountyIndex].proposals[proposalIndex].isPaid = true;
        
        // Log
        emit LogBountyClosedByProposal(bountyIndex, bounties[bountyIndex].desc, proposalIndex, bounties[bountyIndex].proposals[proposalIndex].desc);
    }

    /// @notice Bounty owners can reject proposals they dont like, does not close the bounty.
    /// @dev This frees up space for more proposals.
    /// @param bountyIndex Index of the bounty in bounties array.
    /// @param proposalIndex Index of the proposal for this bounty in the proposals array.    
    function rejectProposal(uint bountyIndex, uint proposalIndex) public
    {
        // Guard values
        require(bountyIndex < MAXBOUNTY, "bountyIndex exceeds MAXBOUNTY");
        require(proposalIndex < MAXPROPOSAL, "bountyIndex exceeds MAXPROPOSAL");
        
        // Can only be rejected by the bounty owner
        require(msg.sender == bounties[bountyIndex].bountyOwner, "Only the bounty owner can reject a proposal");
        
        // Regard proposal as gone, it's slot is now free for someone else to fill
        bounties[bountyIndex].proposals[proposalIndex].isLive = false;
        bounties[bountyIndex].proposals[proposalIndex].isPaid = false;
    }

    /// @notice Bounty hunters (or indeed anyone) can call this to be paid what we owe them 
    /// @dev This function can only run if the function is NOT paused. We use pull payment model.
    function makeWithdrawal() public whenNotPaused
    {
        uint amount = pendingWithdrawals[msg.sender];
        // Remember to zero the pending refund **before** sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
    
    /// @notice Contract owner can call this to delete contract. Funds sent to
    /// contract owner.
    /// @dev The Pausable library itself uses the Open Zeppelin Ownable library, which stores contract owner.
    function kill() public onlyOwner
    {
            selfdestruct(owner);
    }

    /// @dev fallback that allows us to receive simple ether transfers
    function() public payable
    { }
}