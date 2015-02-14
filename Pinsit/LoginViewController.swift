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
        let button = sender as UIButton
        
        button.enabled = false
        PFUser.logInWithUsernameInBackground(usernameField.text, password: passwordField.text) { (user, error) -> Void in
            button.enabled = true
            if error != nil {
                let alert = UIAlertController(title: "Oops", message: "Double check your username and password, make sure you are connected to the internet", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
                alert.addAction(cancel)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                StoryboardManager.segueMain(self)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
