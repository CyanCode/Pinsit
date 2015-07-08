//
//  EditProfile.swift
//  Pinsit
//
//  Created by Walker Christie on 11/9/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import UIKit

class EditProfile {
    var alert: UIAlertController
    
    init() {
        alert = UIAlertController(title: nil, message: "Edit your profile picture", preferredStyle: .ActionSheet)
    }
    
    func alertItems() {
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        let takeImage = UIAlertAction(title: "Take a picture", style: .Default) {(action) in
            print("Take Image")
        }
    
        let chooseImage = UIAlertAction(title: "Choose a picture", style: .Default) {(action) in
            print("Choose Image")
        }
        
        alert.addAction(cancelAction)
        alert.addAction(takeImage)
        alert.addAction(chooseImage)
    }
}