//
//  LPAlbumError.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/11.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import Foundation

public enum AlbumError: Error {
    case noAlbumPermission
    case noCameraPermission
    case moreThanLargestChoiceCount
    case savePhotoError
    
    public var localizedDescription: String {
        switch self {
        case .noAlbumPermission: return "没有相册访问权限"
        case .noCameraPermission: return "没有相机访问权限"
        case .moreThanLargestChoiceCount: return "超出了可选择图片数量的上限"
        case .savePhotoError: return "保存图片失败"
        }
    }
}
