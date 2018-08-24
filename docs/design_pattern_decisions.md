# Design Pattern Decisions
This documents lists common design patterns and explains why they were or were not used in this dApp. Most were detailed in module 10 lesson 6 of the course.

- [Data Types Used](#data-types-used)
- [Emergency Stop](#emergency-stop)
- [Speed Bump](#speed-bump)
- [Separation of Concerns](#separation-of-concerns)
- [Segregation of Duties](#segregation-of-duties)
- [Off-Chain Computation](#off-chain-computation)
- [Commit-Reveal](#commit-reveal)
- [Fail Early, Fail Loud](#fail-early-fail-loud)
- [Auto Deprecation](#auto-deprecation)
- [Self Destruct](#self-destruct)
- [Pull Payments / Withdrawal Pattern](#pull-payments--withdrawal-pattern)
- [Comments](#comments)
- [Upgradable Contracts](#upgradable-contracts)
- [Scaling](#scaling)

# Data Types Used
Since Solidity does not yet handle dynamic arrays of structs well when passing data to clients, and because we have to consider gas limits, I opted for using fixed size arrays throughout. The pattern then used us to **reuse** array slots when payments are made. This means it is the **event logs** that will provide the full long term history of the contract.
 
# Emergency Stop
An emergency stop was implemented because on a live network we are dealing with real Ether. We do not want mistakes to cost money. An emergency stop does not add much complexity, is simple to implement and can prevent catastrophic loss of funds.

I used the OpenZeppelin contract [Pausable.sol](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol) which allows critical functions to be protected with the `whenNotPaused` modifier. I have protected the critical `makeWithdrawal` function with this modifier. The contract owner pauses the contract (i.e. calls an emergency stop) by calling the `pause` function. Then no funds can be withdrawn until the contract is `unpause`d by the contract owner.

# Speed Bump
A speed bump is a similar notion to emergency stop, just it would allow withdrawals to be slowed whilst a bug was investigated. This was not implemented as I feel emergency stop is enough for this use case.

# Separation of Concerns
A good design pattern is that of separation of concerns. This allows your **data** to be held in one contract and your **functionality** to be held in another. If you then implement [upgradable contracts](#upgradable-contracts), then you can more easily upgrade functionality without affecting data. This is overkill for a small contract like the Haiku market.

# Segregation of Duties
I like the idea of contracts having multiple owners. [CryptoKitties](https://medium.com/loom-network/how-to-code-your-own-cryptokitties-style-game-on-ethereum-7c8ac86a4eb3) did this by having multiple admins, a CEO, COO, and CFO. Functions like emergency stop could be triggered by any "C" level person, but financial funtions could only be triggered by the CFO. This is overkill for a small contract like the Haiku market.

# Off-Chain Computation
It is a good idea to do computation off chain if possible, because Ethereum costs money according to how much work is done per on the EVM. Money could be saved by getting frontends to do complex calculations. However, this was not needed in this contract as all computations are simple. Therefore this design pattern was not used.

# Commit-Reveal
A commit-reveal design pattern is used where a user's intent has to be submitted but remain secret until a later time. This is useful for voting and games like Battleships, but is not needed in this simple Haiku marketplace.

# Fail Early, Fail Loud
This design pattern has been used. Require() is used to validate user input when selecting bounty and proposal indexes, and the transaction will fail if bad input happens. This validation happens at the very start of the functions.

# Auto Deprecation
Contracts can be set to expire after a certain date. This was not implemented for this simple contract as it was felt unnecessary. This design pattern would be better suited to proofs-of-concept, or early access alpha contracts that we know would not be used after a certain date.

# Self Destruct
This was implemented. It does not add complexity and it is a good idea to be able to close down the contract and extract funds quickly if there are catastrophic bugs. The contract owner can call `kill` to withdraw all funds and delete the contract.

# Pull Payments / Withdrawal Pattern
This was implemented. A pull pattern for payments is a good idea as per
http://solidity.readthedocs.io/en/v0.4.24/common-patterns.html. This means that bad actors cannot freeze our contract by having payments to themselves fail - they can only freeze payment to themselves.

# Comments
NatSpec comments have been used throughout, as specified here:
https://github.com/ethereum/wiki/wiki/Ethereum-Natural-Specification-Format. The code is thoroughly commented.

# Upgradable Contracts
A feature of Ethereum blockchain development is the default immutable nature of contracts once they are deployed. Once you deploy a contract to an address its source code is fixed. This is not ideal when you want to fix bugs. [Various approaches](https://blog.indorse.io/ethereum-upgradeable-smart-contract-strategies-456350d0557c) have [been suggested](https://medium.com/cardstack/upgradable-contracts-in-solidity-d5af87f0f913) that allow contract code to be upgraded, but all of them would add a great deal of complexity to the design.

Given this project is relatively simple and not long-lived, I chose not to implement any upgradable design patterns. Long-lived, complex contracts (that therefore are more likely to contain bugs) would be stronger candidates for requiring upgradable code.

# Scaling
To scale this dApp to many thousands of users and above, some redesign would be necessary. Currently, to prevent out of gas problems, fixed size arrays are used for bounties and proposals. Having completed this dApp and done even more research I can see a different way to approach the design that may better support scaling.

A different approach would be to store bounties in a mapping like this:

```
mapping(uint => BountyStruct) private bountyMap;
```

This way, there could be as many bounties as there are uints. This change would bring its own challenges:

* Of course, since we cannot iterate over a mapping, we'd have to maintain an index in an array holding just the active bounties as outlined [here](https://medium.com/@robhitchens/solidity-crud-part-1-824ffa69509a).
* We would also have the challenge of passing to the UI an unknown number of bounties to display. We could manage this by sending data in fixed size pages and use a fixed size array together with a page number variable.

The above is achievable but given the significant added complexity and limited time available, I chose not to implement it.