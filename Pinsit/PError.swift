//
//  PError.swift
//  Pinsit
//
//  Created by Walker Christie on 10/7/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation

class PError {
    let errorDomain = "com.walkerchristie.Pinsit"
    
    enum ErrorCode: Int {
        case PWritingError = 1000
        case PReadingError = 1001
        case PDeletingError = 1002
        case PVideoSaveError = 1003
        case PCoordinateFindError = 1004
        case PUserDoesNotExistError = 1005
    }
    
    func constructErrorWithCode(code: NSNumber) -> NSError {
        let errors = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("errors", ofType: "plist")!)
        var value = errors?.objectForKey(code.stringValue) as String
        var error: NSError?
        
        let details = [value : NSLocalizedDescriptionKey]
        
        return NSError(domain: errorDomain, code: code.integerValue, userInfo: details)
    }
}