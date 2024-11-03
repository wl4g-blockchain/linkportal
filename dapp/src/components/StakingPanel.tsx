import React, { useState } from 'react';
import { Shield, ArrowRight } from 'lucide-react';

export default function StakingPanel() {
  const [amount, setAmount] = useState('');

  return (
    <div className="max-w-2xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold mb-2">Liquidity Provider Staking</h2>
          <p className="text-slate-400">Stake your assets to earn fees and rewards</p>
        </div>
        <Shield size={32} className="text-blue-500" />
      </div>

      <div className="bg-slate-900 rounded-lg p-6 mb-6">
        <div className="flex justify-between mb-2">
          <span className="text-slate-400">Available to Stake</span>
          <span className="font-medium">1,000 USDC</span>
        </div>
        <div className="flex justify-between mb-4">
          <span className="text-slate-400">Current APY</span>
          <span className="text-green-500 font-medium">12.5%</span>
        </div>
        <div className="relative mb-4">
          <input
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="Enter amount to stake"
            className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button className="absolute right-2 top-1/2 -translate-y-1/2 px-4 py-1 text-sm bg-slate-700 rounded-md hover:bg-slate-600">
            MAX
          </button>
        </div>
        <button className="w-full bg-blue-600 hover:bg-blue-700 py-3 rounded-lg font-medium transition-colors flex items-center justify-center gap-2">
          Stake Assets
          <ArrowRight size={20} />
        </button>
      </div>

      <div className="bg-slate-900 rounded-lg p-6">
        <h3 className="text-lg font-semibold mb-4">Your Staking Position</h3>
        <div className="space-y-3">
          <div className="flex justify-between">
            <span className="text-slate-400">Staked Amount</span>
            <span>2,500 USDC</span>
          </div>
          <div className="flex justify-between">
            <span className="text-slate-400">Earned Rewards</span>
            <span className="text-green-500">+125 USDC</span>
          </div>
          <div className="flex justify-between">
            <span className="text-slate-400">Lock Period</span>
            <span>30 days</span>
          </div>
        </div>
      </div>
    </div>
  );
}