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
5. Build https://github.com/Solarchainlabs/solarchain-exchange/projects/exchangev2/contract/SolarExchangeV2.sol，deploy it
6. SolarFactory
7. SolarDappV2
8. Call SolarFactory, SolarTbaNft, Erc20TransferProxy's function setDappAddress()， set SolarDappV2's address into it
9. Call SolarFactory.createExchangeV2(), create SolarExchangeV2 instance.
10. Call Erc20TransferProxy，NftTransferProxy's function setDappAddress()，set SolarExchangeV2's address into it 
11. Call SolarFactory.setDappAddress(), set NftTransferProxy's address into it
```
# before run bellow command, add the privateKey, bscscanApikey, etherscanApikey, infuraApikey to the .env
truffle migrate --network bsctest  --compile-none # --verbose-rpc
```
## sepolia testnet contract address

```
NftTransferProxy: 0x010E726F3e10805ae315Fd819878E717a3840277
ERC20TransferProxy: 0x5ed86E347653310e2dBF1002001FdCECacE650F0 
SolarTbaNft: 0xb9dc61A6d05CA7E6edF47DA9289cFE6dF06cC912
SolarERC1155: 0x28AF06c355FE924D7484da1adf295744942bDE1F
SolarFactory: 0x640235afa022D4CA5Ea85DBa438D22985925d49F
SolarDappV2: 0xCe42993599260670124f116B96747ED7980F6551
SolarExchangeV2-imp: 0x006Bd1A53fc5BB96AB9d3436838b86Ff6C6811e5
SolarExchangeV2: 0x49E54c6b94214e0668C7EA22555BAC78376E4C59
```
