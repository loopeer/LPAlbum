//
//  Models.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/11.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import Foundation
import Photos

struct AssetModel {
    var asset: PHAsset
    var isSelect: Bool
}

struct AlbumModel {
    var name: String
    var cover: PHAsset
    var count: Int
    var assetModels: [AssetModel]
    var selectCount: Int { return assetModels.filter{ $0.isSelect == true }.count }
}

extension PHAsset {
    var toAssetModel: AssetModel { return AssetModel(asset: self, isSelect: false) }
}

extension PHFetchResult where ObjectType == PHAsset {
    var toAssetModels: [AssetModel] {
        var result = [AssetModel]()
        enumerateObjects({ (asset, i, stop) in
            result.append(asset.toAssetModel)
        })
        return result
    }
}

extension Array where Iterator.Element == AlbumModel {
    
    func change(assetModel: AssetModel) -> [AlbumModel] {
        
         return map{
            var albumModel = $0
            albumModel.assetModels = $0.assetModels.map{
                return $0.asset.localIdentifier == assetModel.asset.localIdentifier ? assetModel : $0
            }
            return albumModel
        }
    }
    
    var allSelectedAssetModels: [AssetModel] {
        return self[0].assetModels.filter{ $0.isSelect == true }
    }
    var allSelectedAsset: [PHAsset] {
        return allSelectedAssetModels.map{ $0.asset }
    }
}






