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
        let controller = LoginViewController()
        controller.signUpController = SignUpViewController()
        
        vc.presentViewController(controller, animated: true, completion: nil)
    }
    
    class func segueMain(vc: UIViewController) {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let initial = board.instantiateViewControllerWithIdentifier("main") as UIViewController

        vc.presentViewController(initial, animated: true, completion: nil)
    }
}