//
//  UIButton.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/20/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa

extension UIButton {
    
    // Simplifies button title update with RAC
    public var rac_title: MutableProperty<String> {
        return lazyMutableProperty(self, key: &AssociationKey.title, setter: { self.setTitle($0, forState: .Normal) }, getter: { self.titleForState(.Normal) ?? "" })
    }
}