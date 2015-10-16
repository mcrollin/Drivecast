//
//  SDCSignInViewController.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/15/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SpinKit
import SnapKit

class SDCSignInViewController: UIViewController {

    var menuViewController: UITabBarController?
    let activityMonitor:RTSpinKitView = RTSpinKitView(style: .StylePulse, color: UIColor(named: .Main).colorWithAlphaComponent(0.2))
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var dotImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        configureView()
        configureTabBar()
        
//        SDCSafecastAPI.signInUser("###@###.###", password: "##########") { result in
//            switch result {
//            case .Success(let user):
//                log(user)
//                
        self.presentMenu()
//            case .Failure(let error):
//                log(error)
//            }
//        }
        
        // @todo: Implement sign in
//        performSelector(Selector("loadMenu"), withObject: nil, afterDelay: 3.0)
    }
}

// MARK - UIView
extension SDCSignInViewController {
    func presentMenu() {
        self.activityMonitor.stopAnimating()
        
        UIView.animateWithDuration(1.0, delay: 0.0,
                options: [.CurveEaseInOut],
                animations: {
                    self.logoImageView.alpha    = 0.1
                    self.dotImageView.alpha     = 0.1
            }, completion: { finished in
                self.activityMonitor.removeFromSuperview()
                
                if let menuViewController = self.menuViewController {
                    self.navigationController?.pushViewController(menuViewController, animated: true)
                }
        })
    }
    
    func configureTabBar() {
        menuViewController = UIStoryboard.Scene.Main.menuViewController() as? UITabBarController
        
        menuViewController?.delegate    = self
        navigationController?.delegate  = self
        
        if let items = menuViewController?.tabBar.items {
            for item in items {
                item.title          = "";
                item.imageInsets    = UIEdgeInsetsMake(6, 0, -6, 0);
            }
        }
    }
    
    func configureView() {
        logoImageView.alpha     = 1.0
        dotImageView.alpha      = 1.0
        
        activityMonitor.startAnimating()

        view.addSubview(activityMonitor)
        
        activityMonitor.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.view)
        }
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

// MARK - UINavigationControllerDelegate
extension SDCSignInViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController,
        animationControllerForOperation operation: UINavigationControllerOperation,
        fromViewController fromVC: UIViewController,
        toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            return SDCCircleTransitionAnimator()
    }
}
