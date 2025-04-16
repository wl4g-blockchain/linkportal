import React, { useState } from 'react';
import { Wallet } from 'lucide-react';

interface BorrowForm {
  tokenId: string;
  borrowAmount: string;
  loanAmount: string;
  liquidationThreshold: string;
}

export default function BorrowPanel() {
  const [formData, setFormData] = useState<BorrowForm>({
    tokenId: '',
    borrowAmount: '',
    loanAmount: '',
    liquidationThreshold: ''
  });

  // Mock data - replace with actual token data from smart contract
  const availableTokens = [
    { id: '1', name: 'Luxury Villa #123' },
    { id: '2', name: 'Commercial Space #456' }
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Borrow form submitted:', formData);
  };

  return (
    <div className="max-w-2xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold mb-2">Borrow Against Your Asset</h2>
          <p className="text-slate-400">Use your tokenized property as collateral</p>
        </div>
        <Wallet size={32} className="text-blue-500" />
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="space-y-4">

          {/* 
          should to remove it, no needs
          <div>
            <label className="block text-sm font-medium text-slate-400 mb-2">
              Select Real Estate Token
            </label>
            <select
              value={formData.tokenId}
              onChange={(e) => setFormData({ ...formData, tokenId: e.target.value })}
              className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Select a token</option>
              {availableTokens.map(token => (
                <option key={token.id} value={token.id}>
                  {token.name}
                </option>
              ))}
            </select>
          </div> */}

          <div>
            <label className="block text-sm font-medium text-slate-400 mb-2">
              Borrow Amount (USDC)
            </label>
            <input
              type="number"
              value={formData.borrowAmount}
              onChange={(e) => setFormData({ ...formData, borrowAmount: e.target.value })}
              className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter amount to borrow"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-400 mb-2">
              Loan Amount (USDC)
            </label>
            <input
              type="number"
              value={formData.loanAmount}
              onChange={(e) => setFormData({ ...formData, loanAmount: e.target.value })}
              className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter loan amount"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-400 mb-2">
              Liquidation Threshold (%)
            </label>
            <input
              type="number"
              value={formData.liquidationThreshold}
              onChange={(e) => setFormData({ ...formData, liquidationThreshold: e.target.value })}
              className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter liquidation threshold"
            />
          </div>
        </div>

        <button
          type="submit"
          className="w-full bg-blue-600 hover:bg-blue-700 py-3 rounded-lg font-medium transition-colors"
        >
          Submit Borrow Request
        </button>
      </form>
    </div>
  );
}