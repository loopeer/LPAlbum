//
//  AlbumManager.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/11.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import Foundation
import Photos

public class AlbumManager {
    
    static let imageManager = PHCachingImageManager()
    
    public class func getAlbums() -> [AlbumModel] {
        // 获取智能相册
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        // 获取用户创建的相册
        let userAlbums = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        // 遍历相册
        let smartModels = enumerateAlbum(album: smartAlbums as! PHFetchResult<PHCollection>)
        let userModels = enumerateAlbum(album: userAlbums)
        // 数量排序
        return (smartModels + userModels).sorted{ $0.count > $1.count }
    }
    
    // 根据Asset获取photo
    @discardableResult
    public class func getPhoto(asset: PHAsset, targetSize: CGSize, option: PHImageRequestOptions? = nil, resultHandler: @escaping ((UIImage?, [AnyHashable: Any]?) -> Void)) -> PHImageRequestID {
        
        let defalutOption = PHImageRequestOptions()
        defalutOption.resizeMode = .fast
        defalutOption.deliveryMode = .opportunistic
        
        let size = CGSize(width: targetSize.width * UIScreen.main.scale,
                         height: targetSize.height * UIScreen.main.scale)
        return AlbumManager.imageManager.requestImage(for: asset,
                                                      targetSize: size,
                                                      contentMode: .aspectFill,
                                                      options: option ?? defalutOption,
                                                      resultHandler: resultHandler)
    }

    private class func enumerateAlbum(album: PHFetchResult<PHCollection>) -> [AlbumModel] {
        
        var result = [AlbumModel]()
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType in %@", [PHAssetMediaType.image.rawValue])
        
        album.enumerateObjects(options: .concurrent) { (collection, index, stop) in
            let assets = PHAsset.fetchAssets(in: collection as! PHAssetCollection, options: options)
            if assets.count != 0 && (collection.localizedTitle?.isAvailableAlbum ?? false){
                let model = AlbumModel(name: collection.localizedTitle!,
                                       cover: assets[0],
                                       count: assets.count,
                                       assetModels: assets.toAssetModels)
                result.append(model)
            }
        }
        return result
    }

}
















