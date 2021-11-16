import Web3 from "web3"
import {
  newKitFromWeb3
} from "@celo/contractkit"
import BigNumber from "bignumber.js"
import marketplaceAbi from "../contract/marketplace.abi.json"
import erc20Abi from "../contract/erc20.abi.json"

const ERC20_DECIMALS = 18
const casinoContractAddress = "0xe84d540E2Fb6a9e0d07CCCf8237A64bB80b8bDC4"
const cUSDContractAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1"
const casinoOwnerAddress = '0xaC5521ED700507C121256aA19c0c6b398cA46868'

let kit
let contract
let products = []

var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
var popoverList = popoverTriggerList.map(function(popoverTriggerEl) {
  return new bootstrap.Popover(popoverTriggerEl)
})

document.addEventListener("DOMContentLoaded", function() {
  rollDice(Math.floor(Math.random() * 6 + 1))
});

const connectCeloWallet = async function() {
  if (window.celo) {
    notification("⚠️ Please approve this DApp to use it.")
    try {
      await window.celo.enable()
      notificationOff()

      const web3 = new Web3(window.celo)
      kit = newKitFromWeb3(web3)

      const accounts = await kit.web3.eth.getAccounts()
      kit.defaultAccount = accounts[0]

      contract = new kit.web3.eth.Contract(marketplaceAbi, casinoContractAddress)

      if (kit.defaultAccount == casinoOwnerAddress) {
        getCasinoBalance()
        document.querySelector("#casinoOwner").style.display = "block"
      }
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
  } else {
    notification("⚠️ Please install the CeloExtensionWallet.")
  }
}

async function approve(_price) {
  const cUSDContract = new kit.web3.eth.Contract(erc20Abi, cUSDContractAddress)

  const result = await cUSDContract.methods
    .approve(casinoContractAddress, _price)
    .send({
      from: kit.defaultAccount
    })
  return result
}

const getBalance = async function() {
  const totalBalance = await kit.getTotalBalance(kit.defaultAccount)
  const cUSDBalance = totalBalance.cUSD.shiftedBy(-ERC20_DECIMALS).toFixed(2)
  document.querySelector("#balance").textContent = cUSDBalance
}

const getCasinoBalance = async function() {
  const totalBalance = await contract.methods
    .getCasinoBalance()
    .call()
  const cUSDBalance = new BigNumber(totalBalance).shiftedBy(-ERC20_DECIMALS).toFixed(2)
  document.querySelector("#casinoBalance").textContent = cUSDBalance
}

function rollDice(diceNumber) {
  const element = document.getElementById('dice-box');
  const numberOfDice = 1;
  const options = {
    element,
    numberOfDice,
    callback: () => {},
    delay: 10000000000,
    values: [diceNumber]
  }
  rollADie(options);
}

function notification(_text) {
  document.querySelector(".alert").style.display = "block"
  document.querySelector("#notification").textContent = _text
}

function notificationOff() {
  document.querySelector(".alert").style.display = "none"
}

window.addEventListener("load", async () => {
  notification("⌛ Loading...")
  await connectCeloWallet()
  await getBalance()
  notificationOff()
});


document
  .querySelector("#withdrawButton")
  .addEventListener("click", async (e) => {
    try {
      await contract.methods
        .withdrawFunds(new BigNumber(document.getElementById("withdrawAmount").value)
          .shiftedBy(ERC20_DECIMALS)
          .toString())
        .send({
          from: kit.defaultAccount
        })

      getBalance()
      getCasinoBalance()
      document.getElementById("withdrawAmount").value = ''
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
    notification('Success!')
  });

document
  .querySelector("#depositButton")
  .addEventListener("click", async (e) => {
    notification("⌛ Waiting for payment approval...")
    const amount = new BigNumber(document.getElementById("withdrawAmount").value)
          .shiftedBy(ERC20_DECIMALS)
          .toString();
    try {
      await approve(amount)
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
    notification("Depositing...")
    try {
      await contract.methods
        .depositFunds(amount)
        .send({
          from: kit.defaultAccount
        })

      getBalance()

      getCasinoBalance()

      notification('Success!')
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
  });

document
  .querySelector("#playDice")
  .addEventListener("click", async (e) => {
    const params = [
      new BigNumber(document.getElementById("amount").value)
      .shiftedBy(ERC20_DECIMALS)
      .toString(),
      new BigNumber(document.getElementById("bet").value)
      .toString()
    ]
    notification("⌛ Waiting for payment approval...")
    try {
      await approve(params[0])
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
    notification("🎲 Rolling dice...")
    try {
      await contract.methods
        .playDice(...params)
        .send({
          from: kit.defaultAccount
        })

      const myLastDiceNumber = await contract.methods.getMyLastDiceNumber().call()

      rollDice(parseInt(myLastDiceNumber))

      getBalance()

      if (params[1] === myLastDiceNumber) {
        notification('🎉 You won!')
      } else {
        notification('It will be better next time!')
      }
    } catch (error) {
      notification(`⚠️ ${error}.`)
    }
  })