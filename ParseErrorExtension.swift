//
//  File.swift
//  Pinsit
//
//  Created by Walker Christie on 7/7/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import Foundation

extension PFFile {
    func getDataWithError() throws -> NSData {
        var error: NSError?
        let data = self.getData(&error)
        
        if error != nil {
            throw error!
        } else {
            return data!
        }
    }
}

extension PFQuery {
    func findObjectsWithError() throws -> [PFObject] {
        var error: NSError?
        let objects = self.findObjects(&error)
        
        if error != nil {
            throw error!
        } else {
            return objects! as! [PFObject]
        }
    }
}

extension PFObject {
    func saveWithError() throws {
        var error: NSError?
        save(&error)
        
        if error != nil {
            throw error!
        }
    }
    
    func deleteWithError() throws {
        var error: NSError?
        delete(&error)
        
        if error != nil {
            throw error!
        }
    }
}