import React, { useState } from 'react';
import { Building2, Link, FileCheck, Upload } from 'lucide-react';

interface PropertyDetails {
  address: string;
  value: string;
  dataSource: string;
  documents: FileList | null;
}

export default function TokenizationPanel() {
  const [propertyDetails, setPropertyDetails] = useState<PropertyDetails>({
    address: '',
    value: '',
    dataSource: 'official',
    documents: null,
  });

  const officialDataSources = [
    { id: 'official', name: 'National Property Registry' },
    { id: 'county', name: 'County Records' },
    { id: 'custom', name: 'Custom Data Source' },
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Handle tokenization logic here
    console.log('Tokenizing property:', propertyDetails);
  };

  return (
    <div className="max-w-2xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold mb-2">Tokenize Real Estate</h2>
          <p className="text-slate-400">Convert your property into tradeable tokens</p>
        </div>
        <Building2 size={32} className="text-blue-500" />
      </div>

      <form onSubmit={handleSubmit} className="space-y-6">
        <div className="bg-slate-900 rounded-lg p-6">
          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-slate-400 mb-2">
                Property Address
              </label>
              <input
                type="text"
                value={propertyDetails.address}
                onChange={(e) => setPropertyDetails(prev => ({
                  ...prev,
                  address: e.target.value
                }))}
                className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Enter complete property address"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-400 mb-2">
                Property Value (USDC)
              </label>
              <input
                type="number"
                value={propertyDetails.value}
                onChange={(e) => setPropertyDetails(prev => ({
                  ...prev,
                  value: e.target.value
                }))}
                className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Enter property value in USDC"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-400 mb-2">
                Data Source
              </label>
              <select
                value={propertyDetails.dataSource}
                onChange={(e) => setPropertyDetails(prev => ({
                  ...prev,
                  dataSource: e.target.value
                }))}
                className="w-full bg-slate-800 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                {officialDataSources.map(source => (
                  <option key={source.id} value={source.id}>
                    {source.name}
                  </option>
                ))}
              </select>
            </div>

            {propertyDetails.dataSource === 'custom' && (
              <div>
                <label className="block text-sm font-medium text-slate-400 mb-2">
                  Custom Data Source URL
                </label>
                <div className="flex gap-2">
                  <input
                    type="url"
                    className="flex-1 bg-slate-800 border border-slate-700 rounded-lg px-4 py-3 focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="https://"
                  />
                  <button
                    type="button"
                    className="px-4 py-2 bg-slate-700 rounded-lg hover:bg-slate-600 flex items-center gap-2"
                  >
                    <Link size={20} />
                    Verify
                  </button>
                </div>
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-slate-400 mb-2">
                Property Documents
              </label>
              <div className="border-2 border-dashed border-slate-700 rounded-lg p-6 text-center">
                <input
                  type="file"
                  multiple
                  onChange={(e) => setPropertyDetails(prev => ({
                    ...prev,
                    documents: e.target.files
                  }))}
                  className="hidden"
                  id="documents"
                />
                <label
                  htmlFor="documents"
                  className="cursor-pointer flex flex-col items-center gap-2"
                >
                  <Upload size={24} className="text-slate-400" />
                  <span className="text-slate-400">
                    Drop files here or click to upload
                  </span>
                </label>
              </div>
            </div>
          </div>
        </div>

        <button
          type="submit"
          className="w-full bg-blue-600 hover:bg-blue-700 py-3 rounded-lg font-medium transition-colors flex items-center justify-center gap-2"
        >
          <FileCheck size={20} />
          Tokenize Property
        </button>
      </form>
    </div>
  );
}