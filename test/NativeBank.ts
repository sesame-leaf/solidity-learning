import hre from "hardhat";
import { NativeBank } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai"

describe("NativeBank", () => {
    let signers:HardhatEthersSigner[];
    let nativeBancC:NativeBank;
    beforeEach("Deploy NativeBank contract", async () => {
        nativeBancC = await hre.ethers.deployContract("NativeBank");
        signers = await hre.ethers.getSigners();

    });
    it("Should send native token to contract", async () => {
        const staker = signers[0];

        const tx = {
            from: staker.address,
            to: await nativeBancC.getAddress(),
            value: hre.ethers.parseEther("1"),
        };
        const txResp = await staker.sendTransaction(tx);
        const txReceipt = await txResp.wait();
        console.log(
            await hre.ethers.provider.getBalance(await nativeBancC.getAddress())
        );

        console.log(
            await nativeBancC.balanceOf(staker.address)
        );
    });

    it("Should withdraw all the tokens", async () => {
        const staker = signers[0];
        const stakingAmount = hre.ethers.parseEther("10");
        const tx = {
            from: staker.address,
            to: await nativeBancC.getAddress(),
            value: stakingAmount
        }
        const sentTx = await staker.sendTransaction(tx);
        sentTx.wait();
        expect(await nativeBancC.balanceOf(staker.address)).equal(stakingAmount);

        await nativeBancC.withdraw();
        expect(await nativeBancC.balanceOf(staker.address)).equal(0n);
    });
});