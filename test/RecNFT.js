const {expect} = require('chai')
const hre = require('hardhat')

describe('RecNFT', function(){
    it('awardItem', async () => {
        const RecNFTMarketplace = await hre.ethers.getContractFactory("RecNFTMarketplace")
        const recInstance = await RecNFTMarketplace.deploy() 
        console.log(recInstance)
        const [account1, account2] = hre.ethers.getSigners()
        console.log(account1, account2)
        
    })
});