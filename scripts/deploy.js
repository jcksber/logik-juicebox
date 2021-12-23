/*
 * Deployment script for JuiceBox.sol
 *
 * Author: Jack Kasbeer
 * Created: December 22, 2021
 */

const { ethers, upgrades } = require("hardhat");

async function main() {
  const gas = { 'gasPrice': 50000 }
  const JuiceBox = await ethers.getContractFactory("JuiceBox");
  const instance = await JuiceBox.deploy();
  console.log("JuiceBox contract deployed to address:", instance.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error);
    process.exit(1);
  });

