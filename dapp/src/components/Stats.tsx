import React from 'react';
import { DollarSign, Users, TrendingUp } from 'lucide-react';

export default function Stats() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div className="bg-gradient-to-r from-blue-600 to-blue-700 rounded-xl p-6">
        <div className="flex items-center gap-4">
          <div className="p-3 bg-blue-500 bg-opacity-30 rounded-lg">
            <DollarSign size={24} />
          </div>
          <div>
            <p className="text-sm text-blue-200">Total Value Locked</p>
            <p className="text-2xl font-bold">$24.8M</p>
          </div>
        </div>
      </div>
      
      <div className="bg-gradient-to-r from-indigo-600 to-indigo-700 rounded-xl p-6">
        <div className="flex items-center gap-4">
          <div className="p-3 bg-indigo-500 bg-opacity-30 rounded-lg">
            <Users size={24} />
          </div>
          <div>
            <p className="text-sm text-indigo-200">Active Providers</p>
            <p className="text-2xl font-bold">1,240</p>
          </div>
        </div>
      </div>
      
      <div className="bg-gradient-to-r from-purple-600 to-purple-700 rounded-xl p-6">
        <div className="flex items-center gap-4">
          <div className="p-3 bg-purple-500 bg-opacity-30 rounded-lg">
            <TrendingUp size={24} />
          </div>
          <div>
            <p className="text-sm text-purple-200">Average APY</p>
            <p className="text-2xl font-bold">10.5%</p>
          </div>
        </div>
      </div>
    </div>
  );
}