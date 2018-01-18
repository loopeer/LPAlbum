//
//  AlbumCollectionCell.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/11.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import UIKit

class AlbumCollectionCell: UICollectionViewCell {
    
    let photoView = UIImageView()
    let iconButton = UIButton()
    
    var assetIdentifier: String!
    
    var iconClickAction: ((Bool) -> Void)?
    
    func set(_ assetModel: AssetModel){
        self.assetIdentifier = assetModel.asset.localIdentifier
        AlbumManager.getPhoto(asset: assetModel.asset, targetSize: bounds.size) {[weak self] (image, _) in
            guard let `self` = self else { return }
            guard self.assetIdentifier == assetModel.asset.localIdentifier else { return }
            self.photoView.image = image
        }
        iconButton.isSelected = assetModel.isSelect
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        photoView.frame = CGRect(origin: .zero, size: frame.size)
        
        let padding = 5.cgFloat
        let iconWH = 20.adapt
        
        iconButton.frame = CGRect(x: frame.width - padding - iconWH, y: padding, width: iconWH, height: iconWH)
        iconButton.setBackgroundImage(LPAlbum.Style.normalBox , for: .normal)
        iconButton.setBackgroundImage(LPAlbum.Style.selectedBox, for: .selected)
        iconButton.lp_hitEdgeInsets = LPAlbum.Style.boxEdgeInsets
        
        addSubview(photoView)
        addSubview(iconButton)
        
        iconButton.addTarget(self, action: #selector(iconTap), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoView.image = nil
    }
    
    @objc func iconTap() { iconClickAction?(iconButton.isSelected) }
}

