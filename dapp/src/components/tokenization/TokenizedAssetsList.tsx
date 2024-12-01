import React, { useState } from 'react';
import { ExternalLink, Building2, LayoutGrid, List as ListIcon, X } from 'lucide-react';
import AssetDetails from './AssetDetails';

interface TokenizedAsset {
  id: string;
  name: string;
  category: string;
  createDate: string;
  updateDate: string;
  currentPrice: number;
  imageUrl: string;
  description: string;
  location: string;
  size: string;
  bedrooms: number;
  bathrooms: number;
  yearBuilt: number;
  propertyType: string;
  amenities: string[];
}

export default function TokenizedAssetsList() {
  const [viewMode, setViewMode] = useState<'grid' | 'list'>('grid');
  const [selectedAsset, setSelectedAsset] = useState<TokenizedAsset | null>(null);

  // Mock data - replace with actual data from smart contract
  const assets: TokenizedAsset[] = [
    {
      id: '1',
      name: 'Luxury Villa #123',
      category: 'House',
      createDate: '2024-03-15',
      updateDate: '2024-03-15',
      currentPrice: 250000,
      imageUrl: 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6',
      description: 'Luxurious villa with modern amenities and stunning views',
      location: 'Miami, Florida',
      size: '4,500 sq ft',
      bedrooms: 4,
      bathrooms: 3.5,
      yearBuilt: 2020,
      propertyType: 'Single Family',
      amenities: ['Pool', 'Garden', 'Smart Home', 'Security System']
    },
    {
      id: '2',
      name: 'Commercial Space #456',
      category: 'Commercial',
      createDate: '2024-03-14',
      updateDate: '2024-03-15',
      currentPrice: 180000,
      imageUrl: 'https://images.unsplash.com/photo-1570129477492-45c003edd2be',
      description: 'Prime commercial space in downtown business district',
      location: 'New York, NY',
      size: '2,800 sq ft',
      bedrooms: 0,
      bathrooms: 2,
      yearBuilt: 2018,
      propertyType: 'Commercial',
      amenities: ['Parking', 'Security', 'High-speed Internet', 'Conference Room']
    }
  ];

  const handleAssetClick = (asset: TokenizedAsset) => {
    setSelectedAsset(asset);
  };

  const GridView = () => (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {assets.map(asset => (
        <div key={asset.id} className="bg-slate-800 rounded-xl overflow-hidden border border-slate-700">
          <img
            src={asset.imageUrl}
            alt={asset.name}
            className="w-full h-48 object-cover cursor-pointer"
            onClick={() => handleAssetClick(asset)}
          />
          <div className="p-6">
            <div className="flex items-start justify-between mb-4">
              <div>
                <h3 className="font-semibold mb-1 flex items-center gap-2 cursor-pointer" onClick={() => handleAssetClick(asset)}>
                  <Building2 size={20} className="text-blue-500" />
                  {asset.name}
                </h3>
                <p className="text-sm text-slate-400">{asset.category}</p>
              </div>
              <button 
                className="text-blue-500 hover:text-blue-400"
                onClick={() => handleAssetClick(asset)}
              >
                <ExternalLink size={20} />
              </button>
            </div>
            <div className="space-y-2">
              <div className="flex justify-between">
                <span className="text-slate-400">Current Price</span>
                <span className="font-medium">${asset.currentPrice.toLocaleString()} USDC</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-400">Created</span>
                <span className="text-sm">{asset.createDate}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-400">Updated</span>
                <span className="text-sm">{asset.updateDate}</span>
              </div>
            </div>
          </div>
        </div>
      ))}
    </div>
  );

  const ListView = () => (
    <div className="overflow-x-auto">
      <table className="w-full">
        <thead>
          <tr className="text-left border-b border-slate-700">
            <th className="pb-4 font-medium text-slate-400">ID</th>
            <th className="pb-4 font-medium text-slate-400">Name</th>
            <th className="pb-4 font-medium text-slate-400">Category</th>
            <th className="pb-4 font-medium text-slate-400">Created</th>
            <th className="pb-4 font-medium text-slate-400">Updated</th>
            <th className="pb-4 font-medium text-slate-400">Current Price (USDC)</th>
            <th className="pb-4 font-medium text-slate-400">Actions</th>
          </tr>
        </thead>
        <tbody>
          {assets.map(asset => (
            <tr key={asset.id} className="border-b border-slate-700">
              <td className="py-4">{asset.id}</td>
              <td className="py-4 flex items-center gap-2 cursor-pointer" onClick={() => handleAssetClick(asset)}>
                <Building2 size={20} className="text-blue-500" />
                {asset.name}
              </td>
              <td className="py-4">{asset.category}</td>
              <td className="py-4">{asset.createDate}</td>
              <td className="py-4">{asset.updateDate}</td>
              <td className="py-4">${asset.currentPrice.toLocaleString()}</td>
              <td className="py-4">
                <button 
                  className="text-blue-500 hover:text-blue-400"
                  onClick={() => handleAssetClick(asset)}
                >
                  <ExternalLink size={20} />
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );

  return (
    <div className="max-w-6xl mx-auto">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold mb-2">Tokenized Assets</h2>
          <p className="text-slate-400">Manage your tokenized real world assets</p>
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => setViewMode('grid')}
            className={`p-2 rounded-lg transition-colors ${
              viewMode === 'grid'
                ? 'bg-blue-600 text-white'
                : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
            }`}
            title="Grid View"
          >
            <LayoutGrid size={20} />
          </button>
          <button
            onClick={() => setViewMode('list')}
            className={`p-2 rounded-lg transition-colors ${
              viewMode === 'list'
                ? 'bg-blue-600 text-white'
                : 'bg-slate-700 text-slate-300 hover:bg-slate-600'
            }`}
            title="List View"
          >
            <ListIcon size={20} />
          </button>
        </div>
      </div>

      {viewMode === 'grid' ? <GridView /> : <ListView />}

      {selectedAsset && (
        <AssetDetails
          asset={selectedAsset}
          onClose={() => setSelectedAsset(null)}
        />
      )}
    </div>
  );
}