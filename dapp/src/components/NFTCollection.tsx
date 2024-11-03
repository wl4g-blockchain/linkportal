import React from 'react';
import { Building2, DollarSign, ExternalLink, RefreshCw } from 'lucide-react';

interface NFT {
  id: string;
  address: string;
  value: number;
  lastUpdate: string;
  imageUrl: string;
}

export default function NFTCollection() {
  // Mock data - replace with actual NFT data
  const nfts: NFT[] = [
    {
      id: '1',
      address: '123 Crypto Street, Blockchain City',
      value: 250000,
      lastUpdate: '2024-03-15',
      imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6'
    },
    {
      id: '2',
      address: '456 DeFi Avenue, Web3 Valley',
      value: 180000,
      lastUpdate: '2024-03-15',
      imageUrl: 'https://images.unsplash.com/photo-1570129477492-45c003edd2be'
    }
  ];

  return (
    <div className="max-w-6xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold mb-2">Your Tokenized Properties</h2>
          <p className="text-slate-400">Manage your real estate NFT collection</p>
        </div>
        <button className="flex items-center gap-2 px-4 py-2 bg-slate-700 rounded-lg hover:bg-slate-600">
          <RefreshCw size={20} />
          Refresh Values
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {nfts.map(nft => (
          <div key={nft.id} className="bg-slate-800 rounded-xl overflow-hidden border border-slate-700">
            <img
              src={nft.imageUrl}
              alt={`Property ${nft.address}`}
              className="w-full h-48 object-cover"
            />
            <div className="p-6">
              <div className="flex items-start justify-between mb-4">
                <div>
                  <h3 className="font-semibold mb-1 flex items-center gap-2">
                    <Building2 size={20} className="text-blue-500" />
                    Property #{nft.id}
                  </h3>
                  <p className="text-sm text-slate-400">{nft.address}</p>
                </div>
                <a
                  href="#"
                  className="text-blue-500 hover:text-blue-400"
                  title="View on Explorer"
                >
                  <ExternalLink size={20} />
                </a>
              </div>

              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-slate-400">Current Value</span>
                  <span className="font-medium flex items-center gap-1">
                    <DollarSign size={16} />
                    {nft.value.toLocaleString()}
                  </span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-slate-400">Last Update</span>
                  <span className="text-sm">{nft.lastUpdate}</span>
                </div>
              </div>

              <div className="mt-6 grid grid-cols-2 gap-4">
                <button className="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg font-medium transition-colors">
                  Trade
                </button>
                <button className="px-4 py-2 bg-slate-700 hover:bg-slate-600 rounded-lg font-medium transition-colors">
                  Details
                </button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}