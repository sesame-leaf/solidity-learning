import hre from "hardhat";
import { expect } from "chai";
import { MyToken } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers"

const mintingAmount = 100n;
const decimals = 18n;

describe("My Token", () => {
    let myTokenC:MyToken;
    let signers:HardhatEthersSigner[];
    beforeEach("should deploy", async () => {
        myTokenC = await hre.ethers.deployContract("MyToken", [
            "MyToken",
            "MT",
            decimals,
            mintingAmount,
        ]);
        signers = await hre.ethers.getSigners();
    });
    describe("Basic state value check", () => {
        it("should return name", async () => {
            expect(await myTokenC.name()).equal("MyToken");
        });
        it("should return symbol", async () => {
            expect(await myTokenC.symbol()).equal("MT");
        });
        it("should return decimals", async () => {
            expect(await myTokenC.decimals()).equal(decimals);
        });
        it("should return 100 totalSupply", async () => {
            expect(await myTokenC.totalSupply()).equal(
                mintingAmount * 10n ** decimals
            );
        });
    });
    // 1MT = 1 * 10^18
    describe("Mint", () => {
        it("should return 100MT balance for signer 0", async () => {
            const signer0 = signers[0];
            expect(await myTokenC.balanceOf(signer0)).equal(
                mintingAmount * 10n ** decimals
            );
        });
    });
    describe("Transfer", () => {
        it("should have 0.5MT", async () => {
            const signer0 = signers[0];
            const signer1 = signers[1];
            await expect(
                myTokenC.transfer(
                    hre.ethers.parseUnits("0.5", decimals),
                    signer1.address
                )
            )
                .to.emit(myTokenC, "Transfer")
                .withArgs(
                    signer0.address,
                    signer1.address,
                    hre.ethers.parseUnits("0.5", decimals)
                );
            expect(await myTokenC.balanceOf(signer1.address)).equal(
                hre.ethers.parseUnits("0.5", decimals)
            );
        });
        it("should be reverted with insufficient balance error", async () => {
            const signer1 = signers[1];
            await expect(
                myTokenC.transfer(
                    hre.ethers.parseUnits((mintingAmount + 1n).toString(), decimals),
                    signer1.address
                )
            ).to.be.revertedWith("insufficient balance");
        });
    });
    describe("TransferFrom", () => {
        it("should emit Approval event", async () => {
            const signer1 = signers[1];
            await expect(
                // signers[0]는 signer1에게 10MT만큼의 권한을 부여
                myTokenC.approve(signer1.address, hre.ethers.parseUnits("10", decimals))
            )
                .to.emit(myTokenC, "Approval")
                .withArgs(signer1.address, hre.ethers.parseUnits("10", decimals)); 
        });
        it("should be reverted with insufficient allowance error", async () => {
            const signer0 = signers[0];
            const signer1 = signers[1];
            await expect(myTokenC
                .connect(signer1)
                .TransferFrom(
                    signer0.address,
                    signer1.address,
                    hre.ethers.parseUnits("1", decimals)
                )
            ).to.be.revertedWith("insufficient allowance");
        });
        it("should return 10MT balance for signer1", async () => {
            // 과제: approve, TransferFrom 해서 signer1의 balance가 늘어났음을 보이기.
            // 질문: signer1이 TransferFrom을 호출해서 자기 계좌에 돈 넣는게 좀 이상한데 괜찮은건가요?
            const signer0 = signers[0];
            const signer1 = signers[1];

            // signer0는 signer1에게 10MT만큼의 권한을 부여
            await myTokenC.approve(signer1, hre.ethers.parseUnits("10", decimals));
            // signer1이 TransferFrom을 호출해 signer0의 10MT를 signer1의 계좌로 보냄
            await myTokenC.connect(signer1)
                .TransferFrom(
                    signer0,
                    signer1,
                    hre.ethers.parseUnits("10", decimals)
                );
            expect(await myTokenC.balanceOf(signer1)).equal(
                hre.ethers.parseUnits("10", decimals)
            );
        });
    });
});
