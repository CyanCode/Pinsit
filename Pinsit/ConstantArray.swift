//
//  ConstantArray.swift
//  Pinsit
//
//  Created by Walker Christie on 6/23/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation

class ConstantArray {
    var constants = [AnyObject]()
    var array = [AnyObject]()
    
    convenience init(constants: [AnyObject]) {
        self.init()
        self.constants.append(constants)
    }
    
    convenience init(constant: AnyObject) {
        self.init()
        self.constants.append(constant)
    }
    
    func getFullArray() -> [AnyObject] {
        var full = array
        full.append(constants)
        
        return full
    }
}