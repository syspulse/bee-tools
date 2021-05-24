#!/usr/bin/env node
const { ethers } = require("ethers");
const fs = require('fs')
if(process.argv.length<4) { console.log("eth-keystore <PrivateKey> <password>"); process.exit(1);}
let SK = process.argv[2];
let pass = process.argv[3];
let w = new ethers.Wallet(SK)
w.encrypt(pass).then( (json) => { console.log(json); fs.writeFile('keystore.json', json, e => {})})
