//
//  UITextField.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/16/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa

extension UITextField {
    
    // Simplifies updating a textfield's text with RAC
    public var rac_text: MutableProperty<String> {
        return lazyAssociatedProperty(self, key: &AssociationKey.text) {
            
            self.addTarget(self, action: #selector(UITextField.changed), forControlEvents: UIControlEvents.EditingChanged)
            
            let property = MutableProperty<String>(self.text ?? "")
            
            property.producer
                .start { event in
                    switch event {
                    case let .Next(newValue):
                        self.text = newValue
                    default:
                        break
                    }
            }
            
            return property
        }
    }
    
    func changed() {
        rac_text.value = self.text ?? ""
    }
}