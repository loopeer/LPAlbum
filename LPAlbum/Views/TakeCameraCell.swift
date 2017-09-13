//
//  TakeCameraCell.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/12.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import UIKit

class TakeCameraCell: UICollectionViewCell {
    
    private let iconView = UIImageView(image: Bundle.imageFromBundle("image_camera"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .black
        contentView.addSubview(iconView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconView.bounds = bounds.applying(CGAffineTransform(scaleX: 0.5, y: 0.5))
        iconView.center = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
