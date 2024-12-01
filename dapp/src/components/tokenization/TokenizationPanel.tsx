import React, { useState } from 'react';
import { Building2 } from 'lucide-react';

interface TokenizationForm {
  name: string;
  category: string;
  dataSource: string;
}

export default function TokenizationPanel() {
  const [formData, setFormData] = useState<TokenizationForm>({
    name: '',
    category: 'house',
    dataSource: 'us_registry'
  });

  const categories = [
    { id: 'house', name: 'House' },
    { id: 'apartment', name: 'Apartment' },
    { id: 'commercial', name: 'Commercial Property' },
    { id: 'land', name: 'Land' }
  ];

  const dataSources = [
    { id: 'us_registry', name: 'Authority Assets Registry (US)' },
    { id: 'cn_registry', name: 'Authority Assets Registry (CN)' },
    { id: 'uk_registry', name: 'Authority Assets Registry (UK)' },
    { id: 'jp_registry', name: 'Authority Assets Registry (JP)' },
    { id: 'custom', name: 'Custom Registry' }
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Tokenization form submitted:', formData);
  };

  return (
    <div className="max-w-2xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold mb-2">Tokenize Real World Asset</h2>
          <p className="text-slate-400">Convert your property into tradeable tokens</p>
        </div>
        <Building2 size={32} className="text-blue-500" />
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-slate-400 mb-2">
              Asset Name
            </label>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Enter asset name"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-400 mb-2">
              Asset Category
            </label>
            <select
              value={formData.category}
              onChange={(e) => setFormData({ ...formData, category: e.target.value })}
              className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {categories.map(category => (
                <option key={category.id} value={category.id}>
                  {category.name}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-slate-400 mb-2">
              Data Source
            </label>
            <select
              value={formData.dataSource}
              onChange={(e) => setFormData({ ...formData, dataSource: e.target.value })}
              className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {dataSources.map(source => (
                <option key={source.id} value={source.id}>
                  {source.name}
                </option>
              ))}
            </select>
          </div>

          {formData.dataSource === 'custom' && (
            <div>
              <label className="block text-sm font-medium text-slate-400 mb-2">
                Custom Registry URL
              </label>
              <input
                type="url"
                className="w-full bg-slate-900 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="https://"
              />
            </div>
          )}
        </div>

        <button
          type="submit"
          className="w-full bg-blue-600 hover:bg-blue-700 py-3 rounded-lg font-medium transition-colors"
        >
          Tokenize Asset
        </button>
      </form>
    </div>
  );
}