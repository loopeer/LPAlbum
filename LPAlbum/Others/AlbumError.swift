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
        case .noAlbumPermission: return String.local("没有相册访问权限")
        case .noCameraPermission: return String.local("没有摄像头访问权限")
        case .moreThanLargestChoiceCount: return String.local("达到了图片选择最大数量")
        case .savePhotoError: return String.local("保存图片失败")
        }
    }
}
