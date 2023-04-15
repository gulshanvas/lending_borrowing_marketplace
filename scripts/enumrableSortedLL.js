const hre = require("hardhat");

async function main() {
  const EnuerableSortedLLOrderBook = await hre.ethers.getContractFactory("OrderBook");

  const enuerableSortedLLOrderBookInstance = await EnuerableSortedLLOrderBook.deploy();

  await enuerableSortedLLOrderBookInstance.add(10, 25, 0);
  await enuerableSortedLLOrderBookInstance.add(10, 25, 0);


}

main().then(console.log);