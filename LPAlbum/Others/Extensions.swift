//
//  Extensions.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/12.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import Foundation

extension CGFloat {
    static var screenWidth = UIScreen.main.bounds.width
    static var screenHeight = UIScreen.main.bounds.height
    
    var roundInt: Int { return Int(self.rounded()) }
}

extension Int {
    var cgFloat: CGFloat { return CGFloat(self) }
    var half: CGFloat { return self.cgFloat / 2 }
    var adapt: CGFloat { return self.cgFloat * CGFloat.screenWidth / 375.0 }
}

extension Bundle {
    // 资源的bundle
    static var albumBundle: Bundle {
        let bundle = Bundle(for: LPAlbum.self)
        return Bundle(path: bundle.path(forResource: "LPAlbum", ofType: "bundle")!)!
    }
    
    static func imageFromBundle(_ imageName: String) -> UIImage? {
        var imageName = imageName
        if UIScreen.main.scale == 2 {
            imageName = imageName + "@2x"
        }else if UIScreen.main.scale == 3 {
            imageName = imageName + "@3x"
        }
        guard let bundle = Bundle(path: albumBundle.bundlePath + "/Images"),
            let path = bundle.path(forResource: imageName, ofType: "png") else { return nil }
        return UIImage(contentsOfFile: path)
    }
    
    static func localizedString(key: String) -> String {
        guard let code = Locale.current.languageCode else { return key }
        var language = "zh"
        if code == "en" { language = "en" }
        guard let path = albumBundle.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else { return key }
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}



extension UIImage {
    
    func scaleImage(to size: CGSize,
                    contentMode: UIViewContentMode,
                    corner: CGFloat = 0,
                    backGroundColor: UIColor = UIColor.clear) -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        var newSize = self.size
        var newImageFrame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        switch contentMode {
        case .scaleAspectFit:
            newSize = self.size.constrainedSize(toSize: size)
            if newSize.width == size.width {
                newImageFrame = CGRect(x: 0,
                                       y: (size.height - newSize.height)/2,
                                       width: newSize.width,
                                       height: newSize.height)
            }
            if newSize.height == size.height {
                newImageFrame = CGRect(x: 0,
                                       y: (size.width - newSize.width)/2,
                                       width: newSize.width,
                                       height: newSize.height)
            }
        case .scaleAspectFill:
            newSize = self.size.fillingSize(toSize: size)
            if newSize.width > size.width {
                newImageFrame = CGRect(x: -(newSize.width - size.width)/2,
                                       y: 0,
                                       width: newSize.width,
                                       height: newSize.height)
            }
            if newSize.height > size.height {
                newImageFrame = CGRect(x: 0,
                                       y: -(newSize.height - size.height)/2,
                                       width: newSize.width,
                                       height: newSize.height)
            }
        default: break
        }
        backGroundColor.set()
        UIRectFill(newImageFrame)
        UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: corner).addClip()
        self.draw(in: newImageFrame)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

extension CGSize {
    func fillingSize(toSize: CGSize) -> CGSize {
        let aspectWidth = round(aspectRatio * toSize.height)
        let aspectHeight = round(toSize.width / aspectRatio)
        return aspectWidth < toSize.width ?
            CGSize(width: toSize.width, height: aspectHeight) :
            CGSize(width: aspectWidth, height: toSize.height)
    }
    func constrainedSize(toSize: CGSize) -> CGSize {
        let aspectWidth = round(aspectRatio * toSize.height)
        let aspectHeight = round(toSize.width / aspectRatio)
        return aspectWidth > toSize.width ?
            CGSize(width: toSize.width, height: aspectHeight) :
            CGSize(width: aspectWidth, height: toSize.height)
    }
    private var aspectRatio: CGFloat {
        return height == 0.0 ? 1.0 : width / height
    }
}


var keyHitThstEdgeInsets = "HitTestEdgeInsets"
extension UIControl {
    
    public var lp_hitEdgeInsets: UIEdgeInsets? {
        get {
            let value = objc_getAssociatedObject(self, &keyHitThstEdgeInsets) as? NSValue
            return value.map { $0.uiEdgeInsetsValue }
        }
        set {
            guard newValue != nil else { return }
            objc_setAssociatedObject(self, &keyHitThstEdgeInsets, NSValue(uiEdgeInsets: newValue!), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.lp_hitEdgeInsets == nil || !self.isEnabled || self.isHidden {
            return super.point(inside: point, with: event)
        }
        
        let relativeFrame = self.bounds
        let hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.lp_hitEdgeInsets!)
        return hitFrame.contains(point)
    }
}

extension String {
    
    var isAvailableAlbum: Bool {
        return !(isEmpty || contains("Hidden") || contains("已隐藏") || contains("Deleted") || contains("最近删除"))
    }
    
    static func local(_ key: String) -> String {
        return Bundle.localizedString(key: key)
    }
}







