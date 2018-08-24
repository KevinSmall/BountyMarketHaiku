# Bounty Market for Haiku
A Bounty dApp for Haiku Poetry by Kevin Small (kevin_small@hotmail.com). Part of the ConsenSys Academy Ethereum Developer Program Class of 2018.

# Contents
- [What does this project do?](#what-does-this-project-do)
- [User Stories](#user-stories)
- [How to Set Up the Project](#how-to-set-up-the-project)
  - [Prerequisites](#prerequisites)
  - [Install Node Modules](#install-node-modules)
- [How to Compile, Migrate and Test Contracts](#how-to-compile-migrate-and-test-contracts)
  - [Automated Tests](#automated-tests)
  - [Further Testing with Remix (Optional)](#further-testing-with-remix-optional)
- [User Interface](#user-interface)
- [Design Patterns](#design-patterns)
- [Security Tools and Common Attacks](#security-tools-and-common-attacks)
- [Other](#other)
  - [Use a Library](#use-a-library)
  - [Deploy to Rinkeby](#deploy-to-rinkeby)

# What does this project do?
This bounty dApp aims to be the leading (and only!) marketplace in the world for people to request and offer **Haiku poetry**. A [Haiku](https://en.wikipedia.org/wiki/Haiku) is a form of very short poem, usually only three lines. It has a long history tracing back to Japan in the 1600s. In this app, line breaks are shown as a forward slash /.

Here are two Haiku examples. This first one is about grass:

> Freshly mown grass / clinging to my shoes / my muddled thoughts.

This one is about the sea:

> As invading waves / retreat from the sandy shores / treasures are revealed.

# User Stories
There are two user groups involved. **Job posters** post up requests for Haiku on their favoured topic, along with some Ether. **Bounty hunters** can then write and propose a Haiku and if accepted they can then withdraw the Ether bounty.
* As a job poster, I can create a new bounty offering Ether for someone to write me a Haiku on a topic of my choice.
* I will set a bounty description and include the amount to be paid for a successful submission.
* I am able to view a list of bounties that I have already posted that are still unpaid.
* By clicking on a bounty, I can review submissions that have been proposed.
* I can accept or reject the submitted work.
* Accepting proposed work will pay the submitter the deposited amount.
* As a bounty hunter, I can submit work to a bounty for review.

# How to Set Up the Project
To setup the project, download it to a folder of your choice. The project is a truffle project. The project folder structure is as follows:

```
BountyMarketHaiku
+ contracts    - Main Contracts
+ docs         - Documentation files
+ migrations   - Migration definitions
+ remix        - A flattened version of the contract, used to deploy to Rinkeby
+ src          - Frontend UI
+ test         - Contracts for automated testing
```
Some other folders are not delivered, but will get built later:

```
BountyMarketHaiku
+ build        - Build files for contracts (built by Truffle later)
+ node_modules - Node modules for libraries, lite-server (built by npm later)
```
If you experience any difficulties during the install or set up of the project, feel free to email me kevin_small@hotmail.com and I may be able to help.

## Prerequisites
You should have `node`, `npm` (which comes with node) and `truffle` installed. To verify that Truffle is installed properly, type `truffle version` in a shell / command prompt. If you see an error follow the instructions on [how to setup the development environment](
https://truffleframework.com/tutorials/pet-shop#setting-up-the-development-environment) on the Truffle site.

## Install Node Modules
Open a command prompt and navigate to the root folder of the downloaded project (this is the folder with the `truffle.js` file in it). Run **npm install**:
```
> npm install
```
You may see some warnings. Eventually the packages will install and you will see something like this:
```
added 226 packages from 199 contributors and audited 570 packages in 21.306s
```

# How to Compile, Migrate and Test Contracts
Now you can test the contracts. The following steps may be familiar to you:
1) Open a command prompt and run **ganache-cli**, which should listen on port **8545** (the default):
```
> ganache-cli
```
2) Once ganache-cli is running, navigate to the root folder of the downloaded project (this is the folder with the `truffle.js` file in it).
3) Open a shell / command prompt in this folder.
4) Compile contracts by running:
```
> truffle compile
```
5) Then migrate the contracts by running:
```
> truffle migrate
```
6) Then execute the automated tests. Run:
```
> truffle test
```
This will compile and migrate the contracts and run the automated tests. Details of the automated tests are described in the next section.

## Automated Tests
Tests are written in Solidity and are in the `test` folder. The following tests exist:

### Test 1. testContractHasMoney
This tests that the contract can hold value successfully. The contract is given some Ether at deployment time using a Truffle feature, then we check that the Ether is present.

### Test 2. testUserCanCreateBounty
This tests that a user can create a new bounty using `createBounty()` successfully. The test creates a bounty, then retrieves the bounty data back again using `getBountyDetail()` and checks the expected and actual bounty details match. 
   
### Test 3. testUserCanCreateProposal
This tests that the user can create a new proposal using `createProposal()` successfully. The test creates a proposal, then retrieves its details using `getProposalDetail()` and checks the expected and actual proposal details match.
  
### Test 4. testUserCanApproveProposal
This tests that a user can approve a proposal. Since we created the bounty also, we can do it. The test calls `approveProposal()` and then checks the bounty flag `isPaid` to see if the approval worked.
   
### Test 5. testCheckCurrentPauseState
This tests that the contract has a current pause state (emergency stop) of off.
    
### Test 6. testUserCannotPause
This tests that the current user (a Truffle test user) cannot switch on the emergency stop, because they did not create the original contract. This involves catching the revert/throw from the checks made by the [Pausable library](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol) used. This is done using techniques outlined in a [Medium article](https://medium.com/@kscarbrough1/writing-solidity-unit-tests-for-testing-assert-require-and-revert-conditions-using-truffle-2e182d91a40f).

### Test 7. testUserCannotKill
This tests that the current user (test user) cannot kill the contract, because they did not create original contract. This uses the same techniques as test 6. above.

The tests are executed by running:
```
> truffle test
```
The output should be something like this:
```
Using network 'development'.

Compiling .\contracts\BountyMarketHaiku.sol...
Compiling .\test\TestBountyMarketHaiku.sol...
Compiling openzeppelin-solidity/contracts/lifecycle/Pausable.sol...
Compiling openzeppelin-solidity\contracts\ownership\Ownable.sol...
Compiling truffle/Assert.sol...
Compiling truffle/DeployedAddresses.sol...

  TestBountyMarketHaiku
    √ testContractHasMoney (88ms)
    √ testUserCanCreateBounty (123ms)
    √ testUserCanCreateProposal (202ms)
    √ testUserCanApproveProposal (118ms)
    √ testCheckCurrentPauseState (80ms)
    √ testUserCannotPause (95ms)
    √ testUserCannotKill (94ms)

  7 passing (2s)
```
### Challenges Faced During Testing
I wanted to write all tests in Solidity. I could not find any easy way to switch to use different addresses using Solidity tests. For example, I would have liked to switch account and test that a proposal approval would fail because the address was not the address who created the bounty. This is why I did some manual testing in Remix, as described in the next section.

## Further Testing with Remix (Optional)
This section is optional. I added this section because I wanted to test some additional scenarios that I could not cover in automated Solidity tests alone, such as switching accounts. If you wish to see this too, you can interact with the contract in Remix in your local JavaScript VM.

1. Open [Remix](http://remix.ethereum.org/).
2. Copy and paste [contracts/contracts.sol](/contracts/BountyMarketHaiku.sol) into a new Remix contract.
3. Remove the comment on line 6 of the contract.
4. Comment out line 8 of the contract.
5. Deploy to JavaScript VM.
6. From Remix you can switch accounts and interact with all functions.

# User Interface
See the [User Interface](/docs/user_interface.md) document in the `docs` folder. This explains how to run and test the UI.

# Design Patterns
See the [Design Pattern Decisions](/docs/design_pattern_decisions.md/) document in the `docs` folder. This explains the design decisions made.
 
# Security Tools and Common Attacks
See the [Avoiding Common Attacks](/docs/avoiding_common_attacks.md) document in the `docs` folder. This document explains the measures taken to ensure that the contracts are not susceptible to common attacks.

# Other
Some other requirements were outlined in the project requirements document.
## Use a Library
This project makes use of an [Open Zeppelin library](https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/lifecycle/Pausable.sol) to handle the **emergency stop** design pattern. See contract `BountyMarketHaiku.sol`, at the top is this line:

```
// Library to allow emergency stop pattern
...
import "openzeppelin-solidity/contracts/lifecycle/Pausable.sol";
```
More detail is given in the [Design Pattern Decisions](/docs/design_pattern_decisions.md#emergency-stop) document.

## Deploy to Rinkeby
The application has been deployed onto the Rinkeby test network [here](https://rinkeby.etherscan.io/address/0x3d8d27e0577d4e4f2dfdcf772a7f556a9036d21f#code). For more details, see the document called [Deployed Addresses](/docs/deployed_addresses.md) in the `docs` folder that describes where the contracts live on the test net.

