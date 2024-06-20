# solarchain-dapp-contracts
Implement project management and project invest and claim

## install dependency, node version >= v16
``` shell
yarn add -g truffle 
yarn add dotenv
yarn add @truffle/hdwallet-provider@2.1.15 -D
yarn add @truffle/hdwallet-provider@0.6.7 -D
```

## compile contract
``` shell
# in root directory, run below command, the compiled json file output to build/contracts
truffle compile
```

## deploy contract to blockchain
```
# before run bellow command, add the privateKey, bscscanApikey, etherscanApikey, infuraApikey to the .env
truffle migrate --network bsctest  --compile-none # --verbose-rpc
```