//
//  UILabel.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/19/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa

extension UILabel {
    
    // Simplifies updating a label's text with RAC
    public var rac_text: MutableProperty<String> {
        return lazyMutableProperty(self, key: &AssociationKey.text, setter: { self.text = $0 }, getter: { self.text ?? "" })
    }
}