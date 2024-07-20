const ERC20TransferProxy = artifacts.require("ERC20TransferProxy");
const NftTransferProxy = artifacts.require("NftTransferProxy");
const SolarTbaNft = artifacts.require("SolarTbaNft");
const SolarERC1155 = artifacts.require("SolarERC1155");
const SolarFactory = artifacts.require("SolarFactory");
const SolarDappV2 = artifacts.require("SolarDappV2");

module.exports = async function (deployer, network) {
    let paymentTokenAddress;
    let exchangeV2Address;
    if (network == "bsctest") {
        paymentTokenAddress = "0x7848EC33D21561b0755c423C7cf03f5018e18613";
        exchangeV2Address = "0x73315cfE42437063d2a71fEeF9BDd95A64f1309A";
    }else if(network == "ethtest"){
        paymentTokenAddress = "0xBeb74A4dE492c5d64cB90Ce2c68b18661606C380";
        exchangeV2Address = "0xCe42993599260670124f116B96747ED7980F6551";
    }else if(network == "eth"){
        paymentTokenAddress = "0xdAC17F958D2ee523a2206206994597C13D831ec7"
    }
    try {
        await deployer.deploy(ERC20TransferProxy);
        await deployer.deploy(NftTransferProxy);
        await deployer.deploy(SolarTbaNft, "SolarTbaNft", "STN", "https://powerlayer.org/tba/");
        await deployer.deploy(SolarERC1155);
        // 获取 SolarERC1155 的地址
        const solarERC1155Contract = await SolarERC1155.deployed();
        await deployer.deploy(SolarFactory, solarERC1155Contract.address, exchangeV2Address);
        const solarTbaNftContract = await SolarTbaNft.deployed();
        const erc20TransferProxyContract = await ERC20TransferProxy.deployed();
        const solarFactoryContract = await SolarFactory.deployed();
        await deployer.deploy(SolarDappV2, paymentTokenAddress, solarTbaNftContract.address, solarFactoryContract.address, erc20TransferProxyContract.address, 1);
    } catch (err) {
        console.error(`Migration script encountered an error:\n${err.stack}`);
        // throw err;
    }
};
