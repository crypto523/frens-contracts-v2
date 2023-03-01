const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const ENS = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e";
var SSVRegistry = 0;
var DepositContract = 0;

describe("Deploys", function () {
  let contracts = {};
  it("Should deploy FrensStorage", async function () {
    const FrensStorage = await ethers.getContractFactory("FrensStorage");
    const frensStorage = await FrensStorage.deploy();
    contracts = Object.assign(contracts, { frensStorage });
  });
  it("Should initialize FrensStorage", async function () {

    // const { chainId } = await ethers.getDefaultProvider().getNetwork();
    // console.log(`networkID ${chainId}`)

    // if (chainId == 1) {
    //   SSVRegistry = "0xb9e155e65B5c4D66df28Da8E9a0957f06F11Bc04"; //update when SSV exists on mainnet
    //   DepositContract = "0x00000000219ab540356cBB839Cbe05303d7705Fa";
    //   console.log("deploying to mainnet")
    // } else if (chainId == 5) {
    //   SSVRegistry = "0xb9e155e65B5c4D66df28Da8E9a0957f06F11Bc04";
    //   DepositContract = "0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b";
    // } else if (chainId == 31337) {
      SSVRegistry = "0xb9e155e65B5c4D66df28Da8E9a0957f06F11Bc04";
      DepositContract = "0x00000000219ab540356cBB839Cbe05303d7705Fa";//forking mainnet to test
    // }

    // SSV registry
    const ssvHash = ethers.utils.solidityKeccak256(["string", "string"], ["external.contract.address", "SSVRegistry"]);
    const ssvInit = await contracts.frensStorage.setAddress(ssvHash, SSVRegistry);
    await ssvInit.wait();
    //deposit contract
    const depContHash = ethers.utils.solidityKeccak256(["string", "string"], ["external.contract.address", "DepositContract"]);
    const depContInit = await contracts.frensStorage.setAddress(depContHash, DepositContract);
    await depContInit.wait();
    //ENS
    const ENSHash = ethers.utils.solidityKeccak256(["string", "string"], ["external.contract.address", "ENS"]);
    const ENSInit = await contracts.frensStorage.setAddress(ENSHash, ENS);
    await ENSInit.wait();
  });

  it("Should deploy FrensPoolShare", async function () {
    const FrensPoolShare = await ethers.getContractFactory("FrensPoolShare");
    const frensPoolShare = await FrensPoolShare.deploy(
      contracts.frensStorage.address
    );
    contracts = Object.assign(contracts, { frensPoolShare });
    // save address in storage
    const h = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensPoolShare"]);
    const s = await contracts.frensStorage.setAddress(h, frensPoolShare.address);
    await s.wait();
    expect(await contracts.frensStorage.getAddress(h)).to.equal(frensPoolShare.address);
  });
  it("Should deploy PmFont", async function () {
    const PmFont = await ethers.getContractFactory("PmFont");
    const pmFont = await PmFont.deploy();
    contracts = Object.assign(contracts, { pmFont });
    const h = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "PmFont"]);
    const s = await contracts.frensStorage.setAddress(h, contracts.pmFont.address);
    await s.wait();

  });
  it("Should deploy Waves", async function () {
    const Waves = await ethers.getContractFactory("Waves");
    const waves = await Waves.deploy();
    contracts = Object.assign(contracts, { waves });
    const h = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "Waves"]);
    const s = await contracts.frensStorage.setAddress(h, contracts.waves.address);
    await s.wait();

  });
  it("Should deploy FrensLogo", async function () {
    const FrensLogo = await ethers.getContractFactory("FrensLogo");
    const frensLogo = await FrensLogo.deploy();
    contracts = Object.assign(contracts, { frensLogo });
    const h = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensLogo"]);
    const s = await contracts.frensStorage.setAddress(h, contracts.frensLogo.address);
    await s.wait();

  });
  it("Should deploy FrensMetaHelper", async function () {
    const FrensMetaHelper = await ethers.getContractFactory("FrensMetaHelper");
    const frensMetaHelper = await FrensMetaHelper.deploy(
      contracts.frensStorage.address,
    );
    contracts = Object.assign(contracts, { frensMetaHelper });
    const h = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensMetaHelper"]);
    const s = await contracts.frensStorage.setAddress(h, contracts.frensMetaHelper.address);
    await s.wait();
  });
  it("Should deploy FrensArt", async function () {
    const FrensArt = await ethers.getContractFactory("FrensArt");
    const frensArt = await FrensArt.deploy(
      contracts.frensStorage.address
    );
    contracts = Object.assign(contracts, { frensArt });
    const h = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensArt"]);
    const s = await contracts.frensStorage.setAddress(h, contracts.frensArt.address);
    await s.wait();
  });
  it("Should deploy FrensPoolShareTokenURI", async function () {
    const FrensPoolShareTokenURI = await ethers.getContractFactory("FrensPoolShareTokenURI");
    const frensPoolShareTokenURI = await FrensPoolShareTokenURI.deploy(
      contracts.frensStorage.address,
    );
    contracts = Object.assign(contracts, { frensPoolShareTokenURI });
    const h = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensPoolShareTokenURI"]);
    const s = await contracts.frensStorage.setAddress(h, contracts.frensPoolShareTokenURI.address);
    await s.wait();

  });
  // it("Should set NFT address in FrensPoolShareTokenURI", async function () {
  //   await contracts.frensPoolShare.setFrensPoolShareTokenURI(
  //     contracts.frensPoolShareTokenURI.address
  //   );
  // });
  it("Should deploy the StakingPoolFactory", async function () {
    const [owner] = await ethers.getSigners();
    const StakingPoolFactory = await ethers.getContractFactory("StakingPoolFactory");
    const stakingPoolFactory = await StakingPoolFactory.deploy(
      contracts.frensStorage.address,
    );
    contracts = Object.assign(contracts, { stakingPoolFactory });
    const h = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "StakingPoolFactory"]);
    const s = await contracts.frensStorage.setAddress(h, contracts.stakingPoolFactory.address);
    await s.wait();

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
      false
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
    Object.keys(contracts).map((key) => {
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

