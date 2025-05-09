# LinkPortal for Evm Contracts

- **The Real world Assets to on-chain link trading portal platform**

## Introduction

As blockchain technology rapidly evolves, the tokenization of Real-World Assets (RWAs) is transforming how we access, trade, and manage assets. Our project aims to establish an efficient, transparent, and cost-effective platform that connects liquidity providers with investors, facilitating the tokenization of RWAs and promoting their global trading. This platform leverages the advantages of blockchain technology to deliver unprecedented financial services experiences.

### Build

```bash
forge build
```

### Test

```bash
forge test
```

### Format

```bash
forge fmt
```

### Gas Snapshots

```bash
forge snapshot
```

### Anvil

```bash
anvil
```

### Deploy

```bash
# see: https://dashboard.alchemy.com/apps/ivsvjp8jwo22wv89/setup
forge script script/Counter.s.sol:CounterScript --rpc-url https://eth-sepolia.g.alchemy.com/v2/M8QUxbFISVXMqMxvWWKx-N2cxUJF9jmD --private-key ${SEPOLIA_PRIVATE_KEY_1}
```

### Cast

```bash
cast <subcommand>
```

### Help

```bash
forge --help
anvil --help
cast --help
```

## Testnet Deployment information

### Deployed on Ethereum Sepolia Testnet information

- RealEstateToken address: `0x785c39713f52194cabf517c0f5d21c3e0ee227ec` deploy by tx: [https://sepolia.etherscan.io/tx/0x2efeaa44480bd8330e60d34380bfc523ed5d6ecd57638725104cb33d4f4d2b69](https://sepolia.etherscan.io/tx/0x2efeaa44480bd8330e60d34380bfc523ed5d6ecd57638725104cb33d4f4d2b69)

- Issuer address: `0xD34eEe2cAFb778A93234B778f483D7847ECe3630`, [https://sepolia.etherscan.io/tx/0x4153357400a2489cf5ad719c567e7159eb86de74500a3c5f275d87e02be35050](https://sepolia.etherscan.io/tx/0x4153357400a2489cf5ad719c567e7159eb86de74500a3c5f275d87e02be35050)

- Tokenization Assets of House on testnet OpenSea(ERC-1155): [https://testnets.opensea.io/zh-CN/assets/sepolia/0x785c39713f52194cabf517c0f5d21c3e0ee227ec/0](https://testnets.opensea.io/zh-CN/assets/sepolia/0x785c39713f52194cabf517c0f5d21c3e0ee227ec/0)

- RwaLending address: `0xace3D1CAe7868a4f0daB72506fb41BA964fDbc61` deploy by tx: [https://sepolia.etherscan.io/tx/0x3be72c85e436f4db584fe834f5b8689fa84a3a124a2f1c0824d0bcd85735ee7d](https://sepolia.etherscan.io/tx/0x3be72c85e436f4db584fe834f5b8689fa84a3a124a2f1c0824d0bcd85735ee7d)

- EnglishAuction address: `0xF0Ac2df4Aaf19d7537f90347C64cC9ebf2549Dd1` deploy by tx: [https://sepolia.etherscan.io/tx/0x8e2d3ce8108fa71de2c62fc310bb3911914c0ba2bcdd8ae4022c8790f1e9d89d](https://sepolia.etherscan.io/tx/0x8e2d3ce8108fa71de2c62fc310bb3911914c0ba2bcdd8ae4022c8790f1e9d89d)

### Dependent Chainlink and Third-party information

- Chinalink Function Subscription `3815`: [https://functions.chain.link/sepolia/3815](https://functions.chain.link/sepolia/3815), for more information see:
  - [Chainlink CCIP ethereum-testnet-sepolia](https://docs.chain.link/ccip/directory/testnet/chain/ethereum-testnet-sepolia)
  - [Chainlink Functions ethereum-testnet-sepolia](https://docs.chain.link/chainlink-functions/supported-networks#sepolia-testnet)

- Chainlink Automation Registry address: `0x86EFBD0b6736Bed994962f9797049422A3A8E8Ad`: [https://automation.chain.link/sepolia/67709812638333630167339319869842525913904496528132491077497183191721555041670](https://automation.chain.link/sepolia/67709812638333630167339319869842525913904496528132491077497183191721555041670)

- Chainlink Data-Feed USDC/USD on Ethereum Sepolia address: `0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E`, [https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1#sepolia-testnet](https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1#sepolia-testnet)

- USDC on Ethereum Sepolia address: `0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238`, [https://sepolia.etherscan.io/address/0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238](https://sepolia.etherscan.io/address/0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238), USDC on ther chains addresses:
  [https://developers.circle.com/stablecoins/usdc-on-test-networks](https://developers.circle.com/stablecoins/usdc-on-test-networks)
