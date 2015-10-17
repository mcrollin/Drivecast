//
//  RACHelpers.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/16/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import ReactiveCocoa

struct AssociationKey {
    static var hidden: UInt8    = 1
    static var alpha: UInt8     = 2
    static var text: UInt8      = 3
    static var enabled: UInt8   = 4
}

func lazyAssociatedProperty<T: AnyObject>(host: AnyObject,
    key: UnsafePointer<Void>, factory: () -> T) -> T {
        var associatedProperty = objc_getAssociatedObject(host, key) as? T
        
        if associatedProperty == nil {
            associatedProperty = factory()
            objc_setAssociatedObject(host, key, associatedProperty,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        
        return associatedProperty!
}

func lazyMutableProperty<T>(host: AnyObject, key: UnsafePointer<Void>,
    setter: T -> (), getter: () -> T) -> MutableProperty<T> {
        return lazyAssociatedProperty(host, key: key) {
            let property = MutableProperty<T>(getter())
            
            property.producer
                .start { event in
                    switch event {
                    case let .Next(newValue):
                        setter(newValue)
                    default:
                        break
                    }
            }
            
            return property
        }
}