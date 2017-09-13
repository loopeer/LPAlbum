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
        return LPAlbum.Config.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.navigationBar.barTintColor = LPAlbum.Config.barTintColor
        self.navigationBar.tintColor = LPAlbum.Config.tintColor
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
