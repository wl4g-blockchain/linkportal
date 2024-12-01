import React from 'react';
import { ExternalLink, Building2 } from 'lucide-react';

interface Auction {
  id: string;
  tokenId: string;
  tokenName: string;
  startBid: number;
  currentBid: number;
  bidder: string;
  endTime: string;
}

interface AuctionListProps {
  type: 'english' | 'dutch';
  onSelectAuction: (id: string) => void;
}

export default function AuctionList({ type, onSelectAuction }: AuctionListProps) {
  // Mock data - replace with actual auction data from smart contract
  const auctions: Auction[] = [
    {
      id: '1',
      tokenId: '1',
      tokenName: 'Luxury Villa #123',
      startBid: 200000,
      currentBid: type === 'english' ? 220000 : 180000,
      bidder: '0x1234...5678',
      endTime: '2024-03-20'
    },
    {
      id: '2',
      tokenId: '2',
      tokenName: 'Commercial Space #456',
      startBid: 150000,
      currentBid: type === 'english' ? 160000 : 140000,
      bidder: '0x8765...4321',
      endTime: '2024-03-21'
    }
  ];

  return (
    <div className="overflow-x-auto">
      <table className="w-full">
        <thead>
          <tr className="text-left border-b border-slate-700">
            <th className="pb-4 font-medium text-slate-400">Token ID</th>
            <th className="pb-4 font-medium text-slate-400">Name</th>
            <th className="pb-4 font-medium text-slate-400">Start Bid</th>
            <th className="pb-4 font-medium text-slate-400">
              {type === 'english' ? 'Highest' : 'Lowest'} Bid
            </th>
            <th className="pb-4 font-medium text-slate-400">Current Bidder</th>
            <th className="pb-4 font-medium text-slate-400">End Time</th>
            <th className="pb-4 font-medium text-slate-400">Actions</th>
          </tr>
        </thead>
        <tbody>
          {auctions.map(auction => (
            <tr key={auction.id} className="border-b border-slate-700">
              <td className="py-4">{auction.tokenId}</td>
              <td className="py-4 flex items-center gap-2">
                <Building2 size={20} className="text-blue-500" />
                {auction.tokenName}
              </td>
              <td className="py-4">${auction.startBid.toLocaleString()}</td>
              <td className="py-4">${auction.currentBid.toLocaleString()}</td>
              <td className="py-4">{auction.bidder}</td>
              <td className="py-4">{auction.endTime}</td>
              <td className="py-4">
                <button
                  onClick={() => onSelectAuction(auction.id)}
                  className="text-blue-500 hover:text-blue-400"
                >
                  <ExternalLink size={20} />
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}