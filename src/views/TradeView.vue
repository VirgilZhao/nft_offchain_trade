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
</script>

<template>
  <div class="p-4">
    <button @click="connect" class="px-2 py-1 text-white rounded bg-sky-500">Connect</button>
  </div>
  <div class="px-4">Address: {{wallet.address}}</div>
  <div class="p-2 m-4 border border-emerald-400">
    <p>Mint</p>
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
</template>