import hre from "hardhat";

describe("mytoken deploy", () => {
    it("should deploy", async () => {
        const myTokenC = await hre.ethers.deployContract("MyToken", [
            "MyToken",
            "MT", 
            18,
        ]);
        console.log((await myTokenC).name());
    });
});