//
//  SDCUploadViewController.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/15/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SDCUploadViewController: UIViewController {
    let viewModel   = SDCUploadViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bindViewModel()
    }
}

// MARK - UIView
extension SDCUploadViewController {
    func configureView() {
        self.view.backgroundColor = UIColor(named: .Background)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.Asset.More.image,
            style: UIBarButtonItemStyle.Plain,
            target: self, action: Selector("openAboutModal")
        )
    }
    
    func openAboutModal() {
        let about = UIStoryboard.Scene.Main.aboutViewController()
    
        self.presentViewController(about, animated: true, completion: nil)
    }
}

// MARK - Signal Bindings
extension SDCUploadViewController {
    func bindViewModel() {
    }
}
