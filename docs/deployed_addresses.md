# Deployed Addresses
Deploy your application onto the Rinkeby test network. Include a document called deployed_addresses.txt that describes where your contracts live on the test net.

## Deployed Contract 
The [flattened contract](/remix/BountyMarketHaikuFlattened.sol) was deployed to Rinkeby with [this transaction](https://rinkeby.etherscan.io/tx/0xf7761edce851a397109df5a3178ce9aaf1fa7c4f801a14df5ce6ebb9b35e6090). Here, you can see the deployed contract with verified source code:
https://rinkeby.etherscan.io/address/0x3d8d27e0577d4e4f2dfdcf772a7f556a9036d21f#code

Notice the first two contracts in the source are the OpenZeppelin contracts for Ownable and Pausable. From line 110 you can see the BountyMarketHaiku contract itself.

## Interacting with the Deployed Contract
Interact with it in Remix (paste in code found in folder /remix/BountyMarketHaikuFlattened.sol) or use the Etherscan "Write Contract" beta:
https://rinkeby.etherscan.io/address/0x3d8d27e0577d4e4f2dfdcf772a7f556a9036d21f#writeContract

In both cases, use MetaMask to connect to Rinkeby. You can get Ether on Rinkeby by using the official faucet: https://faucet.rinkeby.io/. Remember transaction processing can be much slower on Rinkeby that the live network, and of course is always much slower then a local dev blockchain.

## Constraints
My JavaScript knowledge was not sufficient to let me configure the UI to work with this Rinkeby deployed contract in the time available.