//
//  AuthorizationTool.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/8.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import Foundation
import Photos

class AuthorizationTool {
    /// 相机权限
    static func cameraRequestAuthorization(queue: DispatchQueue = .main, complete: @escaping (_ status: AVAuthorizationStatus) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:   complete(.authorized)
        case .denied:       complete(.denied)
        case .restricted:   complete(.restricted)
        case .notDetermined:
            queue.suspend()
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                DispatchQueue.main.async { complete( granted ? .authorized : .denied ) }
                queue.resume()
            })
        }
    }
    
    /// 相册权限
    static func albumRRequestAuthorization(queue: DispatchQueue = .main, complete: @escaping (_ status: PHAuthorizationStatus) -> Void){
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized: complete(.authorized)
        case .denied: complete(.denied)
        case .restricted: complete(.restricted)
        case .notDetermined:
            queue.suspend()
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async { complete(status) }
                queue.resume()
            })
        }
    }
}

