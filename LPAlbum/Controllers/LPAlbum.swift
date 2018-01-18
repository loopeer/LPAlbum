//
//  LPAlbum.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/8.
//  Copyright © 2017年 Loopeer. All rights reserved.
/**
   TODO: 1. add CompleteSelectAssetsBlock 可以选择原图
         2. 选取单个图片的情形
         3. 支持裁剪(正方形, 圆形)
         4. 是否要加Observer, 如果有Observer, 图片添加或者删除了, 要响应的添加或删除该图片的缓存
         5. 加一些动画效果
         6. 是否内部对图片处理画一遍
 */

import UIKit
import Photos

public typealias SetConfigBlock = ((inout LPAlbum.Config) -> Void)
public typealias CompleteSelectImagesBlock = (([UIImage]) -> Void)
public typealias CompleteSelectAssetsBlock = (([PHAsset]) -> Void)
public typealias ErrorBlock = ((UIViewController ,AlbumError) -> Void)
public typealias TargetSizeBlock = ((CGSize) -> CGSize)


public class LPAlbum: UIViewController {
 
    fileprivate let config: Config
    fileprivate var completeSelectImagesBlock: CompleteSelectImagesBlock?
    fileprivate var completeSelectAssetsBlock: CompleteSelectAssetsBlock?

    fileprivate var errorBlock: ErrorBlock?
    fileprivate var targetSizeBlock: TargetSizeBlock?
    
    fileprivate var collectionView: UICollectionView!
    fileprivate var titleView: TitleView!
    fileprivate var menuView: DropMenuView!
    fileprivate var confirmItem: UIBarButtonItem!
    
    fileprivate var currentAlbumIndex: Int = 0
    fileprivate var albumModels = [AlbumModel]()
    fileprivate var selectedAssets = [PHAsset]()
    fileprivate var allAssets = [PHAsset]() {
        didSet{
            //如果有Observer, 图片添加或者删除了, 要响应的添加或删除该图片的缓存
            let itemSize = (self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
            let scale = UIScreen.main.scale
            let targetSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
            DispatchQueue.global().async {
                AlbumManager.imageManager.startCachingImages(for: self.allAssets, targetSize: targetSize, contentMode: .aspectFill, options: nil)
            }
        }
    }
    
    @discardableResult
    public class func show(at: UIViewController, set: SetConfigBlock? = nil) -> LPAlbum {
        var c = Config(); set?(&c);
        let vc = LPAlbum(c)
        // 异步延后调用, 使`errorBlock`不为空
        DispatchQueue.main.async {
            let nav = LPNavigationController(rootViewController: vc)
            AuthorizationTool.albumRRequestAuthorization {
                $0 == .authorized ? at.present(nav, animated: true, completion: nil) : vc.errorBlock?(at, AlbumError.noAlbumPermission)
            }
        }
        return vc
    }
    
    @discardableResult
    public func targeSize(_ map: @escaping TargetSizeBlock) -> Self{
        targetSizeBlock = map
        return self
    }
    
    @discardableResult
    public func complete(_ complete: @escaping CompleteSelectImagesBlock) -> Self {
        completeSelectImagesBlock = complete
        return self
    }
    
    @discardableResult
    public func error(_ error: @escaping ErrorBlock) -> Self {
        errorBlock = error
        return self
    }
    
    init(_ config: Config) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        albumModels = AlbumManager.getAlbums()
        setupUI()
        allAssets = albumModels[0].assetModels.map{ $0.asset }
        
        titleView.clickAction = { [weak self] in
            $0.isSelected = !$0.isSelected
            $0.isSelected ?
            self?.menuView.show(begin: {
                self?.titleView.isEnabled = false
            }, complete: { 
                self?.titleView.isEnabled = true
            }) :
            self?.menuView.dismiss(begin: {
                self?.titleView.isEnabled = false
            }, complete: { 
                self?.titleView.isEnabled = true
            })
        }
        menuView.maskViewClick = {[weak self] _ in
            self?.titleView.isSelected = false
        }
        menuView.menuViewDidSelect = {[weak self] in
            self?.titleView.isSelected = false
            self?.currentAlbumIndex = $0
            self?.titleView.title = self?.albumModels[$0].name
            self?.collectionView.reloadData()
        }
    }
    
    deinit {
        print("\(self) deinit")
    }
}


extension LPAlbum {
    
    func setupUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: String.local("取消"), style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: String.local("完成"), style: .plain, target: self, action: #selector(confirm))
        navigationItem.rightBarButtonItem!.isEnabled = false
        confirmItem = navigationItem.rightBarButtonItem!
        
        titleView = TitleView(frame: .zero)
        navigationItem.titleView = titleView
        titleView.title = albumModels[currentAlbumIndex].name
        
        let layout = UICollectionViewFlowLayout()
        let photoW = (view.bounds.width - config.photoPadding * CGFloat(config.columnCount - 1)) / CGFloat(config.columnCount)
        layout.itemSize = CGSize(width: photoW, height: photoW)
        layout.minimumLineSpacing = config.photoPadding
        layout.minimumInteritemSpacing = config.photoPadding
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height),
                                          collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        
        collectionView.register(AlbumCollectionCell.self, forCellWithReuseIdentifier: AlbumCollectionCell.description())
        collectionView.register(TakeCameraCell.self, forCellWithReuseIdentifier: TakeCameraCell.description())

        menuView = DropMenuView(frame: CGRect(x: 0, y: 88, width: .screenWidth, height: .screenHeight - 88), albums: albumModels)
        view.addSubview(menuView)
        menuView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11, *) {
            menuView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        }else{
            menuView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
        }
        menuView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        menuView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    @objc func cancel() { dismiss(animated: true, completion: nil) }
    @objc func confirm() {
        var result = [UIImage]()
        for asset in selectedAssets {
            let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight) //PHImageManagerMaximumSize
            let targetSize = targetSizeBlock?(size) ?? size
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            option.resizeMode = .exact
            DispatchQueue.global().async {
                AlbumManager.getPhoto(asset: asset,
                                      targetSize: targetSize,
                                      adaptScale: false,
                                      option: option,
                                      contentMode: .aspectFit,
                                      resultHandler: {[weak self] (image, _) in
                    if image != nil { result.append(image!) }
                    if result.count == self?.selectedAssets.count {
                        DispatchQueue.main.async { self?.completeSelectImagesBlock?(result) }
                    }
                })
            }
            cancel()
        }
    }
    
    func cellDidSelectForPreviewViewController(indexPath: IndexPath) -> UIViewController{
        let previewVc = PhotosBrowerController()
        let assetModels = albumModels[currentAlbumIndex].assetModels
        previewVc.assetModels = assetModels
        previewVc.currentIndex = config.hasCamera ? indexPath.row - 1 : indexPath.row
        previewVc.chooseAction = {[weak self] (index, button, vc) in
            guard let `self` = self else { return }
            
            let willselect = !button.isSelected
            let asset = vc.assetModels[index].asset
            guard self.checkoutCount(willselect: willselect, asset: asset, show: vc) else { return }
            
            button.isSelected = willselect
            vc.assetModels[index].isSelect = willselect
            self.albumModels = self.albumModels.change(assetModel: vc.assetModels[index])
            
            let cellIndex =  self.config.hasCamera ? index + 1 : index
            self.collectionView.reloadItems(at: [IndexPath(row: cellIndex, section: 0)])
        }
        return previewVc
    }
}


extension LPAlbum: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if config.hasCamera && indexPath.row == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: TakeCameraCell.description(), for: indexPath) as! TakeCameraCell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCollectionCell.description(), for: indexPath) as! AlbumCollectionCell
            
            let model = albumModels[currentAlbumIndex].assetModels[config.hasCamera ? indexPath.row - 1 : indexPath.row]
            cell.set(model)
            cell.iconClickAction = {[weak self] in
                guard let `self` = self else { return }
                guard self.checkoutCount(willselect: !$0, asset: model.asset, show: self) else { return }
                var newModel = model
                newModel.isSelect = !$0
                self.albumModels = self.albumModels.change(assetModel: newModel)
                UIView.performWithoutAnimation { self.collectionView.reloadItems(at: [indexPath]) }
            }
            if #available(iOS 9.0, *) {
                guard traitCollection.forceTouchCapability == .available else { return cell }
                registerForPreviewing(with: self, sourceView: cell)
            }
            return cell
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let photoCount = albumModels[currentAlbumIndex].assetModels.count
        return config.hasCamera ? photoCount + 1 : photoCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if config.hasCamera && indexPath.row == 0 {
            guard checkoutCount(willselect: true, show: self) else { return }
            AuthorizationTool.cameraRequestAuthorization{
                $0 == .authorized ? self.takePhoto() : self.errorBlock?(self, AlbumError.noCameraPermission)
            }
        }else{
            let previewVc = cellDidSelectForPreviewViewController(indexPath: indexPath)
            navigationController?.pushViewController(previewVc, animated: true)
        }
    }
    
    func takePhoto() {
        let sourceType = UIImagePickerControllerSourceType.camera
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { fatalError("摄像头不可用") }
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func checkoutCount(willselect: Bool, asset: PHAsset? = nil, show vc: UIViewController) -> Bool {
        
        if self.config.maxSelectCount == self.selectedAssets.count && willselect {
            self.errorBlock?(vc,AlbumError.moreThanLargestChoiceCount)
            return false
        }
        guard let asset = asset else { return true }
        if willselect { self.selectedAssets.append(asset) } else { _ = self.selectedAssets.remove(asset) }
        confirmItem.isEnabled = self.selectedAssets.count > 0
        return true
    }
}

extension LPAlbum: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        guard let image = (info[UIImagePickerControllerEditedImage] as? UIImage) ?? ( info[UIImagePickerControllerOriginalImage] as? UIImage) else {
            picker.dismiss(animated: true, completion: nil); return;
        }
        
        PHPhotoLibrary.shared().performChanges({ 
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { [weak self] (success, error) in
            guard let `self` = self else { return }
            if success == false || error != nil { self.errorBlock?(self, AlbumError.savePhotoError) }
            DispatchQueue.main.async {
                let targetSize = self.targetSizeBlock?(image.size) ?? image.size
                self.completeSelectImagesBlock?([image.scaleImage(to: targetSize, contentMode: .scaleAspectFill) ?? image])
                picker.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}


extension LPAlbum: UIViewControllerPreviewingDelegate {
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let cell = previewingContext.sourceView as? AlbumCollectionCell,
              let indexPath = collectionView.indexPath(for: cell) else { return nil }
        let previewVc = PhotoPreviewController()
        previewVc.assetModel = albumModels[currentAlbumIndex].assetModels[config.hasCamera ? indexPath.row - 1 : indexPath.row]
        previewingContext.sourceRect = previewingContext.sourceView.bounds
        return previewVc
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let cell = previewingContext.sourceView as? AlbumCollectionCell,
              let indexPath = collectionView.indexPath(for: cell) else { return }
        let vc = cellDidSelectForPreviewViewController(indexPath: indexPath)
        navigationController?.pushViewController(vc, animated: true)
    }
}










