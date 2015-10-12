//
//  StoryboardManager.swift
//  Pinsit
//
//  Created by Walker Christie on 1/11/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import Foundation
import UIKit

class StoryboardManager {
    class func segueRegistration(vc: UIViewController) {
        let board = UIStoryboard(name: "Registration", bundle: nil)
        let initial = board.instantiateInitialViewController()
        
        vc.presentViewController(initial!, animated: true, completion: nil)
    }
    
    class func segueMain(vc: UIViewController) {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let initial = board.instantiateViewControllerWithIdentifier("main") 

        vc.presentViewController(initial, animated: true, completion: nil)
    }
}