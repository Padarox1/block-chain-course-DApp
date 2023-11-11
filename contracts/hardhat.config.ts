import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  networks: {
    ganache: {
      // rpc url, change it according to your ganache configuration
      url: 'HTTP://127.0.0.1:7545',
      // the private key of signers, change it according to your ganache user
      accounts: [
        '0x2a93a4fb4227fdc4c930699e2790157e16f9de549f53631759e51e20db4e4a18',
        '0x51583dc0d3988a6fe9ca8c1eec2f62e93a94999113ebbd3e1fb968f455961db3'

      ]
    },
  },
};

export default config;
