const { ethers } = require("hardhat");
const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");

describe("Validation execute permission for functions", function() {
    async function deployFixture() {
        const [owner, ...rest] = await ethers.getSigners();
        const Token = await ethers.getContractFactory("MGGGiftGachaMof");
        const token = await Token.connect(owner).deploy();

        return { token, owner, rest };
    }

    it("Validation to authorize execution setCost", async function() {
        const { token, owner, ...others } = await loadFixture(deployFixture);

        await expect(token.connect(owner).setCost("10000000000000000")).not.to.be.reverted;
        await expect(token.connect(others.rest[0]).setCost("10000000000000000")).to.be.reverted;
    });
    
    it("Validation to authorize execution setWithdrawAddress", async function() {
        const { token, owner, ...others } = await loadFixture(deployFixture);

        await expect(token.connect(owner).setWithdrawAddress("0xF2b12AAa4410928eB8C1a61C0a7BB0447b930303")).not.to.be.reverted;
        await expect(token.connect(others.rest[0]).setWithdrawAddress("0xF2b12AAa4410928eB8C1a61C0a7BB0447b930303")).to.be.reverted;
    });

    it("Validation to authorize execution unpause and pause", async function() {
        const { token, owner, ...others } = await loadFixture(deployFixture);

        await expect(token.connect(owner).unpause()).not.to.be.reverted;
        await expect(token.connect(others.rest[0]).unpause()).to.be.reverted;

        await expect(token.connect(owner).pause()).not.to.be.reverted;
        await expect(token.connect(others.rest[0]).pause()).to.be.reverted;
    });

    it("Validation to authorize execution withdraw", async function() {
        const { token, owner, ...others } = await loadFixture(deployFixture);

        await expect(token.connect(owner).withdraw()).not.to.be.reverted;
        await expect(token.connect(others.rest[0]).withdraw()).to.be.reverted;
    });
});