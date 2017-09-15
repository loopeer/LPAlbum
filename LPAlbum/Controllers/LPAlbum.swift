//
//  LPAlbum.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/8.
//  Copyright © 2017年 Loopeer. All rights reserved.
/**
   TODO: 1. add CompleteSelectAssetsBlock
         2. add Photo Cache
         4. 图片详情zoom
         5. 选取单个图片的情形
         6. 支持裁剪(正方形, 圆形)
         7. take photo statusBarAnimation 
         8. 是否要加Observer, 如果有Observer, 图片添加或者删除了, 要响应的添加或删除该图片的缓存
         9. 完善demo(照片墙, 权限跳转)
        10. 加一些动画效果
        11. 添加注释
        12. 是否内部对图片处理画一遍
 */

import UIKit
import Photos

public typealias SetConfigBlock = ((inout LPAlbum.Config) -> Void)
public typealias CompleteSelectImagesBlock = (([UIImage]) -> Void)
public typealias ErrorBlock = ((UIViewController ,AlbumError) -> Void)
public typealias TargetSizeBlock = ((CGSize) -> CGSize)

public class LPAlbum: UIViewController {
 
    fileprivate let config: Config
    fileprivate var completeSelectImagesBlock: CompleteSelectImagesBlock?
    fileprivate var errorBlock: ErrorBlock?
    fileprivate var targetSizeBlock: TargetSizeBlock?
    
    fileprivate var albumManager: AlbumManager!
    fileprivate var collectionView: UICollectionView!
    fileprivate var titleView: TitleView!
    fileprivate var menuView: DropMenuView!
    
    fileprivate var currentAlbumIndex: Int = 0
    fileprivate var albumModels = [AlbumModel]()
    fileprivate var allAssets = [PHAsset]() {
        didSet{
            //如果有Observer, 图片添加或者删除了, 要响应的添加或删除该图片的缓存
            let itemSize = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
            let scale = UIScreen.main.scale
            let targetSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
            AlbumManager.imageManager.startCachingImages(for: allAssets, targetSize: targetSize, contentMode: .aspectFill, options: nil)
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

    public override func loadView() {
        super.loadView()
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

        menuView = DropMenuView(frame: view.bounds, albums: albumModels)
        view.addSubview(menuView)
    }
    
    func cancel() { dismiss(animated: true, completion: nil) }
    func confirm() {
        let assets = albumModels.allSelectedAsset
        var result = [UIImage]()
        for asset in assets {
            let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight) //PHImageManagerMaximumSize
            let targetSize = targetSizeBlock?(size) ?? size
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            option.resizeMode = .exact
            AlbumManager.getPhoto(asset: asset, targetSize: targetSize, option: option, resultHandler: {[weak self] (image, _) in
                if image != nil { result.append(image!) }
                if result.count == assets.count {
                    self?.completeSelectImagesBlock?(result)
                    self?.cancel() }
            })
        }
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
                guard self.checkoutMaxCount(willselect: !$0, show: self) else { return }
                var newModel = model
                newModel.isSelect = !$0
                self.albumModels = self.albumModels.change(assetModel: newModel)
                self.collectionView.reloadItems(at: [indexPath])
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
            guard checkoutMaxCount(willselect: true, show: self) else { return }
            AuthorizationTool.cameraRequestAuthorization{
                $0 == .authorized ? self.takePhoto() : self.errorBlock?(self, AlbumError.noCameraPermission)
            }
        }else{
            let previewVc = PhotosPreviewController()
            let assetModels = albumModels[currentAlbumIndex].assetModels
            previewVc.assetModels = assetModels
            previewVc.currentIndex = config.hasCamera ? indexPath.row - 1 : indexPath.row
            previewVc.chooseAction = {[weak self] (index, button, vc) in
                guard let `self` = self else { return }
               
                let willselect = !button.isSelected
                guard self.checkoutMaxCount(willselect: willselect, show: vc) else { return }
                
                button.isSelected = willselect
                vc.assetModels[index].isSelect = willselect
                self.albumModels = self.albumModels.change(assetModel: vc.assetModels[index])
                
                let cellIndex =  self.config.hasCamera ? index + 1 : index
                self.collectionView.reloadItems(at: [IndexPath(row: cellIndex, section: 0)])
            }
            navigationController?.pushViewController(previewVc, animated: true)
        }
    }
    
    func takePhoto() {
        let sourceType = UIImagePickerControllerSourceType.camera
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { fatalError("摄像头不可用") }
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func checkoutMaxCount(willselect: Bool, show vc: UIViewController) -> Bool {
        if self.config.maxSelectCount == self.albumModels[0].selectCount && willselect {
            self.errorBlock?(vc,AlbumError.moreThanLargestChoiceCount)
            return false
        }
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










