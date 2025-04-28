import React, { useState } from 'react';
import { X, Calendar, DollarSign, Coins, AlertTriangle, Percent, ArrowRight, Building2 } from 'lucide-react';

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

interface RepayDetailsProps {
  loan: LoanInfo;
  onClose: () => void;
}

export default function RepayDetails({ loan, onClose }: RepayDetailsProps) {
  const [repayAmount, setRepayAmount] = useState('');
  const totalRepayAmount = loan.borrowAmount + loan.accumulatedInterest;

  const handleRepay = async () => {
    if (!repayAmount) return;

    try {
      // TODO: Call smart contract repay function
      console.log('Repaying loan:', {
        tokenId: loan.tokenId,
        amount: repayAmount
      });
    } catch (error) {
      console.error('Error repaying loan:', error);
    }
  };

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-slate-800 rounded-xl w-full max-w-4xl max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-slate-800 p-6 border-b border-slate-700 flex items-center justify-between">
          <h2 className="text-2xl font-bold flex items-center gap-3">
            <Building2 size={24} className="text-blue-500" />
            Loan Details
          </h2>
          <button
            onClick={onClose}
            className="p-2 hover:bg-slate-700 rounded-lg transition-colors"
          >
            <X size={20} />
          </button>
        </div>
        
        <div className="p-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <img
                src={loan.imageUrl}
                alt={loan.tokenName}
                className="w-full h-[300px] object-cover rounded-lg mb-4"
              />
              <h3 className="text-xl font-semibold mb-4">{loan.tokenName}</h3>
              
              <div className="bg-slate-900 rounded-lg p-6 space-y-4">
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
                    Borrowed Amount
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
                    Liquidation Threshold
                  </span>
                  <span>{loan.liquidationThreshold.toLocaleString()} USDC</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-slate-400 flex items-center gap-2">
                    <Percent size={16} />
                    Annual Interest Rate
                  </span>
                  <span>{loan.annualInterestRate}%</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-slate-400 flex items-center gap-2">
                    <DollarSign size={16} />
                    Accumulated Interest
                  </span>
                  <span className="text-yellow-500">
                    {loan.accumulatedInterest.toLocaleString()} USDC
                  </span>
                </div>
              </div>
            </div>

            <div className="bg-slate-900 rounded-lg p-6">
              <h4 className="text-lg font-semibold mb-6">Repay Loan</h4>
              
              <div className="space-y-6">
                <div>
                  <label className="block text-sm font-medium text-slate-400 mb-2">
                    Total Amount to Repay
                  </label>
                  <div className="text-3xl font-bold text-blue-500">
                    {totalRepayAmount.toLocaleString()} USDC
                  </div>
                  <p className="text-sm text-slate-400 mt-1">
                    Principal: {loan.borrowAmount.toLocaleString()} USDC + 
                    Interest: {loan.accumulatedInterest.toLocaleString()} USDC
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium text-slate-400 mb-2">
                    Repay Amount (USDC)
                  </label>
                  <div className="relative">
                    <input
                      type="number"
                      value={repayAmount}
                      onChange={(e) => setRepayAmount(e.target.value)}
                      className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
                      placeholder="Enter amount to repay"
                    />
                    <button
                      onClick={() => setRepayAmount(totalRepayAmount.toString())}
                      className="absolute right-2 top-1/2 -translate-y-1/2 px-3 py-1 text-sm bg-slate-700 rounded-md hover:bg-slate-600"
                    >
                      MAX
                    </button>
                  </div>
                </div>

                <button
                  onClick={handleRepay}
                  disabled={!repayAmount || parseFloat(repayAmount) <= 0}
                  className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-slate-700 disabled:cursor-not-allowed py-3 rounded-lg font-medium transition-colors flex items-center justify-center gap-2"
                >
                  Repay Loan
                  <ArrowRight size={20} />
                </button>

                <div className="text-sm text-slate-400">
                  <p className="mb-2">Note:</p>
                  <ul className="list-disc list-inside space-y-1">
                    <li>Full repayment will return your collateral</li>
                    <li>Partial repayments are not allowed</li>
                    <li>Interest continues to accrue until full repayment</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}