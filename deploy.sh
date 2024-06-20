#!/bin/bash
truffle compile
truffle migrate --network bsctest  --compile-none # --verbose-rpc
truffle run verify ERC20TransferProxy NftTransferProxy SolarTbaNft SolarERC1155 SolarFactory SolarDappV2 --network bsctest
