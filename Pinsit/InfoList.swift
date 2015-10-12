//
//  InfoList.swift
//  Pinsit
//
//  Created by Walker Christie on 7/20/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import Foundation

class InfoList {
    let listLoc = File.documentsPath().URLByAppendingPathComponent("info.plist").path!
    let fm = NSFileManager.defaultManager()
    var dictionary: NSDictionary {
        get {
            return NSDictionary(contentsOfFile: listLoc)!
        }
    }
    
    init() {
        if fm.fileExistsAtPath(listLoc) == false {
            fm.createFileAtPath(listLoc, contents: nil, attributes: nil)
        }
    }

    func objectExistsWithKey(key: String) -> Bool {
        if dictionary.objectForKey(key) != nil {
            return true
        } else {
            return false
        }
    }
    
    func objectForKey(key: String) -> AnyObject {
        return dictionary.objectForKey(key)!
    }
    
    func setObjectForKey(object: AnyObject, key: String) {
        let dict = dictionary
        dict.setValue(object, forKey: key)
        writeDictionary(dict)
    }
    
    private func writeDictionary(dict: NSDictionary) {
        dict.writeToFile(listLoc, atomically: true)
    }
}