# Avoiding Common Attacks
This document explains what measures I took to ensure that contracts are not susceptible to common attacks as described in Module 9 Lesson 3 (Safety Checklist, and its associated links and quiz) plus Module 10 Lesson 7 (Exploits and Dangers).

Each attack is listed below, along with an explanation of whether it applies, and what has been done to mitigate the risk.

- [Logic Bugs](#logic-bugs)
- [No Recursion](#no-recursion)
- [Integer Overflow and Underflow](#integer-overflow-and-underflow)
- [Use Proven Libraries](#use-proven-libraries)
- [Beware Poisoned User Input](#beware-poisoned-user-input)
- [Exposed Functions](#exposed-functions)
- [Exposed Secrets](#exposed-secrets)
- [Timestamp Vulnerabilities](#timestamp-vulnerabilities)
- [Powerful Admins](#powerful-admins)
- [Off Chain Security](#off-chain-security)
- [Cross Chain Replay](#cross-chain-replay)
- [The tx.origin Problem](#the-txorigin-problem)
- [Gas Limits](#gas-limits)
- [Race Conditions and Reentrancy](#race-conditions-and-reentrancy)
- [Transaction-Ordering Dependence (TOD) / Front Running](#transaction-ordering-dependence-tod--front-running)
- [DoS with (Unexpected) revert](#dos-with-unexpected-revert)
- [Forcibly Sending Ether to a Contract](#forcibly-sending-ether-to-a-contract)

# Logic Bugs
Logic bugs can be minimized by comprehensive automated unit testing. This I have tried to do. I have also tried to avoid complexity, see [design pattern decisions](./design_pattern_decisions.md).

# No Recursion
There are no recursive functions.

# Integer Overflow and Underflow
I have used `uint` throughout, which is an unsigned integer with 256 bits, and is more than enough to contain any value. For array access, bounds checking always happens.

# Use Proven Libraries 
I have used some OpenZeppelin contract code, this is a proven high quality source of code and the contracts I used are quite simple.

# Beware Poisoned User Input
All array access is bounds checked before arrays are read. I accept there is a risk with users entering absurdly long strings. The UI does protect this somewhat as it does constrain string length but of course bad actors can bypass this. The real solution is to truncate strings in Solidity but I was not able to find a simple way to do this, the only solution I could find required low level assembly and I realised the risk too late in the project to implement it (after doing all my testing and Rinkeby deployments). So I accept string length is a risk, and with more time I could protect it.

# Exposed Functions
This is not a concern in this contract. Most functions are designed to be public, some functions in the libraries I used are not, but there is no security risk.

# Exposed Secrets
This is not a concern in this contract. It is true that people could copy other Haiku and claim they wrote it, but the bounty owner knows this and can regard the first proposals (those with smaller indexes) as being there first. Analysis of the logs would also determine when a proposal was received.

# Timestamp Vulnerabilities
This contract does not use timestamps.

# Powerful Admins
I like the idea of having multiple admins like a company having a CIO, CFO, COO like [CryptoKitties](https://medium.com/loom-network/how-to-code-your-own-cryptokitties-style-game-on-ethereum-7c8ac86a4eb3) does. However, this increased complexity was not required in our simple Haiku contract case and this was not implemented.

# Off Chain Security
I acknowlege the requirement for good off chain security behaviours that are required for any IT environment. This includes being careful with who can access systems, keeping audit trails of sensetive system access, good password behaviours, awareness of social engineering risks and so on.

# Cross Chain Replay
This is [tricky](http://hackingdistributed.com/2016/07/17/cross-chain-replay/), and I don't see a simple solution to it. One idea is to clear down the market arrays manually after a fork. So imagine a hard fork happens. The date and time of this is known well in advance. A contract admin could wait until *after the fork happened*, then:
* clear down the `bounties[]` array (clear all entries, making them zero or initial values).
* force send Ether to all job hunters who have not made withdrawals.
* return any Ether to bounty posters who have not received any submissions.
The goal is to "reset" the contract data to it's empty state. we'd have to actually upgrade the contract itself to do this, as more functions would be needed. I accept this as a risk, and with more work it could be mitigated.

# The tx.origin Problem
I do not use tx.origin in the contract code.

# Gas Limits
I use fixed length arrays. There is some array iteration happening in code, but only single records are changed in a single tranaction. There are no transactions that could change entire arrays, for example.

# Race Conditions and Reentrancy
I do not believe this can happen in this contract. There are no external contract calls, payments are made using the pull method and where I have calls that may fail (eg there is a transfer call made in function `makeWithdrawal()` in the [main contract](../contracts/BountyMarketHaiku.sol)) I always make sure it is the last function called.
This follows the advice:
> we have recommended finishing all internal work first, and only then calling the external function. This rule, if followed carefully, will allow you to avoid race conditions. However, you need to not only avoid calling external functions too soon, but also avoid calling functions which call external functions.

# Transaction-Ordering Dependence (TOD) / Front Running
I do not believe this can happen in this contract. If corrupt miners were to collect up many transactions and fiddle with the order before submitting a block I do not believe the contract could suffer.

# DoS with (Unexpected) revert
I do not believe this can happen in this contract. There are no external contract calls, payment are made using pull method and where I have calls that may fail (eg there is a transfer call made in function `makeWithdrawal()` in the [main contract](../contracts/BountyMarketHaiku.sol)) I always make sure it is the last function called.

# Forcibly Sending Ether to a Contract
It does not matter if anyone sends extra Ether to the contract. There is no code that assumes the contract balance must start at zero.
