// deploy/00_deploy_your_contract.js

const { ethers } = require("hardhat");

const localChainId = "31337";

// const sleep = (ms) =>
//   new Promise((r) =>
//     setTimeout(() => {
//       console.log(`waited for ${(ms / 1000).toFixed(3)} seconds`);
//       r();
//     }, ms)
//   );

module.exports = async ({ getNamedAccounts, deployments, getChainId }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = await getChainId();

  console.log("chainId", chainId);
  const ENS = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e";

  var SSVRegistry = 0;
  var DepositContract = 0;

  if(chainId == 1){
    SSVRegistry = "0xb9e155e65B5c4D66df28Da8E9a0957f06F11Bc04"; //update when SSV exists on mainnet
    DepositContract = "0x00000000219ab540356cBB839Cbe05303d7705Fa";
    console.log("deploying to mainnet")
  } else if(chainId == 5) {
    SSVRegistry = "0xb9e155e65B5c4D66df28Da8E9a0957f06F11Bc04";
    DepositContract = "0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b";
  }else if(chainId ==31337){ 
    SSVRegistry = "0xb9e155e65B5c4D66df28Da8E9a0957f06F11Bc04";
    //DepositContract = "0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b";//forking goerli to test
    DepositContract = "0x00000000219ab540356cBB839Cbe05303d7705Fa";//forking mainnet to test
  }

  var FrensStorageOld = 0;
  var FrensPoolShareOld = 0;
  var StakingPoolFactoryOld = 0;
  var FrensOracleOld = 0;
  var FrensMetaHelperOld = 0;
  var FrensPoolShareTokenURIOld = 0;
  var FrensArtOld = 0;
  var PmFontOld = 0;
  var FrensLogoOld = 0;
  var WavesOld = 0;

  try{
    FrensStorageOld = await ethers.getContract("FrensStorage", deployer);
  } catch(e) {}

  try{
    FactoryProxyOld = await ethers.getContract("FactoryProxy", deployer);
  } catch(e) {}

  try{
    FrensPoolShareOld = await ethers.getContract("FrensPoolShare", deployer);
  } catch(e) {}

  try{
    StakingPoolFactoryOld = await ethers.getContract("StakingPoolFactory", deployer);
  } catch(e) {}

  try{
    FrensOracleOld = await ethers.getContract("FrensOracle", deployer);
  } catch(e) {}

  try{
    FrensMetaHelperOld = await ethers.getContract("FrensMetaHelper", deployer);
  } catch(e) {}

  try{
    FrensPoolShareTokenURIOld = await ethers.getContract("FrensPoolShareTokenURI", deployer);
  } catch(e) {}

  try{
    FrensArtOld = await ethers.getContract("FrensArt", deployer);
  } catch(e) {}

  try{
    PmFontOld = await ethers.getContract("PmFont", deployer);
  } catch(e) {}

  try{
    FrensLogoOld = await ethers.getContract("FrensLogo", deployer);
  } catch(e) {}

  try{
    WavesOld = await ethers.getContract("Waves", deployer);
  } catch(e) {}

  
  if(FrensStorageOld == 0 || chainId == 31337){ //should not update storage contract on testnet of mainnet
    await deploy("FrensStorage", {
      // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
      from: deployer,
      args: [
        //no args
       ],
      log: true,
      waitConfirmations: 5,
    });
  }
  var reinitialiseEverything = false;
  const FrensStorage = await ethers.getContract("FrensStorage", deployer);
  console.log("storage contract", FrensStorage.address);
  if(FrensStorageOld == 0){
    reinitialiseEverything = true;
    console.log('\x1b[33m%s\x1b[0m', "FrensStorage initialising", FrensStorage.address);
  } else if(FrensStorageOld.address != FrensStorage.address){
    reinitialiseEverything = true;
    console.log('\x1b[31m%s\x1b[0m', "FrensStorage updated and initialising", FrensStorage.address);
  }
/*
  if(FactoryProxyOld == 0 || chainId == 31337){ //should not update proxy contract on testnet of mainnet
    await deploy("FactoryProxy", {
      // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
      from: deployer,
      args: [  FrensStorage.address ],
      log: true,
      waitConfirmations: 5,
    });
  }

  const FactoryProxy = await ethers.getContract("FactoryProxy", deployer);

  if(FactoryProxyOld == 0){
    console.log('\x1b[33m%s\x1b[0m', "FactoryProxy initialised", FactoryProxy.address);
  } else if(FactoryProxyOld.address != FactoryProxy.address){
    console.log('\x1b[31m%s\x1b[0m', "FactoryProxy updated", FactoryProxy.address);
  }
*/
  if(reinitialiseEverything) {
    //ssv
    const ssvHash = ethers.utils.solidityKeccak256(["string", "string"], ["external.contract.address", "SSVRegistry"]);
    const ssvInit = await FrensStorage.setAddress(ssvHash, SSVRegistry);
    await ssvInit.wait();
    //deposit contract
    const depContHash = ethers.utils.solidityKeccak256(["string", "string"], ["external.contract.address", "DepositContract"]);
    const depContInit = await FrensStorage.setAddress(depContHash, DepositContract);
    await depContInit.wait();
    //ENS
    const ENSHash =  ethers.utils.solidityKeccak256(["string", "string"], ["external.contract.address", "ENS"]);
    const ENSInit = await FrensStorage.setAddress(ENSHash, ENS);
    await ENSInit.wait();
    console.log('\x1b[36m%s\x1b[0m', "external contracts initialised", SSVRegistry, DepositContract, ENS);
  } 

  
  if(FrensPoolShareOld == 0 || chainId == 31337){ //should not update NFT contract on testnet or mainnet
    await deploy("FrensPoolShare", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [
      //"0x00000000219ab540356cBB839Cbe05303d7705Fa", "0xb9e155e65B5c4D66df28Da8E9a0957f06F11Bc04" //mainnet (using goerli ssvRegistryAddress until there is a mainnet deployment - some features will not work on mainnet fork)
      FrensStorage.address
     ],
    log: true,
    waitConfirmations: 5,
    });
  }

  const FrensPoolShare = await ethers.getContract("FrensPoolShare", deployer);

  if(FrensPoolShareOld == 0){
    const poolShareXfer = await FrensPoolShare.transferOwnership("0xa53A6fE2d8Ad977aD926C485343Ba39f32D3A3F6");
    await poolShareXfer.wait();
    const poolShareHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensPoolShare"]);
    const poolShareInit = await FrensStorage.setAddress(poolShareHash, FrensPoolShare.address);
    await poolShareInit.wait();
    
    console.log('\x1b[33m%s\x1b[0m', "FrensPoolShare initialised", FrensPoolShare.address);
  } else if(FrensPoolShareOld.address != FrensPoolShare.address){
    const poolShareXfer = await FrensPoolShare.transferOwnership("0xa53A6fE2d8Ad977aD926C485343Ba39f32D3A3F6");
    await poolShareXfer.wait();
    const poolShareHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensPoolShare"]);
    const poolShareInit = await FrensStorage.setAddress(poolShareHash, FrensPoolShare.address);
    await poolShareInit.wait();
    console.log('\x1b[31m%s\x1b[0m', "FrensPoolShare updated", FrensPoolShare.address);
  }else if(reinitialiseEverything) {
    const poolShareHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensPoolShare"]);
    const poolShareInit = await FrensStorage.setAddress(poolShareHash, FrensPoolShare.address);
    await poolShareInit.wait();
    console.log('\x1b[33m%s\x1b[0m', "FrensPoolShare (re)initialised", FrensPoolShare.address);
  }

  await deploy("StakingPoolFactory", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [
      //"0x00000000219ab540356cBB839Cbe05303d7705Fa", "0xb9e155e65B5c4D66df28Da8E9a0957f06F11Bc04" //mainnet (using goerli ssvRegistryAddress until there is a mainnet deployment - some features will not work on mainnet fork)
      FrensStorage.address 
     ],
    log: true,
    waitConfirmations: 5,
  });

  const StakingPoolFactory = await ethers.getContract("StakingPoolFactory", deployer);

  if(StakingPoolFactoryOld == 0 || reinitialiseEverything) {
    const factoryHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "StakingPoolFactory"]);
    const factoryInit = await FrensStorage.setAddress(factoryHash, StakingPoolFactory.address);
    await factoryInit.wait();
    await FrensPoolShare.grantRole(ethers.constants.HashZero,  StakingPoolFactory.address);
    console.log('\x1b[33m%s\x1b[0m', "StakingPoolFactory initialised", StakingPoolFactory.address);
  } else if(StakingPoolFactoryOld.address != StakingPoolFactory.address){
    const factoryHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "StakingPoolFactory"]);
    const factoryInit = await FrensStorage.setAddress(factoryHash, StakingPoolFactory.address);
    await factoryInit.wait();
    await FrensPoolShare.revokeRole(ethers.constants.HashZero,  StakingPoolFactoryOld.address);
    await FrensPoolShare.grantRole(ethers.constants.HashZero,  StakingPoolFactory.address);
    console.log('\x1b[36m%s\x1b[0m', "StakingPoolFactory updated", StakingPoolFactory.address);
  }

  
  await deploy("FrensOracle", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [
      FrensStorage.address
     ],
    log: true,
    waitConfirmations: 5,
  });

  const FrensOracle = await ethers.getContract("FrensOracle", deployer);

  if(FrensOracleOld == 0 || reinitialiseEverything){
    const oracleHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensOracle"]);
    const oracleInit = await FrensStorage.setAddress(oracleHash, FrensOracle.address);
    await oracleInit.wait();
    console.log('\x1b[33m%s\x1b[0m', "FrensOracle initialised", FrensOracle.address);
  } else if(FrensOracleOld.address != FrensOracle.address){
    const oracleHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensOracle"]);
    const oracleInit = await FrensStorage.setAddress(oracleHash, FrensOracle.address);
    await oracleInit.wait();
    console.log('\x1b[36m%s\x1b[0m', "FrensOracle updated", FrensOracle.address);
  }

  await deploy("FrensMetaHelper", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [
      FrensStorage.address
     ],
    log: true,
    waitConfirmations: 5,
  });

  const FrensMetaHelper = await ethers.getContract("FrensMetaHelper", deployer);

  if(FrensMetaHelperOld == 0 || reinitialiseEverything){
    const metaHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensMetaHelper"]);
    const metaInit = await FrensStorage.setAddress(metaHash, FrensMetaHelper.address);
    await metaInit.wait();
    console.log('\x1b[33m%s\x1b[0m', "FrensMetaHelper initialised", FrensMetaHelper.address);
  } else if(FrensMetaHelperOld.address != FrensMetaHelper.address){
    const metaHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensMetaHelper"]);
    const metaInit = await FrensStorage.setAddress(metaHash, FrensMetaHelper.address);
    await metaInit.wait();
    console.log('\x1b[36m%s\x1b[0m', "FrensMetaHelper updated", FrensMetaHelper.address);
  }

  await deploy("FrensPoolShareTokenURI", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [ 
      FrensStorage.address
      ],
    log: true,
    waitConfirmations: 5,
  });

  const FrensPoolShareTokenURI = await ethers.getContract("FrensPoolShareTokenURI", deployer);

  if(FrensPoolShareTokenURIOld == 0 || reinitialiseEverything){
    const tokUriHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensPoolShareTokenURI"]);
    const tokUriInit = await FrensStorage.setAddress(tokUriHash, FrensPoolShareTokenURI.address);
    await tokUriInit.wait();
    console.log('\x1b[33m%s\x1b[0m', "FrensPoolShareTokenURI initialised", FrensPoolShareTokenURI.address);
  } else if(FrensPoolShareTokenURIOld.address != FrensPoolShareTokenURI.address){
    const tokUriHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensPoolShareTokenURI"]);
    const tokUriInit = await FrensStorage.setAddress(tokUriHash, FrensPoolShareTokenURI.address);
    await tokUriInit.wait();
    console.log('\x1b[36m%s\x1b[0m', "FrensPoolShareTokenURI updated", FrensPoolShareTokenURI.address);
  }

  await deploy("FrensArt", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [
          FrensStorage.address
     ],
    log: true,
    waitConfirmations: 5,
  });

  const FrensArt = await ethers.getContract("FrensArt", deployer);

  if(FrensArtOld == 0 || reinitialiseEverything){
    const artHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensArt"]);
    const artInit = await FrensStorage.setAddress(artHash, FrensArt.address);
    await artInit.wait();
    console.log('\x1b[33m%s\x1b[0m', "FrensArt initialised", FrensArt.address);
  } else if(FrensArtOld.address != FrensArt.address){
    const artHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensArt"]);
    const artInit = await FrensStorage.setAddress(artHash, FrensArt.address);
    await artInit.wait();
    console.log('\x1b[36m%s\x1b[0m', "FrensArt updated", FrensArt.address);
  }

  await deploy("PmFont", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [
      
     ],
    log: true,
    waitConfirmations: 5,
  });

  const PmFont = await ethers.getContract("PmFont", deployer);

  if(PmFontOld == 0 || reinitialiseEverything){
    const pmHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "PmFont"]);
    const pmInit = await FrensStorage.setAddress(pmHash, PmFont.address);
    await pmInit.wait();
    console.log('\x1b[33m%s\x1b[0m', "PmFont initialised", PmFont.address);
  } else if(PmFontOld.address != PmFont.address){
    const pmHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "PmFont"]);
    const pmInit = await FrensStorage.setAddress(pmHash, PmFont.address);
    await pmInit.wait();
    console.log('\x1b[36m%s\x1b[0m', "PmFont updated", PmFont.address);
  }

  await deploy("FrensLogo", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [
      
     ],
    log: true,
    waitConfirmations: 5,
  });

  const FrensLogo = await ethers.getContract("FrensLogo", deployer);

  if(FrensLogoOld == 0 || reinitialiseEverything){
    const logoHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensLogo"]);
    const logoInit = await FrensStorage.setAddress(logoHash, FrensLogo.address);
    await logoInit.wait();
    console.log('\x1b[33m%s\x1b[0m', "FrensLogo initialised", FrensLogo.address);
  } else if(FrensLogoOld.address != FrensLogo.address){
    const logoHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "FrensLogo"]);
    const logoInit = await FrensStorage.setAddress(logoHash, FrensLogo.address);
    await logoInit.wait();
    console.log('\x1b[36m%s\x1b[0m', "FrensLogo updated", FrensLogo.address);
  }

  await deploy("Waves", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [
      
     ],
    log: true,
    waitConfirmations: 5,
  });

  const Waves = await ethers.getContract("Waves", deployer);

  if(WavesOld == 0 || reinitialiseEverything){
    const wavesHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "Waves"]);
    const wavesInit = await FrensStorage.setAddress(wavesHash, Waves.address);
    await wavesInit.wait();
    console.log('\x1b[33m%s\x1b[0m', "Waves initialised", Waves.address);
  } else if(WavesOld.address != Waves.address){
    const wavesHash = ethers.utils.solidityKeccak256(["string", "string"], ["contract.address", "Waves"]);
    const wavesInit = await FrensStorage.setAddress(wavesHash, Waves.address);
    await wavesInit.wait();
    console.log('\x1b[36m%s\x1b[0m', "Waves updated", Waves.address);
  }

  if(chainId == 31337){
    await deploy("StakingPool", {//need abi
      // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
      from: deployer,
      args: [
        "0x42f58dd8528c302eeC4dCbC71159bA737908D6Fa",
        false,
        FrensStorage.address
      ],
      log: true,
      waitConfirmations: 5,
    });
  }

  const newPool = await StakingPoolFactory.create("0xa53A6fE2d8Ad977aD926C485343Ba39f32D3A3F6", true/*, false, 0, 32000000000000000000n*/);
  
  newPoolResult = await newPool.wait();
  console.log('\x1b[36m%s\x1b[0m',"New StakingPool", newPoolResult.logs[0].address);

 if(chainId == 1){
    const setGuard = await FrensStorage.setGuardian("0x6B5F5497Dd1FaFfC62faf6dCFC0e7f616058De0b");
    await setGuard.wait();
    console.log('\x1b[36m%s\x1b[0m', "New guardian set", "0x6B5F5497Dd1FaFfC62faf6dCFC0e7f616058De0b");
  }
/*
  await deploy("FrensArtTest", {
    // Learn more about args here: https://www.npmjs.com/package/hardhat-deploy#deploymentsdeploy
    from: deployer,
    args: [
      FrensStorage.address
     ],
    log: true,
    waitConfirmations: 5,
  });

  const FrensArtTest = await ethers.getContract("FrensArtTest", deployer);
  console.log("FrensArtTest", FrensArtTest.address);
*/
};
module.exports.tags = ["FrensArt", "FrensMetaHelper", "FrensPoolSetter", "FrensPoolShare", "FrensPoolShareTokenURI", "FrensStorage", "StakingPoolFactory", "StakingPool"];
