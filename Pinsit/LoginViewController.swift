//
//  LoginViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 1/11/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButton(sender: AnyObject) {
        let button = sender as! UIButton
        
        button.enabled = false
        PFUser.logInWithUsernameInBackground(usernameField.text!, password: passwordField.text!) { (user, error) -> Void in
            button.enabled = true
            
            if error != nil {
                let alert = RegistrationAlerts(vc: self)
                
                if error!.code == PFErrorCode.ErrorConnectionFailed.rawValue {
                    alert.connectionIssue()
                } else if error!.code == PFErrorCode.ErrorUsernameTaken.rawValue {
                    alert.accountExistsAlready()
                }
            } else {
                StoryboardManager.segueMain(self)
            }
        }
    }
}
