const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
// const [owner, otherAccount] = await ethers.getSigners();

describe("Deploys", function () {
  let frensArt, frensPoolShareTokenURI, frensPoolShare;
  it("Should deploy FrensArt", async function () {
    const FrensArt = await ethers.getContractFactory("FrensArt");
    frensArt = await FrensArt.deploy();
  });
  it("Should deploy FrensPoolShareTokenURI", async function () {
    const FrensPoolShareTokenURI = await ethers.getContractFactory("FrensPoolShareTokenURI");
    frensPoolShareTokenURI = await FrensPoolShareTokenURI.deploy();
  });
  it("Should deploy FrensPoolShare", async function () {
    const FrensPoolShare = await ethers.getContractFactory("FrensPoolShare");
    frensPoolShare = await FrensPoolShare.deploy(frensPoolShareTokenURI.address);
  });
  it("Should print a summary", async function () {
    console.log(`Deploys`);
    console.log(`FrensArt at ${frensArt.address}`);
    console.log(`FrensPoolShareTokenURI at ${frensPoolShareTokenURI.address}`);
    console.log(`FrensPoolShare at ${frensPoolShare.address}`);
  });
});

