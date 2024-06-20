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
