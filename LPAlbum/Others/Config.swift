//
//  Config.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/13.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import Foundation

public extension LPAlbum {
    public struct Config {

        public var maxSelectCount: Int = 6
        public var columnCount: Int = 4
        public var photoPadding: CGFloat = 2.0
        public var hasCamera: Bool = true
        public var isSingleSelect: Bool = false
        
        public static var barTitleColor: UIColor = UIColor.white
        public static var barTintColor: UIColor = UIColor.darkGray
        public static var tintColor: UIColor = UIColor.white
        public static var statusBarStyle: UIStatusBarStyle = .lightContent
    
        public static var arrowImage: UIImage = Bundle.imageFromBundle("meun_down")!
        public static var normalBox: UIImage = Bundle.imageFromBundle("circle_normal")!
        public static var selectedBox: UIImage = Bundle.imageFromBundle("circle_selected")!
    }
}


