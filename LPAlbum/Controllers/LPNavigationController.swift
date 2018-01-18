//
//  LPNavigationController.swift
//  LPAlbum
//
//  Created by 郜宇 on 2017/9/8.
//  Copyright © 2017年 Loopeer. All rights reserved.
//

import UIKit

class LPNavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return LPAlbum.Style.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = true
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        navigationBar.barTintColor = LPAlbum.Style.barTintColor
        navigationBar.tintColor = LPAlbum.Style.tintColor
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: LPAlbum.Style.barTitleColor]
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
