//
//  AlbumDetailController.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/12.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import UIKit

class PhotosBrowerController: UIViewController {

    var assetModels: [AssetModel]!
    var currentIndex: Int!
    
    var chooseAction: ((Int, UIButton, PhotosBrowerController) -> Void)?
    
    fileprivate var collectionView: UICollectionView!
    fileprivate let itemPadding: CGFloat = 20.0
    fileprivate let chooseButton = UIButton()
    fileprivate var itemSize: CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        refreshNavigation()
//        addCache()
    }
    
    deinit {
        print("\(self) deinit")
//        removeCache()
    }
}

extension PhotosBrowerController {
    
    func setupUI(){
        // 将collectionView多余的部分切到
        view.clipsToBounds = true
        automaticallyAdjustsScrollViewInsets = false
        chooseButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        chooseButton.setBackgroundImage(LPAlbum.Style.selectedBox, for: .selected)
        chooseButton.setBackgroundImage(LPAlbum.Style.normalBox, for: .normal)
        chooseButton.addTarget(self, action: #selector(chooseClick), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: chooseButton)
        
        let layout = UICollectionViewFlowLayout()
        itemSize = CGSize(width: view.bounds.width + 20, height: view.bounds.height)
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
            self.collectionView.setContentOffset(CGPoint(x: self.itemSize.width * self.currentIndex.cgFloat, y: 0), animated: false)
        }
    }
    
    func refreshNavigation(){
        chooseButton.isSelected = assetModels[currentIndex].isSelect
        title = (currentIndex + 1).description + "/" + assetModels.count.description
    }
    
    func addCache() {
        let scale = UIScreen.main.scale
        DispatchQueue.global().async {
            AlbumManager.imageManager.startCachingImages(for: self.assetModels.map{ $0.asset },
                                                         targetSize: CGSize(width: self.itemSize.width * scale, height: self.itemSize.height * scale),
                                                         contentMode: .aspectFill,
                                                         options: nil)
        }
    }
    func removeCache() {
        let scale = UIScreen.main.scale
        AlbumManager.imageManager.stopCachingImages(for: assetModels.map{ $0.asset },
                                                    targetSize: CGSize(width: itemSize.width * scale, height: itemSize.height * scale),
                                                    contentMode: .aspectFill,
                                                    options: nil)
    }
    
    func chooseClick() {
        chooseAction?(currentIndex, chooseButton, self)
    }
}

extension PhotosBrowerController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPreviewCell.description(), for: indexPath) as! PhotoPreviewCell
        cell.assetModel = assetModels[indexPath.row]
        cell.singleTapAction = { [weak self] in
            guard let `self` = self else { return }
            let isHidden = self.navigationController?.isNavigationBarHidden ?? false
            self.navigationController?.setNavigationBarHidden(!isHidden, animated: true)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (cell as? PhotoPreviewCell)?.resetZoomScale()
    }
   
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentIndex = (scrollView.contentOffset.x / scrollView.bounds.width).roundInt
        refreshNavigation()
    }
}









