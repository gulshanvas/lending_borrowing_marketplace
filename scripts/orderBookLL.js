const hre = require("hardhat");
const ethers = require("ethers");

const {parseEther} = ethers.utils;
// console.log('ethers ',ethers);


async function main() {
  const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
  const OrderBookLL = await hre.ethers.getContractFactory("OrderBookLL");

  const orderBookLLInstance = await OrderBookLL.deploy(ZERO_ADDRESS, ZERO_ADDRESS, ZERO_ADDRESS);

  const user1 = "0x95222290DD7278Aa3Ddd389Cc1E1d165CC4BAfe5";
  const user2 = "0xC7C69a47e329dEBcF2F58f5C2230922c1CFa075A";
  const user3 = "0xD57DEe6EB101f50356BF4F5cFB4eFb0139C48251";
  const user4 = "0x4Be76C39725763390cABE15bA578835980CB939F";

  // await orderBookLLInstance.lend(4, parseEther("1"), user1);
  // await orderBookLLInstance.lend(5, parseEther("5"), user2);
  // await orderBookLLInstance.lend(2, parseEther("2"), user3);
  // await orderBookLLInstance.lend(2, parseEther("3"), user4);

  console.log('size : ', await orderBookLLInstance.size());

  // console.log('at index ', await orderBookLLInstance.getNode(0));
  // console.log('at index ', await orderBookLLInstance.getNode(1));
  // console.log('at index ', await orderBookLLInstance.getNode(2));
  // console.log('at index ', await orderBookLLInstance.getNode(3));

  console.log('borrowable amount ', await orderBookLLInstance.calculateBorrowableAmount(parseEther("0.00000000000000001")));

}

main().then(console.log);