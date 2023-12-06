import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture, mine } from "@nomicfoundation/hardhat-network-helpers";

describe("ERC20", function () {
  async function deployAndMockERC20() {
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
    await mine(); // mines blocks

    return {
      alice,
      bob,
      testFeeReceiver,
      testOwner,
      erc20Token,
    };
  }

  it("transfer tokens correctly", async function () {
    const { alice, bob, testFeeReceiver, erc20Token } =
      await loadFixture(deployAndMockERC20);
    await expect(
      await erc20Token.transfer(bob.address, BigInt(100e18)) // uses the first account as sender
    ).to.changeTokenBalances(
      erc20Token,
      [alice, bob, testFeeReceiver],
      [BigInt(-100e18), BigInt(98e18), BigInt(2e18)]
    );

    await expect(
      await (erc20Token.connect(bob) as any).transfer(
        alice.address,
        BigInt(50e18)
      ) // uses the first account as sender
    ).to.changeTokenBalances(
      erc20Token,
      [alice, bob, testFeeReceiver],
      [BigInt(49e18), BigInt(-50e18), BigInt(1e18)]
    );

    // const aliceBalance = await erc20Token.balanceOf(alice.address);
    // const bobBalance = await erc20Token.balanceOf(bob.address);
    // const testFeeReceiverBalance = await erc20Token.balanceOf(
    //   testFeeReceiver.address
    // );

    // await expect(aliceBalance).to.equals(BigInt(200e18));
    // await expect(bobBalance).to.equals(BigInt(98e18));
    // awiat expect(testFeeReceiverBalance).to.equals(BigInt(2e18));
  });

  it("should revert if sender has insufficient balance", async function () {
    const { bob, erc20Token } = await loadFixture(deployAndMockERC20);
    await expect(
      erc20Token.transfer(bob.address, BigInt(400e18)) // uses the first account as sender
    ).to.be.revertedWith("Insufficient balance");
  });

  it("should emit transfer events", async function () {
    const { alice, bob, testFeeReceiver, erc20Token } =
      await loadFixture(deployAndMockERC20);
    await expect(
      erc20Token.transfer(bob.address, BigInt(100e18)) // uses the first account as sender
    )
      .to.emit(erc20Token, "Transfer")
      .withArgs(alice.address, testFeeReceiver.address, BigInt(2e18))
      .to.emit(erc20Token, "Transfer")
      .withArgs(alice.address, bob.address, BigInt(98e18));
  });
});
