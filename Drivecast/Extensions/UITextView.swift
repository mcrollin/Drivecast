//
//  UITextView.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/18/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa

extension UITextView {
    public var rac_attributed_text: MutableProperty<NSAttributedString> {
        return lazyMutableProperty(self, key: &AssociationKey.attributedText, setter: { self.attributedText = $0 }, getter: { self.attributedText })
    }
}