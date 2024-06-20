const HDWalletProvider = require('@truffle/hdwallet-provider');
require('dotenv').config(); 
module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 9545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
     },
     bsctest: {
       provider: () => new HDWalletProvider(
        {
          privateKeys:[process.env.privateKey],
          providerOrUrl: 'https://rpc.ankr.com/bsc_testnet_chapel',
          pollingInterval: 30000
        }),
       network_id: 97,
       confirmations: 2,
       timeoutBlocks: 200,
       gasPrice: 10000000000,
       networkCheckTimeout: 600000,
       skipDryRun: true
     },
     ethtest: {
       provider: () => new HDWalletProvider(
       {
         privateKeys:[process.env.privateKey],
         providerOrUrl: 'https://mainnet.infura.io/v3/'+process.env.infuraApikey,
         pollingInterval: 30000
       }),
       network_id: 11155111,
       confirmations: 2,
       timeoutBlocks: 200,
       skipDryRun: true,
       gasPrice: 10000000000,
       networkCheckTimeout: 600000,
     }
  },

  // Set default mocha options here, use special reporters, etc.
  mocha: {
    // timeout: 100000
  },

  compilers: {
    solc: {
      version: "0.8.20",
      settings: {
        optimizer: {
          enabled: true,
          runs: 1,
        },
        "viaIR":false
      },
    },
  },
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    bscscan: process.env.bscscanApikey,
    etherscan: process.env.etherscanApikey
  }

};
