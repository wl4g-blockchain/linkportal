import React, { useState } from 'react';
import { ArrowLeftRight, ExternalLink, Calendar, DollarSign, Coins, AlertTriangle, Percent, ArrowRight } from 'lucide-react';
import RepayDetails from './RepayDetails';

interface LoanInfo {
  tokenId: string;
  tokenName: string;
  borrowDate: string;
  borrowAmount: number;
  tokenAmount: number;
  liquidationThreshold: number;
  annualInterestRate: number;
  accumulatedInterest: number;
  imageUrl: string;
}

export default function RepayPanel() {
  const [selectedLoan, setSelectedLoan] = useState<LoanInfo | null>(null);

  // Mock data - replace with actual borrowed tokens data from smart contract
  const loans: LoanInfo[] = [
    {
      tokenId: '1',
      tokenName: 'Luxury Villa #123',
      borrowDate: '2024-02-15',
      borrowAmount: 50000,
      tokenAmount: 0.2,
      liquidationThreshold: 75000,
      annualInterestRate: 8.5,
      accumulatedInterest: 850,
      imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6'
    },
    {
      tokenId: '2',
      tokenName: 'Commercial Space #456',
      borrowDate: '2024-03-01',
      borrowAmount: 30000,
      tokenAmount: 0.15,
      liquidationThreshold: 45000,
      annualInterestRate: 7.5,
      accumulatedInterest: 375,
      imageUrl: 'https://images.unsplash.com/photo-1570129477492-45c003edd2be'
    }
  ];

  return (
    <div className="max-w-6xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold mb-2">Active Loans</h2>
          <p className="text-slate-400">Manage and repay your borrowed assets</p>
        </div>
        <ArrowLeftRight size={32} className="text-blue-500" />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {loans.map(loan => (
          <div key={loan.tokenId} className="bg-slate-800 rounded-xl overflow-hidden border border-slate-700">
            <img
              src={loan.imageUrl}
              alt={loan.tokenName}
              className="w-full h-48 object-cover"
            />
            <div className="p-6">
              <div className="flex items-start justify-between mb-4">
                <h3 className="font-semibold">{loan.tokenName}</h3>
                <button
                  onClick={() => setSelectedLoan(loan)}
                  className="text-blue-500 hover:text-blue-400"
                >
                  <ExternalLink size={20} />
                </button>
              </div>

              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-slate-400 flex items-center gap-2">
                    <Calendar size={16} />
                    Borrow Date
                  </span>
                  <span>{loan.borrowDate}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-slate-400 flex items-center gap-2">
                    <DollarSign size={16} />
                    Borrowed
                  </span>
                  <span>{loan.borrowAmount.toLocaleString()} USDC</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-slate-400 flex items-center gap-2">
                    <Coins size={16} />
                    Token Amount
                  </span>
                  <span>{loan.tokenAmount} ERC1155</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-slate-400 flex items-center gap-2">
                    <AlertTriangle size={16} />
                    Liquidation At
                  </span>
                  <span>{loan.liquidationThreshold.toLocaleString()} USDC</span>
                </div>
              </div>

              <button
                onClick={() => setSelectedLoan(loan)}
                className="w-full mt-4 bg-blue-600 hover:bg-blue-700 py-2 rounded-lg font-medium transition-colors flex items-center justify-center gap-2"
              >
                View Details
                <ArrowRight size={20} />
              </button>
            </div>
          </div>
        ))}
      </div>

      {selectedLoan && (
        <RepayDetails
          loan={selectedLoan}
          onClose={() => setSelectedLoan(null)}
        />
      )}
    </div>
  );
}