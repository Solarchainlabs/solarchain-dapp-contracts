const ERC20TransferProxy = artifacts.require("ERC20TransferProxy");
const NftTransferProxy = artifacts.require("NftTransferProxy");
const SolarTbaNft = artifacts.require("SolarTbaNft");
const SolarERC1155 = artifacts.require("SolarERC1155");
const SolarERC1155Factory = artifacts.require("SolarERC1155Factory");
const SolarDappV2 = artifacts.require("SolarDappV2");
const paymentTokenAddress = "0x7848EC33D21561b0755c423C7cf03f5018e18613";

module.exports = async function (deployer) {
    try {
        await deployer.deploy(ERC20TransferProxy);
        await deployer.deploy(NftTransferProxy);
        await deployer.deploy(SolarTbaNft, "SolarTbaNft", "STN", "https://powerlayer.org/tba/");
        await deployer.deploy(SolarERC1155);
        // 获取 SolarERC1155 的地址
        const solarERC1155Contract = await SolarERC1155.deployed();
        await deployer.deploy(SolarERC1155Factory, solarERC1155Contract.address);
        const solarTbaNftContract = await SolarTbaNft.deployed();
        const erc20TransferProxyContract = await ERC20TransferProxy.deployed();
        const solarERC1155FactoryContract = await SolarERC1155Factory.deployed();
        await deployer.deploy(SolarDappV2, paymentTokenAddress, solarTbaNftContract.address, solarERC1155FactoryContract.address, erc20TransferProxyContract.address, 1);
    } catch (err) {
        console.error(`Migration script encountered an error:\n${err.stack}`);
        // throw err;
    }
};
