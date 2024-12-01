import React from 'react';
import { Coins } from 'lucide-react';
import { useWallet } from '../contexts/WalletContext';

export default function Header() {
  const { isConnected, address, connect, disconnect, error } = useWallet();

  const handleConnect = async () => {
    try {
      await connect();
    } catch (err) {
      console.error('Failed to connect:', err);
    }
  };

  return (
    <header className="bg-slate-800 border-b border-slate-700">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Coins className="text-blue-500" size={32} />
            <span className="text-xl font-bold">LinkPortal™</span>
          </div>
          <div className="flex items-center gap-4">
            {error && (
              <span className="text-sm text-red-500">{error}</span>
            )}
            {isConnected ? (
              <div className="flex items-center gap-4">
                <span className="text-sm text-slate-400">
                  {address?.slice(0, 6)}...{address?.slice(-4)}
                </span>
                <button
                  onClick={disconnect}
                  className="px-4 py-2 bg-red-600 hover:bg-red-700 rounded-lg transition-colors"
                >
                  Disconnect
                </button>
              </div>
            ) : (
              <button
                onClick={handleConnect}
                className="px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded-lg transition-colors"
              >
                Connect Wallet
              </button>
            )}
          </div>
        </div>
      </div>
    </header>
  );
}