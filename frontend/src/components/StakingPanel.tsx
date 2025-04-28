import React, { useState } from 'react';
import ReactECharts from 'echarts-for-react';
import { Wallet, TrendingUp, ArrowRight, PiggyBank, History } from 'lucide-react';

interface StakingStats {
  totalStaked: number;
  availableLiquidity: number;
  currentAPY: number;
  yourStaked: number;
  yourEarnings: number;
}

interface EarningsHistory {
  date: string;
  earnings: number;
}

export default function StakingPanel() {
  const [amount, setAmount] = useState('');

  // Mock data - replace with actual data from smart contract
  const stats: StakingStats = {
    totalStaked: 1500000,
    availableLiquidity: 850000,
    currentAPY: 12.5,
    yourStaked: 50000,
    yourEarnings: 1250
  };

  // Mock earnings history data
  const earningsHistory: EarningsHistory[] = [
    { date: '2024-01', earnings: 180 },
    { date: '2024-02', earnings: 220 },
    { date: '2024-03', earnings: 280 },
    { date: '2024-04', earnings: 350 },
    { date: '2024-05', earnings: 420 },
    { date: '2024-06', earnings: 380 }
  ];

  const chartOption = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      },
      formatter: (params: any) => {
        const data = params[0];
        return `${data.name}<br/>Earnings: ${data.value} USDC`;
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: earningsHistory.map(item => item.date),
      axisLabel: {
        color: '#94a3b8'
      }
    },
    yAxis: {
      type: 'value',
      axisLabel: {
        color: '#94a3b8',
        formatter: (value: number) => `${value} USDC`
      },
      splitLine: {
        lineStyle: {
          color: '#334155'
        }
      }
    },
    series: [
      {
        name: 'Earnings',
        type: 'bar',
        data: earningsHistory.map(item => item.earnings),
        itemStyle: {
          color: '#3b82f6'
        },
        emphasis: {
          itemStyle: {
            color: '#2563eb'
          }
        }
      }
    ],
    backgroundColor: 'transparent'
  };

  const handleStake = async () => {
    if (!amount) return;
    try {
      // TODO: Call smart contract stake function
      console.log('Staking:', amount, 'USDC');
    } catch (error) {
      console.error('Error staking:', error);
    }
  };

  return (
    <div className="max-w-6xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold mb-2">Liquidity Provider Staking</h2>
          <p className="text-slate-400">Stake USDC to earn fees from RWA lending</p>
        </div>
        <Wallet size={32} className="text-blue-500" />
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-xl p-6">
          <div className="flex items-center gap-4">
            <div className="p-3 bg-blue-500 bg-opacity-30 rounded-lg">
              <PiggyBank size={24} />
            </div>
            <div>
              <p className="text-sm text-blue-200">Total Value Staked</p>
              <p className="text-2xl font-bold">${stats.totalStaked.toLocaleString()}</p>
            </div>
          </div>
        </div>

        <div className="bg-gradient-to-r from-indigo-600 to-indigo-700 rounded-xl p-6">
          <div className="flex items-center gap-4">
            <div className="p-3 bg-indigo-500 bg-opacity-30 rounded-lg">
              <Wallet size={24} />
            </div>
            <div>
              <p className="text-sm text-indigo-200">Available Liquidity</p>
              <p className="text-2xl font-bold">${stats.availableLiquidity.toLocaleString()}</p>
            </div>
          </div>
        </div>

        <div className="bg-gradient-to-r from-purple-600 to-purple-700 rounded-xl p-6">
          <div className="flex items-center gap-4">
            <div className="p-3 bg-purple-500 bg-opacity-30 rounded-lg">
              <TrendingUp size={24} />
            </div>
            <div>
              <p className="text-sm text-purple-200">Current APY</p>
              <p className="text-2xl font-bold">{stats.currentAPY}%</p>
            </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-slate-800 rounded-xl p-6">
          <h3 className="text-lg font-semibold mb-6 flex items-center gap-2">
            <History size={20} className="text-blue-500" />
            Earnings History
          </h3>
          <ReactECharts 
            option={chartOption}
            style={{ height: '300px' }}
          />
        </div>

        <div className="bg-slate-800 rounded-xl p-6">
          <h3 className="text-lg font-semibold mb-6">Stake USDC</h3>
          
          <div className="space-y-6">
            <div className="bg-slate-900 rounded-lg p-4 space-y-2">
              <div className="flex justify-between">
                <span className="text-slate-400">Your Staked Amount</span>
                <span className="font-medium">${stats.yourStaked.toLocaleString()} USDC</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-400">Your Earnings</span>
                <span className="text-green-500">+${stats.yourEarnings.toLocaleString()} USDC</span>
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-400 mb-2">
                Amount to Stake (USDC)
              </label>
              <div className="relative">
                <input
                  type="number"
                  value={amount}
                  onChange={(e) => setAmount(e.target.value)}
                  className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  placeholder="Enter amount to stake"
                />
                <button
                  className="absolute right-2 top-1/2 -translate-y-1/2 px-4 py-1 text-sm bg-slate-700 rounded-md hover:bg-slate-600"
                >
                  MAX
                </button>
              </div>
            </div>

            <button
              onClick={handleStake}
              disabled={!amount || parseFloat(amount) <= 0}
              className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-slate-700 disabled:cursor-not-allowed py-3 rounded-lg font-medium transition-colors flex items-center justify-center gap-2"
            >
              Stake USDC
              <ArrowRight size={20} />
            </button>

            <div className="text-sm text-slate-400">
              <p className="mb-2">Note:</p>
              <ul className="list-disc list-inside space-y-1">
                <li>Earn fees from RWA lending activities</li>
                <li>APY varies based on platform usage</li>
                <li>No lock-up period - withdraw anytime</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}