//
//  PhotoPreviewController.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/26.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import UIKit

class PhotoPreviewController: UIViewController {

    var assetModel: AssetModel!

    private let preview = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preview.layer.cornerRadius = 8
        preview.contentMode = .scaleAspectFill
        view.addSubview(preview)
        
        let scale = assetModel.asset.pixelHeight.cgFloat / assetModel.asset.pixelWidth.cgFloat
        preferredContentSize = CGSize(width: view.bounds.width, height: view.bounds.width * scale)
        preview.frame = CGRect(origin: .zero, size: preferredContentSize)
        
        AlbumManager.getPhoto(asset: assetModel.asset, targetSize: preferredContentSize, adaptScale: true, option: nil, contentMode: .aspectFill) { (image, _) in
            self.preview.image = image
        }
    }
    deinit {
        print("\(self) deinit")
    }
}
