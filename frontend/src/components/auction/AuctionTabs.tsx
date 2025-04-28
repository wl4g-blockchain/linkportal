import React, { useState } from 'react';
import EnglishAuction from './EnglishAuction';
import DutchAuction from './DutchAuction';

type AuctionType = 'english' | 'dutch';

export default function AuctionTabs() {
  const [activeTab, setActiveTab] = useState<AuctionType>('english');

  return (
    <div className="max-w-6xl mx-auto">
      <div className="flex gap-4 mb-6">
        <button
          onClick={() => setActiveTab('english')}
          className={`flex-1 py-3 px-6 rounded-lg font-medium transition-all ${
            activeTab === 'english'
              ? 'bg-blue-600 text-white'
              : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
          }`}
        >
          English Auction
        </button>
        <button
          onClick={() => setActiveTab('dutch')}
          className={`flex-1 py-3 px-6 rounded-lg font-medium transition-all ${
            activeTab === 'dutch'
              ? 'bg-blue-600 text-white'
              : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
          }`}
        >
          Dutch Auction
        </button>
      </div>

      {activeTab === 'english' ? <EnglishAuction /> : <DutchAuction />}
    </div>
  );
}