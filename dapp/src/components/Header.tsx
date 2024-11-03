import React from 'react';
import { Coins } from 'lucide-react';

export default function Header() {
  return (
    <header className="bg-slate-800 border-b border-slate-700">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Coins className="text-blue-500" size={32} />
            <span className="text-xl font-bold">LinkPortal</span>
          </div>
          <button className="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg transition-colors">
            Connect Wallet
          </button>
        </div>
      </div>
    </header>
  );
}