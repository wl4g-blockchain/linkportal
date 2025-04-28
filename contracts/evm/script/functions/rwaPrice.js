export default async function main(args) {	
	const { ethers } = require("ethers");
	const { defaultAbiCoder, BigNumber } = ethers.utils;

	const [tokenIdArg, requestUrl] = args;
	const tokenId = BigNumber.from(tokenIdArg);

	let apiResponse;
	try {
		apiResponse = await Functions.makeHttpRequest({
			url: requestUrl,
		});
	} catch (err) {
		throw new Error(`HTTP request failed: ${err.message}`);
	}

	if (!apiResponse.data?.ListPrice) {
		throw new Error(`Invalid API response: missing ListPrice`);
	}
	const listPrice = BigNumber.from(apiResponse.data.ListPrice.toString());
	const encoded = abiCoder.encodeHexString(
		[`uint256`, `uint256`],
		[tokenId, listPrice]
	);
	return ethers.getBytes(encoded);
}
