//
//  UIView.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/16/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa

extension UIView {
    
    // Sets radius for the view's corners
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    // Rounds a button
    var isRounded: Bool {
        get {
            let radius = min(CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds)) / 2.0
            
            return radius == cornerRadius
        } set {
            if newValue {
                let radius = min(CGRectGetHeight(self.bounds), CGRectGetWidth(self.bounds)) / 2.0
                
                cornerRadius = radius
            }
        }
    }    
}

extension UIView {
    
    // Simplifies updating the alpha's view with RAC
    public var rac_alpha: MutableProperty<CGFloat> {
        return lazyMutableProperty(self, key: &AssociationKey.alpha, setter: { self.alpha = $0 }, getter: { self.alpha })
    }
    
    // Simplifies updating the hidden property of a view with RAC
    public var rac_hidden: MutableProperty<Bool> {
        return lazyMutableProperty(self, key: &AssociationKey.hidden, setter: { self.hidden = $0 }, getter: { self.hidden })
    }
}