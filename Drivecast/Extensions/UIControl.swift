//
//  UIControl.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/19/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa

extension UIControl {
    
    // Simplifies a control enable status update with RAC
    public var rac_enabled: MutableProperty<Bool> {
        return lazyMutableProperty(self, key: &AssociationKey.hidden, setter: { self.enabled = $0 }, getter: { self.enabled })
    }
}