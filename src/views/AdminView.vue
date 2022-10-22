<script setup>
    import { ethers } from 'ethers'
    import Web3Modal from 'web3modal'
    import { reactive, toRaw } from 'vue'
    import NFTItem from '../../artifacts/contracts/NFTItem.sol/NFTItem.json'
    import { nftItemAddress } from '../../config.js'
    
    const wallet = reactive({
      signer: null,
      address: ''
    })
  
    const mintInfo = reactive({
      address: '',
      tokenURI: ''
    })

    const sellInfo = reactive({
        address: '',
        tokenId: '',
        price: '',
        signature: ''
    })

    const buyerInfo = reactive({
        seller: '',
        buyer: '',
        tokenId: '',
        price: '',
        signature: ''
    })
  
    async function connect() {
      const providerOptions = {}
      const web3Modal = new Web3Modal({
          network: "mainnet",
          cacheProvider: true,
          providerOptions
      })
      const instance = await web3Modal.connect()
      const provider = new ethers.providers.Web3Provider(instance)
      const signer = provider.getSigner()
      const address = await signer.getAddress()
      console.log(address)
      console.log(signer)
      wallet.signer = signer
      wallet.address = address
    }
  
    async function mint(){
      console.log(nftItemAddress)
      console.log(NFTItem.abi)
      console.log(wallet.signer)
      var nftItem = new ethers.Contract(nftItemAddress, NFTItem.abi, toRaw(wallet.signer))
      let tx = await nftItem.awardItem(mintInfo.address, mintInfo.tokenURI)
      console.log(tx)
      await tx.wait()
    }
    
    async function onlineSelling(){
        var nftItem = new ethers.Contract(nftItemAddress, NFTItem.abi, toRaw(wallet.signer))
        let tx = await nftItem.sellItem(sellInfo.address, sellInfo.tokenId, sellInfo.price, ethers.utils.arrayify(sellInfo.signature))
        console.log(tx)
        await tx.wait()
    }

    async function onlineBuy(){
        var nftItem = new ethers.Contract(nftItemAddress, NFTItem.abi, toRaw(wallet.signer))
        let tx = await nftItem.buyItem(buyerInfo.seller, buyerInfo.buyer, buyerInfo.tokenId, buyerInfo.price, ethers.utils.arrayify(buyerInfo.signature))
        console.log(tx)
        await tx.wait()
    }
  </script>
  
  <template>
    <div class="p-4">
      <button @click="connect" class="px-2 py-1 text-white rounded bg-sky-500">Connect</button>
    </div>
    <div class="px-4">Address: {{wallet.address}}</div>
    <div class="p-2 m-4 border border-emerald-400">
      <p>Mint NFT</p>
      <label class="block mt-2">
        <span>Address</span>
        <input type="text" v-model="mintInfo.address" class="block w-full mt-2 bg-white border "/>
      </label>
      <label class="block mt-2">
        <span>Token URI</span>
        <input type="text" v-model="mintInfo.tokenURI" class="block w-full mt-2 bg-white border "/>
      </label>
      <button @click="mint" class="px-2 py-2 mt-2 text-white rounded bg-sky-500">Mint</button>
    </div>
    <div class="p-2 m-4 border border-emerald-400">
      <p>Onchain Sell NFT</p>
      <label class="block mt-2">
        <span>Seller</span>
        <input type="text" v-model="sellInfo.address" class="block w-full mt-2 bg-white border "/>
      </label>
      <label class="block mt-2">
        <span>Token Id</span>
        <input type="text" v-model="sellInfo.tokenId" class="block w-full mt-2 bg-white border "/>
      </label>
      <label class="block mt-2">
        <span>Price</span>
        <input type="text" v-model="sellInfo.price" class="block w-full mt-2 bg-white border "/>
      </label>
      <label class="block mt-2">
        <span>Signature</span>
        <input type="text" v-model="sellInfo.signature" class="block w-full mt-2 bg-white border "/>
      </label>
      <button @click="onlineSelling" class="px-2 py-2 mt-2 text-white rounded bg-sky-500">Online</button>
    </div>
    <div class="p-2 m-4 border border-emerald-400">
      <p>Onchain Buy NFT</p>
      <label class="block mt-2">
        <span>Seller</span>
        <input type="text" v-model="buyerInfo.seller" class="block w-full mt-2 bg-white border "/>
      </label>
      <label class="block mt-2">
        <span>Buyer</span>
        <input type="text" v-model="buyerInfo.buyer" class="block w-full mt-2 bg-white border "/>
      </label>
      <label class="block mt-2">
        <span>Token Id</span>
        <input type="text" v-model="buyerInfo.tokenId" class="block w-full mt-2 bg-white border "/>
      </label>
      <label class="block mt-2">
        <span>Price</span>
        <input type="text" v-model="buyerInfo.price" class="block w-full mt-2 bg-white border "/>
      </label>
      <label class="block mt-2">
        <span>Signature</span>
        <input type="text" v-model="buyerInfo.signature" class="block w-full mt-2 bg-white border "/>
      </label>
      <button @click="onlineBuy" class="px-2 py-2 mt-2 text-white rounded bg-sky-500">Online</button>
    </div>
  </template>