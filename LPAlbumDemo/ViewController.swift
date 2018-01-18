//
//  ViewController.swift
//  LPAlbumDemo
//
//  Created by 郜宇 on 2017/9/8.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import UIKit
import LPAlbum

class ViewController: UIViewController {

    fileprivate var collectionView: UICollectionView!
    fileprivate var photos = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "LPAlbum"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(openAlbum))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(clean))
        
        let layout = UICollectionViewFlowLayout()
        let wh = view.bounds.width / 4.0
        layout.itemSize = CGSize(width: wh, height: wh)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.description())
    }

    @objc func openAlbum() {
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
    }
    @objc func clean() {
        photos.removeAll()
        collectionView.reloadData()
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.description(), for: indexPath) as! PhotoCell
        cell.photoView.image = photos[indexPath.row]
        return cell
    }
}


extension UIViewController {
    func show(message: String){
        let controler = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        controler.addAction(UIAlertAction(title: "确定", style: .cancel, handler: nil))
        self.present(controler, animated: true, completion: nil)
    }
}












