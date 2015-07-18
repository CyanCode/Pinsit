//
//  Credentials.swift
//  Pinsit
//
//  Created by Walker Christie on 1/15/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import Parse
class Credentials {
    var username: String!
    var password: String!
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    ///Does the password contain more than or 6 characters
    func confirmPassword() -> Bool {
        if password.characters.count >= 6 {
            return true
        } else {
            return false
        }
    }
    
    ///Does the username contain more than or 6 characters
    func confirmUsername() -> Bool {
        if username.characters.count >= 6 {
            return true
        } else {
            return false
        }
    }
    
    ///Is the username available for use?
    func usernameAvailable(responder: UIViewController) -> Bool {
        let query = PFQuery(className: "Users")
        query.whereKey("username", equalTo: username)
        
        var error: NSError?
        let count = query.countObjects(&error)
        
        if error != nil {
            let alert = UIAlertController(title: "Oops!", message: "A network error has occured, are you sure you are connected to the internet?", preferredStyle: .Alert)
            let dismiss = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
            alert.addAction(dismiss)
            
            responder.presentViewController(alert, animated: true, completion: nil)
            
            return false
        }
        
        if count >= 1 {
            return false
        } else {
            return true
        }
    }
}