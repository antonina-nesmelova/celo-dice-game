## Celo Dice Game

cDG is blockchain based web-casino with single game. Player can guess dice number, if his guess will be correct, player own 6 times more then he bet. Owner can deposit and withdraw cUSD from the contract. 

Random number is generated from players wallet address, block timestamp and salt, which can be changed by owner.

# Live demo

[https://xnesme00.github.io/celo-dice-game/](https://xnesme00.github.io/celo-dice-game/)

# Install

```

npm install

```

or 

```

yarn install

```

# Start

```

npm run dev

```

# Build

```

npm run build

```
# Usage
1. Install the [CeloExtensionWallet](https://chrome.google.com/webstore/detail/celoextensionwallet/kkilomkmpmkbdnfelcpgckmpcaemjcdh?hl=en) from the google chrome store.
2. Create a wallet.
3. Go to [https://celo.org/developers/faucet](https://celo.org/developers/faucet) and get tokens for the alfajores testnet.
4. Switch to the alfajores testnet in the CeloExtensionWallet.

# Test

1. Deposit some cUSD to contract by owner.
2. Change account, choose bet and amount, roll dice.
3. Switch account back to owner, withdraw funds.