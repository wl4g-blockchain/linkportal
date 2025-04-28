import React, { createContext, useContext, useState, useCallback } from 'react';
import { BrowserProvider, JsonRpcSigner } from 'ethers';

interface WalletContextType {
  isConnected: boolean;
  address: string | null;
  signer: JsonRpcSigner | null;
  connect: () => Promise<void>;
  disconnect: () => void;
  error: string | null;
}

const WalletContext = createContext<WalletContextType>({
  isConnected: false,
  address: null,
  signer: null,
  connect: async () => {},
  disconnect: () => {},
  error: null,
});

export function WalletProvider({ children }: { children: React.ReactNode }) {
  const [isConnected, setIsConnected] = useState(false);
  const [address, setAddress] = useState<string | null>(null);
  const [signer, setSigner] = useState<JsonRpcSigner | null>(null);
  const [error, setError] = useState<string | null>(null);

  const connect = useCallback(async () => {
    setError(null);

    if (typeof window === 'undefined') {
      setError('Window object not available');
      return;
    }

    if (typeof window.ethereum === 'undefined') {
      setError('Please install MetaMask to use this feature');
      return;
    }

    try {
      // Request account access
      const accounts = await window.ethereum.request({ 
        method: 'eth_requestAccounts',
        params: []
      });

      if (!accounts || accounts.length === 0) {
        setError('No accounts found');
        return;
      }

      // Get provider and signer
      const provider = new BrowserProvider(window.ethereum);
      const signer = await provider.getSigner();
      
      setIsConnected(true);
      setAddress(accounts[0]);
      setSigner(signer);

      // Listen for account changes
      window.ethereum.on('accountsChanged', (newAccounts: string[]) => {
        if (newAccounts.length === 0) {
          // User disconnected wallet
          disconnect();
        } else {
          // User switched account
          setAddress(newAccounts[0]);
        }
      });

      // Listen for chain changes
      window.ethereum.on('chainChanged', () => {
        // Reload the page when chain changes
        window.location.reload();
      });

    } catch (err) {
      console.error('Error connecting wallet:', err);
      setError(err instanceof Error ? err.message : 'Failed to connect wallet');
      setIsConnected(false);
      setAddress(null);
      setSigner(null);
    }
  }, []);

  const disconnect = useCallback(() => {
    setIsConnected(false);
    setAddress(null);
    setSigner(null);
    setError(null);

    // Remove event listeners
    if (window.ethereum) {
      window.ethereum.removeAllListeners('accountsChanged');
      window.ethereum.removeAllListeners('chainChanged');
    }
  }, []);

  return (
    <WalletContext.Provider value={{ 
      isConnected, 
      address, 
      signer, 
      connect, 
      disconnect,
      error 
    }}>
      {children}
    </WalletContext.Provider>
  );
}

export function useWallet() {
  return useContext(WalletContext);
}