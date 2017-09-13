//
//  DropMenuView.swift
//  MaiDou
//
//  Created by 郜宇 on 2017/8/22.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import UIKit
import Photos

class DropMenuView: UIView {

    fileprivate let tableView = UITableView()
    fileprivate let backgroundView = UIView()
    fileprivate var albums = [AlbumModel]()
    
    var maskViewClick: ((DropMenuView) -> Void)?
    var menuViewDidSelect: ((Int) -> Void)?
    
    func show(begin: (() -> Void)? = nil, complete: (() -> Void)? = nil) {
        begin?()
        alpha = 1.0
        UIView.animate(withDuration: 0.35, animations: {
            self.tableView.transform = CGAffineTransform(translationX: 0, y: self.tableView.bounds.height)
            self.backgroundView.alpha = 1.0
        }) { (_) in
            complete?()
        }
    }
    
    func dismiss(begin: (() -> Void)? = nil, complete: (() -> Void)? = nil) {
        begin?()
        UIView.animate(withDuration: 0.35, animations: {
            self.tableView.transform = .identity
            self.backgroundView.alpha = 0.0
        }) { (_) in
            self.alpha = 0
            complete?()
        }
    }
    
    init(frame: CGRect, albums: [AlbumModel]) {
        super.init(frame: frame)
        
        let rowHeight: CGFloat = 65
        
        self.albums = albums
        tableView.delegate = self
        tableView.dataSource = self
        alpha = 0
        
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.alpha = 0
        let tap = UITapGestureRecognizer(target: self, action: #selector(maskClick))
        backgroundView.addGestureRecognizer(tap)
        
        addSubview(backgroundView)
        addSubview(tableView)
        
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.description())
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.separatorInset = .zero
        tableView.rowHeight = rowHeight
        
        let height = min(rowHeight * CGFloat(albums.count), 400)
        tableView.frame = CGRect(x: 0, y: -height, width: frame.size.width, height: height)
        backgroundView.frame = frame
    }
    
    @objc private func maskClick() { dismiss();  maskViewClick?(self) }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DropMenuView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.description(), for: indexPath) as! MenuCell
        cell.album = albums[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        (cell as! MenuCell).album = albums[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss()
        menuViewDidSelect?(indexPath.row)
    }
}


final class MenuCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let iconView = UIImageView()
    
    var album: AlbumModel! {
        didSet{
            titleLabel.text = album.name + "   \(album.count)"
            AlbumManager.getPhoto(asset: album.cover, targetSize: iconView.frame.size) {[weak self] (image, _) in
                self?.iconView.image = image
            }
            layoutIfNeeded()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.systemFont(ofSize: 17)
        titleLabel.lineBreakMode = .byTruncatingMiddle
        
        iconView.clipsToBounds = true
        iconView.contentMode = .scaleAspectFill
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 10.0
        titleLabel.sizeToFit()
        titleLabel.bounds = CGRect(x: 0, y: 0,
                                   width: min(bounds.width - iconView.frame.maxX - 2 * padding, titleLabel.frame.width),
                                   height: titleLabel.frame.height)
        iconView.bounds = CGRect(x: 0, y: 0, width: 55, height: 55)
        iconView.center = CGPoint(x: 40, y: bounds.height * 0.5)
        titleLabel.center = CGPoint(x: titleLabel.frame.width * 0.5 + iconView.frame.maxX + padding, y: bounds.height * 0.5)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





