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

  const ownNFTs = reactive({
    items: []
  })

  const sellingNFTs = reactive({
    items: []
  })

  const signStrs = reactive({
    sellSign: '',
    buySign: ''
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

  async function checkOwned(){
    var nftItem = new ethers.Contract(nftItemAddress, NFTItem.abi, toRaw(wallet.signer))
    let result = await nftItem.getMyNFTs()
    console.log(result)
    ownNFTs.items = []
    signStrs.sellSign = ''
    result.forEach(async function (item){
      let data = await fetchTokenURI(item['tokenURI'])
      ownNFTs.items.push({
        id: item['tokenId'].toNumber(),
        image_url: data['image_url'].replace('ipfs://', 'https://gateway.pinata.cloud/ipfs/'),
        name: data['name'],
        description: data['description']
      })
    });
    //console.log(items);
    //ownNFTs.items = items;
  }

  async function fetchTokenURI(uri){
    let data = await fetch(uri).then(res => res.json())
    console.log(data)
    return data
  }

  async function sellNFT(item){
    let price = window.prompt("Please enter sell price")
    console.log(item)
    console.log(price)
    var nftItem = new ethers.Contract(nftItemAddress, NFTItem.abi, toRaw(wallet.signer))
    console.log(toRaw(wallet.address))
    let message = await nftItem.getMessageHash(toRaw(wallet.address), item.id, price)
    let flatSig = await toRaw(wallet.signer).signMessage(ethers.utils.arrayify(message));
    //let sig = ethers.utils.splitSignature(flatSig);
    console.log(ethers.utils.hexlify(flatSig))
    signStrs.sellSign = flatSig
    //console.log(sig)
  }

  async function checkSelling(){
    var nftItem = new ethers.Contract(nftItemAddress, NFTItem.abi, toRaw(wallet.signer))
    let result = await nftItem.getSellNFTs()
    console.log(result)
    sellingNFTs.items = []
    signStrs.buySign = ''
    result.forEach(async function(item){
      let data = await nftItem.tokenURI(item.tokenId)
      console.log(data)
      let tokenData = await fetchTokenURI(data)
      console.log(tokenData)
      sellingNFTs.items.push({
        id: item.tokenId,
        image_url: tokenData['image_url'].replace('ipfs://', 'https://gateway.pinata.cloud/ipfs/'),
        name: tokenData['name'],
        description: tokenData['description'],
        price: item.price,
        seller: item.seller
      })
    })
  }
  
  async function buyNFT(item){
    console.log(item)
    var nftItem = new ethers.Contract(nftItemAddress, NFTItem.abi, toRaw(wallet.signer))
    let message = await nftItem.getMessageHash(toRaw(wallet.address), item.id, item.price)
    let flatSig = await toRaw(wallet.signer).signMessage(ethers.utils.arrayify(message));
    console.log(ethers.utils.hexlify(flatSig))
    signStrs.buySign = flatSig
  }
</script>

<template>
  <div class="p-4">
    <button @click="connect" class="px-2 py-1 text-white rounded bg-sky-500">Connect</button>
  </div>
  <div class="px-4">Address: {{wallet.address}}</div>
  <div class="p-2 m-4 border border-emerald-400">
    <p>Owned NFT</p>
    <button @click="checkOwned" class="px-2 py-2 mt-2 text-white rounded-none bg-sky-500">Check</button>
    <div class="flex p-2 space-x-4">
      <div v-for="item in ownNFTs.items" class="p-2">
        <img :src="item.image_url" class="w-1/5" />
        <p>{{item.name}}</p>
        <p>#{{item.id}}</p>
        <p>{{item.description}}</p>
        <button @click="sellNFT(item)" class="px-2 py-2 text-white rounded bg-sky-500">Sell It</button>
      </div>
    </div>
    <p class="break-all">{{signStrs.sellSign}}</p>
  </div>
  <div class="p-2 m-4 border border-emerald-400">
    <p>On Market NFT List</p>
    <button @click="checkSelling" class="px-2 py-2 mt-2 text-white rounded-none bg-sky-500">Check</button>
    <div class="flex p-2 space-x-4">
      <div v-for="item in sellingNFTs.items" class="p-2">
        <img :src="item.image_url" class="w-1/5" />
        <p>{{item.name}}</p>
        <p>#{{item.id}}</p>
        <p>{{item.description}}</p>
        <p>${{item.price}}</p>
        <p>{{item.seller}}</p>
        <button @click="buyNFT(item)" class="px-2 py-2 text-white rounded bg-sky-500">Buy It</button>
      </div>
    </div>
    <p class="break-all">{{signStrs.buySign}}</p>
  </div>
</template>