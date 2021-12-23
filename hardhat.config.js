require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");

const { STAGING_ALCHEMY_API_URL, 
        STAGING_PRIVATE_KEY,
        PRODUCTION_INFURA_API_URL,
        PRODUCTION_PRIVATE_KEY } = process.env;

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
// task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
//   const accounts = await hre.ethers.getSigners();

//   for (const account of accounts) {
//     console.log(account.address);
//   }
// });

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
       {
          version: '0.8.7',
          settings: {
             optimizer: {
                enabled: true,
                runs: 200,
             },
          },
       },
       {
          version: '0.8.1',
          settings: {},
       },
       {
          version: '0.8.0',
          settings: {},
       },
       {
          version: '0.7.3',
          settings: {},
       },
       {
          version: '0.6.2',
          settings: {},
       }
    ]
  },
  defaultNetwork: "rinkeby",
  networks: {
    hardhat: {},
    rinkeby: {
       url: STAGING_ALCHEMY_API_URL,
       accounts: [`0x${STAGING_PRIVATE_KEY}`]
    },
    mainnet: {
      url: PRODUCTION_INFURA_API_URL,
      accounts: [`0x${STAGING_PRIVATE_KEY}`],
    }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
};
