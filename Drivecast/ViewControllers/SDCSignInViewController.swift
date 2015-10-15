//
//  SDCSignInViewController.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/15/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SDCSignInViewController: UIViewController {

    var menuViewController: UITabBarController?
    
    @IBOutlet var logoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bindViewModel()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        configureTabBar()
        animateLogo()
        
        // @todo: Implement sign in
        performSelector(Selector("loadMenu"), withObject: nil, afterDelay: 3.0)
    }
}

// MARK - UIView
extension SDCSignInViewController {
    func configureTabBar() {
        menuViewController = UIStoryboard.Scene.Main.menuViewController() as? UITabBarController
        
        menuViewController?.delegate = self
        
        if let items = menuViewController?.tabBar.items {
            for item in items {
                item.title          = "";
                item.imageInsets    = UIEdgeInsetsMake(6, 0, -6, 0);
            }
        }
    }
    
    func animateLogo() {
        UIView.animateWithDuration(0.9, delay: 0.0,
            options: [.CurveEaseInOut, .Autoreverse, .Repeat],
            animations: {
                self.logoImageView.alpha = 0.5
            }, completion: nil)
    }
    
    func loadMenu() {
        UIView.animateWithDuration(1.0, delay: 0,
            options: [.CurveEaseInOut, .BeginFromCurrentState],
            animations: {
                self.logoImageView.alpha = 0.0
            }, completion: { finished in
                if let menuViewController = self.menuViewController {
                    menuViewController.modalTransitionStyle = .CrossDissolve
                    
                    self.presentViewController(menuViewController, animated: true, completion: {
                        self.logoImageView.alpha = 1.0
                    })
                }
        })
    }
    
    func configureView() {
    }
}

// MARK - Signal Bindings
extension SDCSignInViewController {
    func bindViewModel() {
    }
}

// MARK - UITabBarControllerDelegate
extension SDCSignInViewController: UITabBarControllerDelegate {
    internal func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        // @todo: Need a more elegant way to do this
        guard tabBarController.viewControllers?.indexOf(viewController) == 1 else {
            return true
        }
        
        let recordController = UIStoryboard.Scene.Main.recordViewController()
        
        tabBarController.presentViewController(recordController, animated: true, completion: nil)
        
        return false;
    }
}
