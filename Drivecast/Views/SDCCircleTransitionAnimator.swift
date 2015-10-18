//
//  SDCCircleTransitionAnimator.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/16/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit

// Reference: http://www.raywenderlich.com/86521/how-to-make-a-view-controller-transition-animation-like-in-the-ping-app
class SDCCircleTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var transitionContext: UIViewControllerContextTransitioning?

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
        
        let containerView = transitionContext.containerView()!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let referenceCenterView = fromViewController.view
        let circleView = UIView()
        
        circleView.center = referenceCenterView.center
        circleView.frame.size = CGSize(width: 4, height: 4)

        containerView.addSubview(toViewController.view)
        
        // Initial path
        let circleMaskPathInitial = UIBezierPath(ovalInRect: circleView.frame)
        
        // Final path
        let extremePoint = CGPoint(x: circleView.center.x - 0,
            y: circleView.center.y - CGRectGetHeight(toViewController.view.bounds))
        let radius = sqrt((extremePoint.x * extremePoint.x) + (extremePoint.y * extremePoint.y))
        let circleMaskPathFinal = UIBezierPath(ovalInRect: CGRectInset(circleView.frame, -radius, -radius))
        
        // Create mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = circleMaskPathFinal.CGPath
        toViewController.view.layer.mask = maskLayer
        
        // Animate
        let maskLayerAnimation = CABasicAnimation(keyPath: "path")
        maskLayerAnimation.fromValue    = circleMaskPathInitial.CGPath
        maskLayerAnimation.toValue      = circleMaskPathFinal.CGPath
        maskLayerAnimation.duration     = self.transitionDuration(transitionContext)
        maskLayerAnimation.delegate     = self
        maskLayer.addAnimation(maskLayerAnimation, forKey: "path")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.transitionContext?.completeTransition(!self.transitionContext!.transitionWasCancelled())
        self.transitionContext?.viewControllerForKey(UITransitionContextFromViewControllerKey)?.view.layer.mask = nil
    }
}
