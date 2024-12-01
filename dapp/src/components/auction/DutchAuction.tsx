import React, { useState } from 'react';
import { TrendingDown, ArrowUpRight } from 'lucide-react';
import AuctionSetup from './AuctionSetup';
import AuctionList from './AuctionList';
import AuctionDetails from './AuctionDetails';

type AuctionView = 'setup' | 'list' | 'details';

export default function DutchAuction() {
  const [view, setView] = useState<AuctionView>('list');
  const [selectedAuctionId, setSelectedAuctionId] = useState<string | null>(null);

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold mb-2">Dutch Auction</h2>
          <p className="text-slate-400">Bid on assets with decreasing prices</p>
        </div>
        <TrendingDown size={32} className="text-blue-500" />
      </div>

      <div className="flex gap-4 mb-6">
        <button
          onClick={() => setView('setup')}
          className={`flex items-center gap-2 px-6 py-2 rounded-lg font-medium transition-all ${
            view === 'setup'
              ? 'bg-green-600 text-white'
              : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
          }`}
        >
          <ArrowUpRight size={20} />
          Create Auction
        </button>
      </div>

      {view === 'setup' && <AuctionSetup type="dutch" onComplete={() => setView('list')} />}
      {view === 'list' && (
        <AuctionList
          type="dutch"
          onSelectAuction={(id) => {
            setSelectedAuctionId(id);
            setView('details');
          }}
        />
      )}
      {view === 'details' && selectedAuctionId && (
        <AuctionDetails
          type="dutch"
          auctionId={selectedAuctionId}
          onBack={() => setView('list')}
        />
      )}
    </div>
  );
}