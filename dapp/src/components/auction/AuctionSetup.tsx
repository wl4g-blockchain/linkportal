import React, { useState } from 'react';
import { Calendar } from 'lucide-react';

interface AuctionSetupForm {
  tokenId: string;
  amount: string;
  startBid: string;
  startAt: string;
  expireAt: string;
  endPrice?: string;
  discountInterval?: string;
  discountStep?: string;
}

interface AuctionSetupProps {
  type: 'english' | 'dutch';
  onComplete: () => void;
}

export default function AuctionSetup({ type, onComplete }: AuctionSetupProps) {
  const [formData, setFormData] = useState<AuctionSetupForm>({
    tokenId: '',
    amount: '',
    startBid: '',
    startAt: '',
    expireAt: '',
    endPrice: '',
    discountInterval: '',
    discountStep: ''
  });

  // Mock data - replace with actual token data from smart contract
  const availableTokens = [
    { id: '1', name: 'Luxury Villa #123' },
    { id: '2', name: 'Commercial Space #456' }
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Auction setup submitted:', formData);
    onComplete();
  };

  return (
    <div className="bg-slate-900 rounded-lg p-6">
      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-slate-400 mb-2">
              Select Token
            </label>
            <select
              value={formData.tokenId}
              onChange={(e) => setFormData({ ...formData, tokenId: e.target.value })}
              className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Select a token</option>
              {availableTokens.map(token => (
                <option key={token.id} value={token.id}>
                  {token.name}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-400 mb-2">
              Amount
            </label>
            <input
              type="number"
              value={formData.amount}
              onChange={(e) => setFormData({ ...formData, amount: e.target.value })}
              className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter amount"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-400 mb-2">
              Start Bid (USDC)
            </label>
            <input
              type="number"
              value={formData.startBid}
              onChange={(e) => setFormData({ ...formData, startBid: e.target.value })}
              className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter start bid"
            />
          </div>

          {type === 'dutch' && (
            <div>
              <label className="block text-sm font-medium text-slate-400 mb-2">
                End Price (USDC)
              </label>
              <input
                type="number"
                value={formData.endPrice}
                onChange={(e) => setFormData({ ...formData, endPrice: e.target.value })}
                className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Enter end price"
              />
            </div>
          )}

          <div>
            <label className="block text-sm font-medium text-slate-400 mb-2">
              Start Time
            </label>
            <div className="relative">
              <Calendar className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
              <input
                type="datetime-local"
                value={formData.startAt}
                onChange={(e) => setFormData({ ...formData, startAt: e.target.value })}
                className="w-full bg-slate-800 border border-slate-700 rounded-lg pl-12 pr-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-400 mb-2">
              End Time
            </label>
            <div className="relative">
              <Calendar className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
              <input
                type="datetime-local"
                value={formData.expireAt}
                onChange={(e) => setFormData({ ...formData, expireAt: e.target.value })}
                className="w-full bg-slate-800 border border-slate-700 rounded-lg pl-12 pr-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
            </div>
          </div>

          {type === 'dutch' && (
            <>
              <div>
                <label className="block text-sm font-medium text-slate-400 mb-2">
                  Discount Interval (seconds)
                </label>
                <input
                  type="number"
                  value={formData.discountInterval}
                  onChange={(e) => setFormData({ ...formData, discountInterval: e.target.value })}
                  className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Enter discount interval"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-slate-400 mb-2">
                  Discount Step (USDC)
                </label>
                <input
                  type="number"
                  value={formData.discountStep}
                  onChange={(e) => setFormData({ ...formData, discountStep: e.target.value })}
                  className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Enter discount step"
                />
              </div>
            </>
          )}
        </div>

        <div className="flex gap-4">
          <button
            type="button"
            onClick={() => onComplete()}
            className="flex-1 bg-slate-700 hover:bg-slate-600 py-3 rounded-lg font-medium transition-colors"
          >
            Cancel
          </button>
          <button
            type="submit"
            className="flex-1 bg-blue-600 hover:bg-blue-700 py-3 rounded-lg font-medium transition-colors"
          >
            Create Auction
          </button>
        </div>
      </form>
    </div>
  );
}