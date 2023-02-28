const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Deploys", function () {
  let frensArt, frensPoolShareTokenURI, frensPoolShare, stakingPool;
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
  it("Should deploy StakingPool", async function () {
    const [owner] = await ethers.getSigners();
    const StakingPool = await ethers.getContractFactory("StakingPool");
    stakingPool = await StakingPool.deploy(
      owner.address,
      false,
      frensPoolShare.address,
      frensArt.address
    );
  });
  it("Should add StakingPool to the MINT role", async function () {
    const role = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('MINTER_ROLE'));
    await frensPoolShare.grantRole(role, stakingPool.address);
  });
  it("Should print a summary", async function () {
    console.log(`Deploys`);
    console.log(`FrensArt at ${frensArt.address}`);
    console.log(`FrensPoolShareTokenURI at ${frensPoolShareTokenURI.address}`);
    console.log(`FrensPoolShare at ${frensPoolShare.address}`);
    console.log(`StakingPool at ${stakingPool.address}`);
  });

  it("Should stake in StakingPool", async function () {
    const [owner] = await ethers.getSigners();

    await stakingPool.depositToPool({ value: ethers.utils.parseEther("1.0") });

    // const transactionHash = await owner.sendTransaction({
    //   to: stakingPool.address,
    //   value: ethers.utils.parseEther("1.0"), // Sends exactly 1.0 ether
    // });

    // console.log(`Deposit tx hash=${JSON.stringify(transactionHash)}`);

    const supply = await frensPoolShare.totalSupply()
    console.log(`supply is ${supply.toString()}`)

  });


});

