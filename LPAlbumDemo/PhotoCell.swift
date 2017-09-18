//
//  PhotoCell.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/13.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    let photoView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        photoView.frame = bounds
        photoView.clipsToBounds = true
        photoView.contentMode = .scaleAspectFit
        contentView.addSubview(photoView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
