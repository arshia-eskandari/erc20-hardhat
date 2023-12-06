import { ethers } from "hardhat";
import dotenv from "dotenv";
dotenv.config();

async function main() {
  const ERC20 = await ethers.getContractFactory("ERC20");
  const erc20 = await ERC20.deploy(
    "test",
    "TEST",
    18,
    2,
    process.env.FEE_RECEIVER,
    1_000_000_000_000_000,
    process.env.OWNER
  );
  const address = await erc20.getAddress();
  console.log("ERC20 deployed to ", address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
