//
//  SessionTitleView.swift
//  MaiDou
//
//  Created by 郜宇 on 2017/8/22.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import UIKit

class TitleView: UIButton {
    
    override var isSelected: Bool {
        didSet{
            UIView.animate(withDuration: 0.25) {
                self.imageView?.transform = self.isSelected ? CGAffineTransform(rotationAngle: CGFloat.pi) : .identity
            }
        }
    }
    
    var title: String! {
        didSet{
            setTitle(title, for: .normal)
            sizeToFit()
        }
    }
    
    var clickAction: ((TitleView) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(LPAlbum.Style.arrowImage, for: .normal)
        setTitleColor(LPAlbum.Style.barTitleColor, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 17)
        bounds = CGRect(origin: .zero, size: CGSize(width: 200, height: 40))
        addTarget(self, action: #selector(click), for: .touchUpInside)
    }
    
    func click() { clickAction?(self) }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageEdgeInsets = UIEdgeInsets(top: 0, left: (titleLabel?.frame.width ?? 0) + 5, bottom: 0, right: -(titleLabel?.frame.width ?? 0))
        titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageView?.frame.width ?? 0), bottom: 0, right: (imageView?.frame.width ?? 0) + 5)
        
        contentHorizontalAlignment = .center
    }
}
