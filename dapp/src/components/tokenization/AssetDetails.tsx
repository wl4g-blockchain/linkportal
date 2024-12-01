import React from 'react';
import { X, Building2, MapPin, Ruler, BedDouble, Bath, Calendar, Tag } from 'lucide-react';

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

interface AssetDetailsProps {
  asset: TokenizedAsset;
  onClose: () => void;
}

export default function AssetDetails({ asset, onClose }: AssetDetailsProps) {
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-slate-800 rounded-xl w-full max-w-4xl max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-slate-800 p-6 border-b border-slate-700 flex items-center justify-between">
          <h2 className="text-2xl font-bold flex items-center gap-3">
            <Building2 size={24} className="text-blue-500" />
            Asset Details
          </h2>
          <button
            onClick={onClose}
            className="p-2 hover:bg-slate-700 rounded-lg transition-colors"
          >
            <X size={20} />
          </button>
        </div>
        
        <div className="p-6">
          <img
            src={asset.imageUrl}
            alt={asset.name}
            className="w-full h-[400px] object-cover rounded-lg mb-6"
          />
          
          <div className="space-y-6">
            <div>
              <h3 className="text-xl font-semibold mb-2">{asset.name}</h3>
              <p className="text-slate-400">{asset.description}</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-4">
                <div className="flex items-center gap-2">
                  <MapPin size={20} className="text-blue-500" />
                  <span>{asset.location}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Ruler size={20} className="text-blue-500" />
                  <span>{asset.size}</span>
                </div>
                <div className="flex items-center gap-2">
                  <BedDouble size={20} className="text-blue-500" />
                  <span>{asset.bedrooms} Bedrooms</span>
                </div>
                <div className="flex items-center gap-2">
                  <Bath size={20} className="text-blue-500" />
                  <span>{asset.bathrooms} Bathrooms</span>
                </div>
              </div>

              <div className="space-y-4">
                <div className="flex items-center gap-2">
                  <Calendar size={20} className="text-blue-500" />
                  <span>Built in {asset.yearBuilt}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Tag size={20} className="text-blue-500" />
                  <span>{asset.propertyType}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Calendar size={20} className="text-blue-500" />
                  <span>Created: {asset.createDate}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Calendar size={20} className="text-blue-500" />
                  <span>Updated: {asset.updateDate}</span>
                </div>
              </div>
            </div>

            <div>
              <h4 className="font-semibold mb-3">Amenities</h4>
              <div className="flex flex-wrap gap-2">
                {asset.amenities.map((amenity, index) => (
                  <span
                    key={index}
                    className="px-3 py-1 bg-slate-700 rounded-full text-sm"
                  >
                    {amenity}
                  </span>
                ))}
              </div>
            </div>

            <div className="bg-slate-900 rounded-lg p-6">
              <div className="flex justify-between items-center">
                <span className="text-xl">Current Price</span>
                <span className="text-2xl font-bold text-blue-500">
                  ${asset.currentPrice.toLocaleString()} USDC
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}