export default async function main(args) {
	const [requestUrl] = args;
	const apiResponse = await Functions.makeHttpRequest({ url: requestUrl });
	const tokenURI = apiResponse.data.tokenURI;
	return tokenURI;
}
