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

    let viewModel = SDCSignInViewModel()
    
    // Main screen to be shown after authentication
    var menuViewController: UITabBarController?
    
    // Activity monitor spinner
    let activityMonitor:RTSpinKitView = RTSpinKitView(style: .StylePulse,
        color: UIColor(named: .Main).colorWithAlphaComponent(0.2))
    
    // Sign in action
    var signInCocoaAction: CocoaAction!
    
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var dotImageView: UIImageView!
    @IBOutlet var signInFormView: UIView!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var emailUnderlineView: UIView!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordUnderlineView: UIView!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var explanationTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
        configureConstraints()
        configureTabBar()
    }
    
    override func viewDidAppear(animated: Bool) {
        viewModel.checkAuthentication()
    }
}

// MARK - UIView
extension SDCSignInViewController {
    func configureTabBar() {
        menuViewController = UIStoryboard.Scene.Main.menuViewController() as? UITabBarController
        
        menuViewController?.delegate    = self
        navigationController?.delegate  = self
        
        if let items = menuViewController?.tabBar.items {
            for item in items {
                item.title          = ""
                item.imageInsets    = UIEdgeInsetsMake(6, 0, -6, 0)
            }
        }
    }
    
    func configureView() {
        let textColor = UIColor(named: .TextColor)
        
        view.backgroundColor            = UIColor(named: .Background)
        emailTextField.textColor        = textColor
        passwordTextField.textColor     = textColor
        explanationTextView.textColor   = textColor
        
        resetView()
    }
    
    func resetView() {
        logoImageView.alpha     = 1.0
        dotImageView.alpha      = 1.0
        signInFormView.alpha    = 0.0
        
        let color = UIColor(named: .Main).colorWithAlphaComponent(0.2)
        
        emailTextField.delegate                 = self
        emailUnderlineView.backgroundColor      = color
        passwordTextField.delegate              = self
        passwordUnderlineView.backgroundColor   = color
        signInButton.borderColor                = color
        
        activityMonitor.startAnimating()
        
        view.addSubview(activityMonitor)
    }
    
    func configureConstraints() {
        activityMonitor.snp_makeConstraints { make in
            make.center.equalTo(self.dotImageView)
        }
        
        logoImageView.snp_removeConstraints()
        logoImageView.snp_makeConstraints { make in
            make.bottom.equalTo(self.signInFormView.snp_top).offset(-40)
        }
        
        resetConstraints()
    }
    
    func resetConstraints() {
        signInFormView.snp_removeConstraints()
        signInFormView.snp_makeConstraints { make in
            make.top.equalTo(self.dotImageView.snp_top)
        }
    }
    
    func presentSignInForm() {
        activityMonitor.stopAnimating()
        
        emailTextField.enabled      = true
        passwordTextField.enabled   = true
        
        UIView.animateWithDuration(0.5, delay: 0.0,
            options: [.CurveEaseInOut, .TransitionCrossDissolve],
            animations: {
                self.signInFormView.snp_removeConstraints()
                self.signInFormView.snp_makeConstraints { make in
                    make.centerY.equalTo(self.dotImageView).offset(40)
                }
                
                self.signInFormView.alpha   = 1.0
                self.dotImageView.alpha     = 0.0
                
                self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func dismissSignInForm() {
        // Dismiss the keyboard and resign first responder
        view.endEditing(true)
        
        // Dismiss the form
        UIView.animateWithDuration(0.5, delay: 0.0,
            options: [.CurveEaseInOut],
            animations: {
                self.resetView()
                self.resetConstraints()
                
                self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func presentMenu() {
        activityMonitor.stopAnimating()
        
        UIView.animateWithDuration(0.5, delay: 0.0,
            options: [.CurveEaseInOut],
            animations: {
                self.logoImageView.alpha    = 0.1
                self.dotImageView.alpha     = 0.1
            }, completion: { finished in
                self.activityMonitor.removeFromSuperview()
                self.emailTextField.text    = nil
                self.passwordTextField.text = nil
                
                if let menuViewController = self.menuViewController {
                    self.navigationController?.pushViewController(menuViewController, animated: true)
                }
        })
    }
    
    func animateSignInButton(enabled: Bool) {
        UIView.animateWithDuration(0.3, delay: 0.0,
            options: [.CurveEaseInOut],
            animations: {
                self.signInButton.backgroundColor   = UIColor(named: .Main)
                    .colorWithAlphaComponent(enabled ? 0.9 : 0.4)
            }, completion: nil)
    }
}

// MARK - Signal Bindings
extension SDCSignInViewController {
    
    func bindViewModel() {
        // Forwarding inputs to the viewModel
        viewModel.emailText             <~ emailTextField.rac_text
        viewModel.passwordText          <~ passwordTextField.rac_text

        // Updating UI elements
        emailTextField.rac_enabled      <~ viewModel.emailTextEnabled
        passwordTextField.rac_enabled   <~ viewModel.passwordTextEnabled
        signInButton.rac_enabled        <~ viewModel.signInButtonEnabled
        
        // Visually enable/disable the signInButton
        viewModel.signInButtonEnabled.producer.startWithNext { enabled in
            self.animateSignInButton(enabled)
        }
        
        // Binding the signIn action
        signInCocoaAction = CocoaAction(viewModel.signInAction!, input:nil)
        signInButton.addTarget(signInCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.TouchUpInside)
        
        // Presenting the menu if user is authenticated
        viewModel.userIsAuthenticated.producer.startWithNext { authenticated in
            if authenticated {
                self.presentMenu()
            }
        }
        
        // Presenting/dismissing the signInForm
        viewModel.signInFormIsVisible.producer.skip(1).startWithNext { visible in
            if visible {
                self.presentSignInForm()
            } else {
                self.dismissSignInForm()
            }
        }
    }
}

// MARK - UITextFieldDelegate
extension SDCSignInViewController: UITextFieldDelegate {
    
    private func updateTextFieldUndeline(textField: UITextField, alpha: CGFloat) {
        UIView.animateWithDuration(0.3, delay: 0.0,
            options: [.CurveEaseInOut],
            animations: {
                if textField == self.emailTextField {
                    self.emailUnderlineView.backgroundColor = self.emailUnderlineView.backgroundColor?.colorWithAlphaComponent(alpha)
                } else {
                    self.passwordUnderlineView.backgroundColor = self.passwordUnderlineView.backgroundColor?.colorWithAlphaComponent(alpha)
                }
            } , completion: nil)
    }
    
    internal func textFieldDidBeginEditing(textField: UITextField) {
        updateTextFieldUndeline(textField, alpha: 0.6)
    }

    internal func textFieldDidEndEditing(textField: UITextField) {
        updateTextFieldUndeline(textField, alpha: 0.2)
    }
}

// @todo: Handle UIKeyboardDelegate for the return key

// MARK - UITabBarControllerDelegate
extension SDCSignInViewController: UITabBarControllerDelegate {
    
    internal func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        // @todo: Need a more elegant way to do this
        guard tabBarController.viewControllers?.indexOf(viewController) == 1 else {
            return true
        }
        
        let recordController = UIStoryboard.Scene.Main.recordViewController()
        
        tabBarController.presentViewController(recordController, animated: true, completion: nil)
        
        return false
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
