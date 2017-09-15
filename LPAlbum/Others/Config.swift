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
        /// 最大选择数量
        public var maxSelectCount: Int = 6
        /// 每列照片数量
        public var columnCount: Int = 4
        /// 照片间距
        public var photoPadding: CGFloat = 2.0
        /// 是否有相机
        public var hasCamera: Bool = true
    }
    
    public struct Style {
        /// `NavigationBar`标题颜色
        public static var barTitleColor: UIColor = UIColor.white
        /// `NavigationBar`背景颜色
        public static var barTintColor: UIColor = UIColor.darkGray
        /// `NavigationBar`item文本颜色
        public static var tintColor: UIColor = UIColor.white
        /// 状态栏样式
        public static var statusBarStyle: UIStatusBarStyle = .lightContent
        /// 下拉箭头图片
        public static var arrowImage: UIImage = Bundle.imageFromBundle("meun_down")!
        /// 正常的选择框图片
        public static var normalBox: UIImage = Bundle.imageFromBundle("circle_normal")!
        /// 选中的选择框图片
        public static var selectedBox: UIImage = Bundle.imageFromBundle("circle_selected")!
    }
    
}


