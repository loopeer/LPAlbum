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
                let size = self.scrollView.frame.size
                let newSize = (image?.size ?? size).constrainedSize(toSize: size)
                self.photoView.bounds = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            }
        }
    }
    func resetZoomScale() { scrollView.setZoomScale(1.0, animated: false) }
    var singleTapAction: (() -> Void)?
    
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
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        photoView.contentMode = .scaleAspectFit
        photoView.frame = scrollView.bounds
        scrollView.addSubview(photoView)
        contentView.addSubview(scrollView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapClick))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapClick))
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        contentView.addGestureRecognizer(singleTap)
        contentView.addGestureRecognizer(doubleTap)
        
    }

    func singleTapClick() { singleTapAction?() }
    
    func doubleTapClick(ges: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            scrollView.contentInset = .zero
            scrollView.setZoomScale(1.0, animated: true)
        }else{
            let point = ges.location(in: photoView)
            let zoonScale = scrollView.maximumZoomScale
            let xSize = bounds.size.width / zoonScale
            let ySize = bounds.size.height / zoonScale
            scrollView.zoom(to: CGRect(x: point.x - xSize/2, y: point.y - ySize/2, width: xSize, height: ySize), animated: true)
        }
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
        let scrollViewW = scrollView.frame.width
        let scrollViewH = scrollView.frame.height
        let contentSizeW = scrollView.contentSize.width
        let contentSizeH = scrollView.contentSize.height
        // 缩小
        let offsetX = scrollViewW > contentSizeW ? (scrollViewW - contentSizeW) * 0.5 : 0
        let offsetY = scrollViewH > contentSizeH ? (scrollViewH - contentSizeH) * 0.5 : 0
        photoView.center = CGPoint(x: contentSizeW * 0.5 + offsetX, y: contentSizeH * 0.5 + offsetY)
    }

}


