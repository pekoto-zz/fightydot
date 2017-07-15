//
//  Weak.swift
//  Ananke
//
//  Created by Graham McRobbie on 23/12/2016.
//  Copyright © 2016 Graham McRobbie. All rights reserved.
//
//  A wrapper to allow for an array of unowned objects.
//

import Foundation

class Unowned<T: AnyObject> {
    unowned var value : T
    
    init(value: T) {
        self.value = value
    }
}
