//
//  Models.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/11.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import Foundation
import Photos

public struct AssetModel {
    /// 照片
    var asset: PHAsset
    /// 是否被选中
    var isSelect: Bool
}

public struct AlbumModel {
    /// 相册名字
    var name: String
    /// 相册封面
    var cover: PHAsset
    /// 照片数量
    var count: Int
    /// 照片Model
    var assetModels: [AssetModel]
    /// 该相册中被选中的数量
    var selectCount: Int { return assetModels.filter{ $0.isSelect == true }.count }
}

extension PHAsset {
    
    /// `PHAsset`转变成`AssetModel`
    var toAssetModel: AssetModel { return AssetModel(asset: self, isSelect: false) }
}

extension PHFetchResult where ObjectType == PHAsset {
    
    /// `PHFetchResult<PHAsset>`转变成`[AssetModel]`
    var toAssetModels: [AssetModel] {
        var result = [AssetModel]()
        enumerateObjects({ (asset, i, stop) in
            result.append(asset.toAssetModel)
        })
        return result
    }
}

extension Array where Iterator.Element == AlbumModel {
    
    /// 改变AlbumModel数组中的所有assetModel
    ///
    /// - Parameter assetModel: 传入的assetModel
    /// - Returns: 改变后的AlbumModel数组
    func change(assetModel: AssetModel) -> [AlbumModel] {
        
         return map{
            var albumModel = $0
            albumModel.assetModels = $0.assetModels.map{
                return $0.asset.localIdentifier == assetModel.asset.localIdentifier ? assetModel : $0
            }
            return albumModel
        }
    }
    
    /// 得到相册中所有的不重复的AssetModel
    var allSelectedAssetModels: [AssetModel] {
        return self[0].assetModels.filter{ $0.isSelect == true }
    }
    /// 得到所有的选中的`PHAsset`
    var allSelectedAsset: [PHAsset] {
        return allSelectedAssetModels.map{ $0.asset }
    }
}






