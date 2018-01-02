# LPAlbum

<img src="./Images/logo.png" alt="LPAlbum" title="LPAlbum"/>

![Xcode 8.3+](https://img.shields.io/badge/Xcode-8.3%2B-blue.svg)
![iOS 8.0+](https://img.shields.io/badge/iOS-8.0%2B-blue.svg)
![Swift 3.1+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)
<!--[![Version](https://img.shields.io/cocoapods/v/AttributedStringWrapper.svg?style=flat)](https://cocoapods.org/pods/LPAlbum)-->
<!--[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/loopeer/LPAlbum)-->
<!--<a href="http://cocoapods.org/pods/AttributedStringWrapper"><img src="https://img.shields.io/cocoapods/at/AttributedStringWrapper.svg?label=Apps%20Using%20AttributedStringWrapper&colorB=28B9FE"></a>-->
<!--<a href="http://cocoapods.org/pods/AttributedStringWrapper"><img src="https://img.shields.io/cocoapods/dt/AttributedStringWrapper.svg?label=Total%20Downloads&colorB=28B9FE"></a>-->


**LPAlbum** is a simple photo album 


## Overview

**LPAlbum** is a album including the function of multiple images, photo browsing, camera taking pictures. It is very easy to use

<table>
 <tr>
  <td>
    <img src="Images/demo1.png" width="300"/>
  </td>
  <td>
    <img src="Images/demo2.png" width="300"/>
  </td>
 </tr>
</table>

## How to use

1. Config


```Swift

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
        /// 选择框box的可点击区域向外的扩展size
        public static var boxEdgeInsets = UIEdgeInsets(top: -5, left: -5, bottom: -5, right: -5)
    }
}

```


2. Error:


```Swift

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

```


3. Use: 


```Swift

// you can setup style yourself
LPAlbum.Style.barTintColor = .gray
LPAlbum.Style.tintColor = .white

// show
LPAlbum.show(at: self)  {
    $0.columnCount = 4
    $0.hasCamera = true
    $0.maxSelectCount = 9 - self.photos.count
}.targeSize({ (size) -> CGSize in
    return CGSize(width: 240, height: 240)
}).error {(vc, error) in
    vc.show(message: error.localizedDescription)
}.complete { [weak self](images) in
    self?.photos.append(contentsOf: images)
    self?.collectionView.reloadData()
    _ = images.map{ print($0.size) }
}

```


## Features

- [ ] Support for iCloud 
- [ ] Support for cutting
- [ ] Support for selecting a single image
- [ ] Support for choosing the original image
- [ ] Add preview of the selected photos


## Installation


### 1. CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects.

Specify LPAlbum into your project's Podfile:


```ruby
# source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
use_frameworks!

target '<Your App Target>' do
  pod 'LPAlbum'
end
```


Then run the following command:

```sh
$ pod install
```

















