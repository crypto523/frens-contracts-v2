const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Deploys", function () {
  let contracts = {};
  it("Should deploy FrensPoolShare", async function () {
    const FrensPoolShare = await ethers.getContractFactory("FrensPoolShare");
    const frensPoolShare = await FrensPoolShare.deploy();
    contracts = Object.assign(contracts, { frensPoolShare });
  });
  it("Should deploy PmFont", async function () {
    const PmFont = await ethers.getContractFactory("PmFont");
    const pmFont = await PmFont.deploy();
    contracts = Object.assign(contracts, { pmFont });
  });
  it("Should deploy Waves", async function () {
    const Waves = await ethers.getContractFactory("Waves");
    const waves = await Waves.deploy();
    contracts = Object.assign(contracts, { waves });
  });
  it("Should deploy FrensLogo", async function () {
    const FrensLogo = await ethers.getContractFactory("FrensLogo");
    const frensLogo = await FrensLogo.deploy();
    contracts = Object.assign(contracts, { frensLogo });
  });
  it("Should deploy FrensMetaHelper", async function () {
    const FrensMetaHelper = await ethers.getContractFactory("FrensMetaHelper");
    const frensMetaHelper = await FrensMetaHelper.deploy(
      contracts.frensPoolShare.address
    );
    contracts = Object.assign(contracts, { frensMetaHelper });
  });
  it("Should deploy FrensArt", async function () {
    const FrensArt = await ethers.getContractFactory("FrensArt");
    const frensArt = await FrensArt.deploy(
      contracts.frensMetaHelper.address,
      contracts.pmFont.address,
      contracts.waves.address,
      contracts.frensLogo.address,
    );
    contracts = Object.assign(contracts, { frensArt });
  });
  it("Should deploy FrensPoolShareTokenURI", async function () {
    const FrensPoolShareTokenURI = await ethers.getContractFactory("FrensPoolShareTokenURI");
    const frensPoolShareTokenURI = await FrensPoolShareTokenURI.deploy(
      contracts.frensPoolShare.address,
      contracts.frensMetaHelper.address
    );
    contracts = Object.assign(contracts, { frensPoolShareTokenURI });
  });
  it("Should set NFT address in FrensPoolShareTokenURI", async function () {
    await contracts.frensPoolShare.setFrensPoolShareTokenURI(
      contracts.frensPoolShareTokenURI.address
    );
  });
  it("Should deploy the StakingPoolFactory", async function () {
    const [owner] = await ethers.getSigners();
    const StakingPoolFactory = await ethers.getContractFactory("StakingPoolFactory");
    const stakingPoolFactory = await StakingPoolFactory.deploy(
      contracts.frensPoolShare.address,
    );
    contracts = Object.assign(contracts, { stakingPoolFactory });
  });
  it("Should add StakingPoolFactory to the DEFAULT_ADMIN_ROLE role", async function () {
    await contracts.frensPoolShare.grantRole(
      ethers.constants.HashZero,
      contracts.stakingPoolFactory.address
    );
  });
  it("Should deploy a StakingPool", async function () {
    const [owner] = await ethers.getSigners();

    const tx = await contracts.stakingPoolFactory.create(
      owner.address,
      false,
      contracts.frensArt.address
    );
    const receipt = await tx.wait();
    for (const event of receipt.events) {
      // console.log(`Event ${event.event} with args ${event.args}`);
      if (event.event === "Create") {
        // read the stakingpool address that was generated
        const StakingPool = await ethers.getContractFactory("StakingPool");
        const stakingPool = await StakingPool.attach(event.args[0]);
        contracts = Object.assign(contracts, { stakingPool });

      }
    }
  });

  it("Should print a summary of deployed contracts", async function () {
    console.log(`Deploy finished..`);
    Object.keys(contracts).map((key)=>{
      console.log(`${key} at ${contracts[key].address}`);
    });
  });
  it("Should stake in StakingPool", async function () {
    const [owner] = await ethers.getSigners();
    const tx = await contracts.stakingPool.depositToPool(
      { value: ethers.utils.parseEther("1.0") }
    );
    const supply = await contracts.frensPoolShare.totalSupply()
    console.log(`supply is ${supply.toString()}`)
    const tokenURI = await contracts.frensPoolShare.tokenURI(0);
    console.log(`tokenURI of token 0 is ${tokenURI}`);
  });
});

