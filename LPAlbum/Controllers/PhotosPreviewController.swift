//
//  AlbumDetailController.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/12.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import UIKit

class PhotosPreviewController: UIViewController {

    var assetModels: [AssetModel]!
    var currentIndex: Int!
    
    var chooseAction: ((Int, UIButton, PhotosPreviewController) -> Void)?
    
    fileprivate var collectionView: UICollectionView!
    fileprivate let itemPadding: CGFloat = 20.0
    fileprivate let chooseButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    deinit {
        print("\(self) deinit")
    }
}

extension PhotosPreviewController {
    
    func setupUI(){
        // 将collectionView多余的部分切到
        view.clipsToBounds = true
    
        chooseButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        chooseButton.setBackgroundImage(LPAlbum.Style.selectedBox, for: .selected)
        chooseButton.setBackgroundImage(LPAlbum.Style.normalBox, for: .normal)
        chooseButton.isSelected = assetModels[currentIndex].isSelect
        chooseButton.addTarget(self, action: #selector(chooseClick), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: chooseButton)
        
        let layout = UICollectionViewFlowLayout()
        let itemSize = CGSize(width: view.bounds.width + 20, height: view.bounds.height - 64)
        layout.itemSize = itemSize
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: CGRect(x: -10, y: 0, width: itemSize.width, height: itemSize.height),
                                          collectionViewLayout: layout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.register(PhotoPreviewCell.self, forCellWithReuseIdentifier: PhotoPreviewCell.description())
        collectionView.performBatchUpdates(nil){ _ in
            self.collectionView.setContentOffset(CGPoint(x: itemSize.width * self.currentIndex.cgFloat, y: 0), animated: false)
        }
    }
    func chooseClick() {
        chooseAction?(currentIndex, chooseButton, self)
    }
}

extension PhotosPreviewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPreviewCell.description(), for: indexPath) as! PhotoPreviewCell
        cell.assetModel = assetModels[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? PhotoPreviewCell)?.resetZoomScale()
    }
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = (scrollView.contentOffset.x / scrollView.bounds.width).roundInt
        chooseButton.isSelected = assetModels[currentIndex].isSelect
    }
}









