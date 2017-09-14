//
//  PhotoPreviewCell.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/14.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import UIKit

class PhotoPreviewCell: UICollectionViewCell {
    
    var assetModel: AssetModel! {
        didSet{
            
            AlbumManager.getPhoto(asset: assetModel.asset, targetSize: bounds.size) { (image, _) in
                self.photoView.image = image
            }
        }
    }
    func resetZoomScale() { scrollView.setZoomScale(1.0, animated: false) }
    
    fileprivate let photoView = UIImageView()
    fileprivate let scrollView = UIScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView.frame = bounds.insetBy(dx: 10, dy: 0)
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.bouncesZoom = true
        scrollView.delaysContentTouches = true
        scrollView.canCancelContentTouches = true
        scrollView.delegate = self
        
        photoView.contentMode = .scaleAspectFit
        photoView.frame = scrollView.bounds
        scrollView.addSubview(photoView)
        contentView.addSubview(scrollView)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoPreviewCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photoView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.contentInset = .zero
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        let scrollViewW = scrollView.frame.width
//        let scrollViewH = scrollView.frame.height
//        let contentSizeW = scrollView.contentSize.width
//        let contentSizeH = scrollView.contentSize.height
//        
//        let offsetX = scrollViewW > contentSizeW ? scrollViewW - contentSizeW * 0.5 : 0
//        let offsetY = scrollViewH > contentSizeH ? scrollViewH - contentSizeH * 0.5 : 0
//        photoView.center = CGPoint(x: contentSizeW * 0.5 + offsetX, y: contentSizeH * 0.5 + offsetY)
    }

}


