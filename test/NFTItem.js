const {expect} = require('chai')
const hre = require('hardhat')

/*describe('NFTItem', function(){
    it('awardItem', async () => {
        const NFTItemContract = await hre.ethers.getContractFactory("NFTItem")
        const nftInstance = await NFTItemContract.deploy() 
        console.log(nftInstance)

        const [account1, account2] = await hre.ethers.getSigners()
        console.log(account1, account2)
        const tokenURI = "https://opensea-creatures-api.herokuapp.com/api/creature/1"
        const tx = await nftInstance.connect(account1).awardItem(account2.getAddress(), tokenURI)
        console.log(tx)
    })
})*/
