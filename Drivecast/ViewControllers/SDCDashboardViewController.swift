//
//  SDCDashboardViewController.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/14/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SDCDashboardViewController: UIViewController {
    
    // ViewModel handling all logic
    let viewModel   = SDCDashboardViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bindViewModel()
        
//        SDCSafecastAPI.retrieveImports(2, page: 1) { result in
//            switch result {
//            case .Success(let imports):
//                log(imports)
//            case .Failure(let error):
//                log(error)
//            }
//        }
    }
}

// MARK - UIView
extension SDCDashboardViewController {
    func configureView() {        
        navigationItem.titleView   = UIImageView(image: UIImage(asset: .SafecastLettersSmall))
        view.backgroundColor       = UIColor(named: .Background)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.Asset.More.image,
            style: UIBarButtonItemStyle.Plain,
            target: self, action: Selector("openAboutModal")
        )
        
        #if DEBUG
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.Asset.Dot.image,
            style: UIBarButtonItemStyle.Plain,
            target: self, action: Selector("deauthenticate")
        )
        #endif
    }

    func deauthenticate() {
        SDCUser.authenticatedUser = nil
        
        tabBarController?.navigationController?.popViewControllerAnimated(true)
    }
    
    func openAboutModal() {
        let about = UIStoryboard.Scene.Main.aboutViewController()
        
        presentViewController(about, animated: true, completion: nil)
    }
}

// MARK - Signal Bindings
extension SDCDashboardViewController {
    
    func bindViewModel() {
    }
}
