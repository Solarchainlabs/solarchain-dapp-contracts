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
SolarDappV2: 0xcAc1F814170972EC8B7955e21305f181E4a5ab85
SolarExchangeV2-imp: 0x006Bd1A53fc5BB96AB9d3436838b86Ff6C6811e5
SolarExchangeV2: 0x049d434575bC5A349FF9583D3aB33275d167Fdb9
```
