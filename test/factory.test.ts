import chai, { expect } from "chai";
import { ethers, upgrades } from 'hardhat';
import { solidity } from "ethereum-waffle";
chai.use(solidity);
import { Signer } from "ethers";
import { TokenUpgradeable, TokenUpgradeableV2, TokenUpgradeable__factory, TokenUpgradeableV2__factory } from "../typechain";


describe("Factory Deployment Testing", function () {
  let accounts: Signer[];
  let Factory: TokenUpgradeable;
  let TokenContractFactory: TokenUpgradeable__factory;
  let TokenV2: TokenUpgradeableV2;
  let TokenContractFactoryV2: TokenUpgradeableV2__factory;
  let owner: any


  beforeEach(async ()=>{
    TokenContractFactory = <TokenUpgradeable__factory>await ethers.getContractFactory("TokenUpgradeable");
    // Factory = <TokenUpgradeable>await upgrades.deployProxy(TokenContractFactory, { kind: "uups" });
    Factory = <TokenUpgradeable>await upgrades.deployProxy(TokenContractFactory, {
      initializer: "initialize",
    });
    await Factory.deployed();
    [owner] = await ethers.getSigners();
  })

  describe("Factory contract", function () {
    it("Deployment should assign the total supply of tokens to the owner", async function () {
      const ownerBalance = await Factory.balanceOf(owner.address);
      expect(await Factory.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("Upgraded Factory contract", function () {
    it("Deployment should say upgraded", async function () {
    TokenContractFactoryV2 = <TokenUpgradeableV2__factory>await ethers.getContractFactory("TokenUpgradeableV2");
    TokenV2 = <TokenUpgradeableV2>await upgrades.upgradeProxy(Factory, TokenContractFactoryV2);
    expect(Factory.address).to.equal(TokenV2.address);
    expect(await TokenV2.exampleUpgrade()).to.equal("upgraded");
    });
  });

});
