#!/usr/bin/env node
const { ethers } = require("ethers");
const abi = [
    "function balanceOf(address owner) view returns (uint256)",
    "function decimals() view returns (uint8)",
    "function symbol() view returns (string)",
    "function transfer(address to, uint amount) returns (boolean)",
    "event Transfer(address indexed from, address indexed to, uint amount)"
];
const address = "0x2ac3c1d3e24b45c6c310534bc2dd84b5ed576335";
const provider = ethers.getDefaultProvider("http://localhost:18545");
const erc20 = new ethers.Contract(address, abi, provider);
erc20.symbol().then(p=>console.log(p))

console.log(erc20)

