import React, { useState } from 'react';
import { Building2, Wallet, ArrowRightLeft, Shield, BarChart3, FileCheck } from 'lucide-react';
import Header from './components/Header';
import StakingPanel from './components/StakingPanel';
import InvestmentPanel from './components/InvestmentPanel';
import TokenizationPanel from './components/TokenizationPanel';
import NFTCollection from './components/NFTCollection';
import Stats from './components/Stats';

type TabType = 'stake' | 'invest' | 'tokenize' | 'collection';

function App() {
  const [activeTab, setActiveTab] = useState<TabType>('stake');

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-900 to-slate-800 text-white">
      <Header />
      
      <main className="container mx-auto px-4 py-8">
        <Stats />

        <div className="mt-8">
          <div className="flex flex-wrap gap-4 mb-6">
            <button
              onClick={() => setActiveTab('stake')}
              className={`flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all ${
                activeTab === 'stake'
                  ? 'bg-blue-600 text-white'
                  : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
              }`}
            >
              <Shield size={20} />
              LP Staking
            </button>
            <button
              onClick={() => setActiveTab('invest')}
              className={`flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all ${
                activeTab === 'invest'
                  ? 'bg-blue-600 text-white'
                  : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
              }`}
            >
              <BarChart3 size={20} />
              Invest
            </button>
            <button
              onClick={() => setActiveTab('tokenize')}
              className={`flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all ${
                activeTab === 'tokenize'
                  ? 'bg-blue-600 text-white'
                  : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
              }`}
            >
              <FileCheck size={20} />
              Tokenize
            </button>
            <button
              onClick={() => setActiveTab('collection')}
              className={`flex items-center gap-2 px-6 py-3 rounded-lg font-medium transition-all ${
                activeTab === 'collection'
                  ? 'bg-blue-600 text-white'
                  : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
              }`}
            >
              <Building2 size={20} />
              Collection
            </button>
          </div>

          <div className="bg-slate-800 rounded-xl p-6 shadow-xl border border-slate-700">
            {activeTab === 'stake' && <StakingPanel />}
            {activeTab === 'invest' && <InvestmentPanel />}
            {activeTab === 'tokenize' && <TokenizationPanel />}
            {activeTab === 'collection' && <NFTCollection />}
          </div>
        </div>

        <div className="mt-16 grid md:grid-cols-3 gap-8">
          <div className="bg-slate-800 p-6 rounded-xl border border-slate-700">
            <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center mb-4">
              <Building2 size={24} />
            </div>
            <h3 className="text-xl font-semibold mb-2">Real World Assets</h3>
            <p className="text-slate-400">Access tokenized real estate, commodities, and other traditional assets on-chain.</p>
          </div>
          <div className="bg-slate-800 p-6 rounded-xl border border-slate-700">
            <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center mb-4">
              <ArrowRightLeft size={24} />
            </div>
            <h3 className="text-xl font-semibold mb-2">Instant Liquidity</h3>
            <p className="text-slate-400">Provide or access liquidity instantly with our automated market making system.</p>
          </div>
          <div className="bg-slate-800 p-6 rounded-xl border border-slate-700">
            <div className="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center mb-4">
              <Wallet size={24} />
            </div>
            <h3 className="text-xl font-semibold mb-2">Yield Generation</h3>
            <p className="text-slate-400">Earn competitive yields by providing liquidity or investing in RWA pools.</p>
          </div>
        </div>
      </main>
    </div>
  );
}

export default App;