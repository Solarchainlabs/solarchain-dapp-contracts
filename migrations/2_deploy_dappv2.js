const ERC20TransferProxy = "0x7053d9189478bf5E67c23eA61aB6E98600c09c10";
const SolarTbaNft = "0xC118435ce1B44bc6B6ae1c937853D6Ba2539201B";
const SolarFactory = "0x6c32fBbb5F84C559bCeEf54ed25B2fD0d9C9eAd9";
const SolarDappV2 = artifacts.require("SolarDappV2");

module.exports = async function (deployer, network) {
    let paymentTokenAddress;
    let exchangeV2Address;
    if (network == "bsctest") {
        paymentTokenAddress = "0x7848EC33D21561b0755c423C7cf03f5018e18613";
        exchangeV2Address = "0x73315cfE42437063d2a71fEeF9BDd95A64f1309A";
    }else if(network == "ethtest"){
        paymentTokenAddress = "0xBeb74A4dE492c5d64cB90Ce2c68b18661606C380";
        exchangeV2Address = "0x0e85aD98aF2bEbeA148c48BA3Ee0D8CD19b8023e";
    }else if(network == "eth"){
        paymentTokenAddress = "0xdAC17F958D2ee523a2206206994597C13D831ec7"
    }
    try {
        await deployer.deploy(SolarDappV2, paymentTokenAddress, SolarTbaNft, SolarFactory, ERC20TransferProxy, 10000);
    } catch (err) {
        console.error(`Migration script encountered an error:\n${err.stack}`);
        // throw err;
    }
};
