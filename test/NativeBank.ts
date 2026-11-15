import hre from "hardhat";
import { NativeBank } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai"
import { DECIMALS } from "./constant";

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

    const unitParser = (amount: string) =>
        hre.ethers.parseUnits(amount, DECIMALS);
    const unitFormatter = (amount: bigint) =>
        hre.ethers.formatUnits(amount, DECIMALS);
    const getBalance = async (address: string) => unitFormatter(
        await hre.ethers.provider.getBalance(address)
    );
    
    it("exploit", async () => {
        const victim1 = signers[1];
        const victim2 = signers[2];
        const hacker = signers[3];

        const exploitC = await hre.ethers.deployContract(
            "Exploit",
            [await nativeBancC.getAddress()],
            hacker
        );
        const hCAddr = await exploitC.getAddress();
        const stakingAmount = unitParser("1");
        const v1Tx = {
            fromJ: victim1.address,
            to: await nativeBancC.getAddress(),
            value: stakingAmount
        };
        const v2Tx = {
            fromJ: victim1.address,
            to: await nativeBancC.getAddress(),
            value: stakingAmount
        };
        await victim1.sendTransaction(v1Tx);
        await victim2.sendTransaction(v2Tx);

        console.log(await getBalance(hCAddr));
        await exploitC.exploit({ value: stakingAmount });
        console.log(await getBalance(hCAddr));
    });
});