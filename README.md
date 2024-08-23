# solarchain-dapp-contracts
Implement project management and project invest and claim

## install dependency, node version >= v16
``` shell
yarn add -g truffle 
yarn add dotenv
yarn add @truffle/hdwallet-provider@2.1.15 -D
yarn add truffle-plugin-verify@0.6.7 -D
```

## compile contract
``` shell
# in root directory, run below command, the compiled json file output to build/contracts
truffle compile
```

## deploy contract to blockchain

1. Erc20TransferProxy
2. NftTransferProxy
3. SolarTbaNft
4. SolarERC1155
5. Build [SolarExchangeV2.sol](https://github.com/Solarchainlabs/solarchain-exchange/projects/exchangev2/contract/SolarExchangeV2.sol)，deploy it
6. SolarFactory
7. SolarDappV2
8. Call SolarFactory, SolarTbaNft, Erc20TransferProxy's function setDappAddress()， set SolarDappV2's address into it
9. Call SolarFactory.createExchangeV2(), create SolarExchangeV2 instance.
10. Call Erc20TransferProxy，NftTransferProxy's function setDappAddress()，set SolarExchangeV2's address into it 
11. Call SolarFactory.setDappAddress(), set NftTransferProxy's address into it
```
# before run bellow command, add the privateKey, bscscanApikey, etherscanApikey, infuraApikey to the .env
truffle migrate --network ethtest  --compile-none # --verbose-rpc
```
## sepolia testnet contract address

```
NftTransferProxy: 0x010E726F3e10805ae315Fd819878E717a3840277
ERC20TransferProxy: 0x5ed86E347653310e2dBF1002001FdCECacE650F0 
SolarTbaNft: 0xaCd60d0699F52f68964C91Bd2271Abd3f528be9a
SolarERC1155-imp: 0xCE5154b47FE79d6a76A9B3e6f628e6a795D48027
SolarFactory: 0x640235afa022D4CA5Ea85DBa438D22985925d49F
SolarDappV2: 0xCf768a330be86B816cf11c7E842b7ffD04EdEADa
SolarExchangeV2-imp: 0x006Bd1A53fc5BB96AB9d3436838b86Ff6C6811e5
SolarExchangeV2: 0xc48272cE6957a423803523BeeaA226A524eD950c
```

## base mainnet contract address

```

NftTransferProxy: 0x797e600D29d27a849CB09C22C36052fB3f04059C
ERC20TransferProxy: 0x2e4d0afde8a9229b800BbdeE8D43867d13164093 
SolarTbaNft: 0xe11190B26132F2377e7979920c41b503f37d8379
SolarERC1155-imp: 0x97ccdb5a4ccf0ee8e52bd4fd959f05f3a5dd82fd
SolarFactory: 0x8be2dd8D61149B5870413e130153c6369cb6De67
SolarDappV2: 0x93b6a2c4e85A8C942f6DFF937De82173A6f2dD73
SolarExchangeV2-imp: 0x8d58f3d13784895d9480d3dfbfe7a2354c386c5b
SolarExchangeV2: 0x248E6724e2da7D874A0930E6Dd38f3c92B6F8528
```