// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library NetworkConfig {
    struct NetworkInfo {
        address linkToken;
        address ccipRouter;
        address functionsRouter;
        uint64 chainSelector;
        string name;
        uint256 chainId;
        address usdcUsdAggregator;
        uint256 usdcUsdFeedHeartbeatInterval;
    }

    function getNetworkConfig(
        uint256 chainId
    ) internal pure returns (NetworkInfo memory) {
        // Ethereum Mainnet
        if (chainId == 1) {
            // see:https://docs.chain.link/ccip/directory/mainnet/chain/mainnet
            return
                NetworkInfo({
                    linkToken: 0x514910771AF9Ca656af840dff83E8264EcF986CA,
                    ccipRouter: 0x80226fc0Ee2b096224EeAc085Bb9a8cba1146f7D,
                    // see:https://docs.chain.link/chainlink-functions/supported-networks#ethereum
                    functionsRouter: 0x65Dcc24F8ff9e51F10DCc7Ed1e4e2A61e6E14bd6,
                    chainSelector: 5009297550715157269,
                    name: "Ethereum Mainnet",
                    chainId: chainId,
                    usdcUsdAggregator: 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6,
                    usdcUsdFeedHeartbeatInterval: 3600
                });
        }
        // Sepolia Testnet
        if (chainId == 11155111) {
            // see:https://docs.chain.link/ccip/directory/testnet/chain/ethereum-testnet-sepolia
            return
                NetworkInfo({
                    linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
                    ccipRouter: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
                    // see:https://docs.chain.link/chainlink-functions/supported-networks#sepolia-testnet
                    functionsRouter: 0xb83E47C2bC239B3bf370bc41e1459A34b41238D0,
                    chainSelector: 16015286601757825753,
                    name: "Sepolia Testnet",
                    chainId: chainId,
                    usdcUsdAggregator: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E,
                    usdcUsdFeedHeartbeatInterval: 3600
                });
        }
        // Avalanche Mainnet
        if (chainId == 43114) {
            // see:https://docs.chain.link/ccip/directory/mainnet/chain/avalanche-mainnet
            return
                NetworkInfo({
                    linkToken: 0x5947BB275c521040051D82396192181b413227A3,
                    ccipRouter: 0xF4c7E640EdA248ef95972845a62bdC74237805dB,
                    // see:https://docs.chain.link/chainlink-functions/supported-networks#avalanche-mainnet
                    functionsRouter: 0x9f82a6A0758517FD0AfA463820F586999AF314a0,
                    chainSelector: 6433500567565415381,
                    name: "Avalanche Mainnet",
                    chainId: chainId,
                    usdcUsdAggregator: 0xF096872672F44d6EBA71458D74fe67F9a77a23B9,
                    usdcUsdFeedHeartbeatInterval: 3600
                });
        }
        // Avalanche Fuji Testnet
        if (chainId == 43113) {
            // see:https://docs.chain.link/ccip/directory/testnet/chain/avalanche-fuji-testnet
            return
                NetworkInfo({
                    linkToken: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846,
                    ccipRouter: 0xF694E193200268f9a4868e4Aa017A0118C9a8177,
                    // see:https://docs.chain.link/chainlink-functions/supported-networks#avalanche-fuji-testnet
                    functionsRouter: 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0,
                    chainSelector: 14767482510784806043,
                    name: "Avalanche Fuji",
                    chainId: chainId,
                    usdcUsdAggregator: 0x97FE42a7E96640D932bbc0e1580c73E705A8EB73,
                    usdcUsdFeedHeartbeatInterval: 3600
                });
        }
        // Optimism Mainnet
        if (chainId == 10) {
            // see:https://docs.chain.link/chainlink-functions/supported-networks#optimism-mainnet
            return
                NetworkInfo({
                    linkToken: 0x350a791Bfc2C21F9Ed5d10980Dad2e2638ffa7f6,
                    ccipRouter: 0x3206695CaE29952f4b0c22a169725a865bc8Ce0f,
                    // see:https://docs.chain.link/chainlink-functions/supported-networks#optimism-mainnet
                    functionsRouter: 0xaA8AaA682C9eF150C0C8E96a8D60945BCB21faad,
                    chainSelector: 3734403246176062136,
                    name: "Optimism Mainnet",
                    chainId: chainId,
                    usdcUsdAggregator: 0x16a9FA2FDa030272Ce99B29CF780dFA30361E0f3,
                    usdcUsdFeedHeartbeatInterval: 3600
                });
        }
        // Optimism Sepolia Testnet
        if (chainId == 420) {
            // see:https://docs.chain.link/ccip/directory/testnet/chain/ethereum-testnet-sepolia-optimism-1
            return
                NetworkInfo({
                    linkToken: 0xE4aB69C077896252FAFBD49EFD26B5D171A32410,
                    ccipRouter: 0x114A20A10b43D4115e5aeef7345a1A71d2a60C57,
                    // see:https://docs.chain.link/chainlink-functions/supported-networks#optimism-sepolia-testnet
                    functionsRouter: 0xC17094E3A1348E5C7544D4fF8A36c28f2C6AAE28,
                    chainSelector: 5224473277236331295,
                    name: "Optimism Sepolia",
                    chainId: chainId,
                    usdcUsdAggregator: 0x6e44e50E3cc14DD16e01C590DC1d7020cb36eD4C,
                    usdcUsdFeedHeartbeatInterval: 3600
                });
        }
        // // BSC Mainnet
        // if (chainId == 56) {
        //     // see:https://docs.chain.link/ccip/directory/mainnet/chain/bsc-mainnet
        //     return
        //         NetworkInfo({
        //             linkToken: 0x404460C6A5EdE2D891e8297795264fDe62ADBB75,
        //             ccipRouter: 0x34B03Cb9086d7D758AC55af71584F81A598759FE,
        //             // see: TODO Not implemented yet?
        //             functionsRouter: 0x4D7Bd0c9d7219A743737e5655376a192Ac72C0F8,
        //             chainSelector: 11344663589394136015,
        //             name: "BSC Mainnet",
        //             chainId: chainId
        //         });
        // }
        // // BSC Testnet
        // if (chainId == 97) {
        //     // see:https://docs.chain.link/ccip/directory/testnet/chain/bsc-testnet
        //     return
        //         NetworkInfo({
        //             linkToken: 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06,
        //             ccipRouter: 0xE1053aE1857476f36A3C62580FF9b016E8EE8F6f,
        //             // see: TODO Not implemented yet?
        //             functionsRouter: 0x9FF23B05dd151CdE9cE79E5Ab4eE0B23Ab19d4a4,
        //             chainSelector: 13264668187771770619,
        //             name: "BSC Testnet",
        //             chainId: chainId
        //         });
        // }

        revert("Network not supported");
    }
}
