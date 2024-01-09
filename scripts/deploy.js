async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
    //console.log("Account balance:", (await deployer.provider.getBalance()).toString());
    const Token = await ethers.getContractFactory("MGGGiftGachaMof");
    const token = await Token.deploy();
    console.log("Token address:", token.address);
}
main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});