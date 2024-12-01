import React, { useState } from 'react';
import { ArrowLeft, Building2 } from 'lucide-react';

interface AuctionDetailsProps {
  type: 'english' | 'dutch';
  auctionId: string;
  onBack: () => void;
}

export default function AuctionDetails({ type, auctionId, onBack }: AuctionDetailsProps) {
  const [bidAmount, setBidAmount] = useState('');

  // Mock data - replace with actual auction data from smart contract
  const auction = {
    id: auctionId,
    tokenId: '1',
    tokenName: 'Luxury Villa #123',
    imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6',
    currentPrice: 220000,
    startBid: 200000,
    highestBid: type === 'english' ? 220000 : 180000,
    bidder: '0x1234...5678',
    endTime: '2024-03-20',
    properties: {
      location: 'Miami, FL',
      size: '4,500 sq ft',
      bedrooms: 5,
      bathrooms: 4
    }
  };

  const handleBid = (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Bid submitted:', { auctionId, amount: bidAmount });
  };

  return (
    <div>
      <button
        onClick={onBack}
        className="flex items-center gap-2 text-slate-400 hover:text-white mb-6"
      >
        <ArrowLeft size={20} />
        Back to List
      </button>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div>
          <img
            src={auction.imageUrl}
            alt={auction.tokenName}
            className="w-full h-[400px] object-cover rounded-lg mb-6"
          />

          <div className="bg-slate-900 rounded-lg p-6">
            <h3 className="text-lg font-semibold mb-4">Property Details</h3>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <p className="text-slate-400">Location</p>
                <p className="font-medium">{auction.properties.location}</p>
              </div>
              <div>
                <p className="text-slate-400">Size</p>
                <p className="font-medium">{auction.properties.size}</p>
              </div>
              <div>
                <p className="text-slate-400">Bedrooms</p>
                <p className="font-medium">{auction.properties.bedrooms}</p>
              </div>
              <div>
                <p className="text-slate-400">Bathrooms</p>
                <p className="font-medium">{auction.properties.bathrooms}</p>
              </div>
            </div>
          </div>
        </div>

        <div className="space-y-6">
          <div className="bg-slate-900 rounded-lg p-6">
            <div className="flex items-center gap-3 mb-4">
              <Building2 size={24} className="text-blue-500" />
              <h2 className="text-2xl font-bold">{auction.tokenName}</h2>
            </div>

            <div className="space-y-4">
              <div>
                <p className="text-slate-400">Current Price</p>
                <p className="text-2xl font-bold">${auction.currentPrice.toLocaleString()} USDC</p>
              </div>
              <div>
                <p className="text-slate-400">Starting Bid</p>
                <p className="font-medium">${auction.startBid.toLocaleString()} USDC</p>
              </div>
              <div>
                <p className="text-slate-400">
                  {type === 'english' ? 'Highest' : 'Lowest'} Bid
                </p>
                <p className="font-medium">${auction.highestBid.toLocaleString()} USDC</p>
              </div>
              <div>
                <p className="text-slate-400">Current Bidder</p>
                <p className="font-medium">{auction.bidder}</p>
              </div>
              <div>
                <p className="text-slate-400">Ends At</p>
                <p className="font-medium">{auction.endTime}</p>
              </div>
            </div>
          </div>

          <form onSubmit={handleBid} className="bg-slate-900 rounded-lg p-6">
            <h3 className="text-lg font-semibold mb-4">Place a Bid</h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-slate-400 mb-2">
                  Bid Amount (USDC)
                </label>
                <input
                  type="number"
                  value={bidAmount}
                  onChange={(e) => setBidAmount(e.target.value)}
                  className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Enter bid amount"
                />
              </div>
              <button
                type="submit"
                className="w-full bg-blue-600 hover:bg-blue-700 py-3 rounded-lg font-medium transition-colors"
              >
                Place Bid
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}