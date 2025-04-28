import React, { useState } from 'react';
import { Building2, Wallet, ArrowRightLeft, Shield, PiggyBank } from 'lucide-react';
import Header from './components/Header';
import Stats from './components/Stats';
import TokenizationPanel from './components/tokenization/TokenizationPanel';
import TokenizedAssetsList from './components/tokenization/TokenizedAssetsList';
import BorrowPanel from './components/lending/BorrowPanel';
import RepayPanel from './components/lending/RepayPanel';
import AuctionTabs from './components/auction/AuctionTabs';
import StakingPanel from './components/StakingPanel';

type TabType = 'tokenize' | 'assets' | 'borrow' | 'repay' | 'auction' | 'staking';

function App() {
  const [activeTab, setActiveTab] = useState<TabType>('tokenize');

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-900 to-slate-800 text-white">
      <Header />
      
      <main className="container mx-auto px-4 py-8">
        <Stats />

        <div className="mt-8">
          <div className="flex flex-wrap gap-4 mb-6">
            <button
              onClick={() => setActiveTab('tokenize')}
              className={`flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all ${
                activeTab === 'tokenize'
                  ? 'bg-blue-600 text-white'
                  : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
              }`}
            >
              <Building2 size={20} />
              Tokenize Asset
            </button>
            <button
              onClick={() => setActiveTab('assets')}
              className={`flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all ${
                activeTab === 'assets'
                  ? 'bg-blue-600 text-white'
                  : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
              }`}
            >
              <ArrowRightLeft size={20} />
              My Assets
            </button>
            <button
              onClick={() => setActiveTab('borrow')}
              className={`flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all ${
                activeTab === 'borrow'
                  ? 'bg-blue-600 text-white'
                  : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
              }`}
            >
              <Wallet size={20} />
              Borrow
            </button>
            <button
              onClick={() => setActiveTab('repay')}
              className={`flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all ${
                activeTab === 'repay'
                  ? 'bg-blue-600 text-white'
                  : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
              }`}
            >
              <Shield size={20} />
              Repay
            </button>
            <button
              onClick={() => setActiveTab('auction')}
              className={`flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all ${
                activeTab === 'auction'
                  ? 'bg-blue-600 text-white'
                  : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
              }`}
            >
              <Building2 size={20} />
              Auction
            </button>
            <button
              onClick={() => setActiveTab('staking')}
              className={`flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all ${
                activeTab === 'staking'
                  ? 'bg-blue-600 text-white'
                  : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
              }`}
            >
              <PiggyBank size={20} />
              Staking
            </button>
          </div>

          <div className="bg-slate-800 rounded-xl p-6 shadow-xl border border-slate-700">
            {activeTab === 'tokenize' && <TokenizationPanel />}
            {activeTab === 'assets' && <TokenizedAssetsList />}
            {activeTab === 'borrow' && <BorrowPanel />}
            {activeTab === 'repay' && <RepayPanel />}
            {activeTab === 'auction' && <AuctionTabs />}
            {activeTab === 'staking' && <StakingPanel />}
          </div>
        </div>
      </main>
    </div>
  );
}

export default App;