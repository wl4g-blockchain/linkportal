import React, { useState } from 'react';
import { ArrowUpRight, ArrowDownRight, BarChart3 } from 'lucide-react';

export default function InvestmentPanel() {
  const [activeAction, setActiveAction] = useState<'deposit' | 'withdraw'>('deposit');
  const [amount, setAmount] = useState('');

  return (
    <div className="max-w-2xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold mb-2">Investment Portal</h2>
          <p className="text-slate-400">Deposit or withdraw from RWA pools</p>
        </div>
        <BarChart3 size={32} className="text-blue-500" />
      </div>

      <div className="flex gap-4 mb-6">
        <button
          onClick={() => setActiveAction('deposit')}
          className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-lg font-medium transition-all ${
            activeAction === 'deposit'
              ? 'bg-green-600 text-white'
              : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
          }`}
        >
          <ArrowUpRight size={20} />
          Deposit
        </button>
        <button
          onClick={() => setActiveAction('withdraw')}
          className={`flex-1 flex items-center justify-center gap-2 py-3 rounded-lg font-medium transition-all ${
            activeAction === 'withdraw'
              ? 'bg-red-600 text-white'
              : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
          }`}
        >
          <ArrowDownRight size={20} />
          Withdraw
        </button>
      </div>

      <div className="bg-slate-900 rounded-lg p-6 mb-6">
        <div className="flex justify-between mb-2">
          <span className="text-slate-400">Available Balance</span>
          <span className="font-medium">5,000 USDC</span>
        </div>
        <div className="flex justify-between mb-4">
          <span className="text-slate-400">Expected Return</span>
          <span className="text-green-500 font-medium">8.2% APY</span>
        </div>
        <div className="relative mb-4">
          <input
            type="number"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder={`Enter amount to ${activeAction}`}
            className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button className="absolute right-2 top-1/2 -translate-y-1/2 px-4 py-1 text-sm bg-slate-700 rounded-md hover:bg-slate-600">
            MAX
          </button>
        </div>
        <button 
          className={`w-full py-3 rounded-lg font-medium transition-colors flex items-center justify-center gap-2 ${
            activeAction === 'deposit' 
              ? 'bg-green-600 hover:bg-green-700' 
              : 'bg-red-600 hover:bg-red-700'
          }`}
        >
          {activeAction === 'deposit' ? 'Deposit' : 'Withdraw'} Assets
          {activeAction === 'deposit' ? <ArrowUpRight size={20} /> : <ArrowDownRight size={20} />}
        </button>
      </div>

      <div className="bg-slate-900 rounded-lg p-6">
        <h3 className="text-lg font-semibold mb-4">Investment Overview</h3>
        <div className="space-y-3">
          <div className="flex justify-between">
            <span className="text-slate-400">Total Invested</span>
            <span>10,000 USDC</span>
          </div>
          <div className="flex justify-between">
            <span className="text-slate-400">Current Value</span>
            <span className="text-green-500">10,820 USDC</span>
          </div>
          <div className="flex justify-between">
            <span className="text-slate-400">Profit/Loss</span>
            <span className="text-green-500">+820 USDC (+8.2%)</span>
          </div>
        </div>
      </div>
    </div>
  );
}