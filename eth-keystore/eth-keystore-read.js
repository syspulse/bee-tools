#!/usr/bin/env node
const { ethers } = require("ethers");
const fs = require('fs')
if(process.argv.length<4) { console.log("eth-keystore <keystore> <password>"); process.exit(1);}
let file = process.argv[2];
let pass = process.argv[3];
fs.readFile(file, 'utf8', (e,json) => {
    if (e) { console.log(file+" ", err); return }
    console.log(json);
    ethers.Wallet.fromEncryptedJson(json,pass).then( (w)=> {
        console.log(w);
        console.log(w._signingKey())
    })
})
