import { ethers } from "hardhat";

describe("ERC20", function () {
  it("transfer tokens correctly", async function () {
    const [alice, bob, testFeeReceiver, testOwner] = await ethers.getSigners();
    const ERC20 = await ethers.getContractFactory("ERC20Mock");
    const erc20Token = await ERC20.deploy(
      "name",
      "SYM",
      18,
      2,
      testFeeReceiver.address,
      1_000_000_000_000_000,
      testOwner.address
    );

    await erc20Token.mockMint(alice.address, BigInt(300e18));
    await erc20Token.transfer(bob.address, BigInt(100e18));
  });
});
