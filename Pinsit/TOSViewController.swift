//
//  TOSViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 1/15/15.
//  Copyright (c) 2015 Walker Christie. All rights reserved.
//

import UIKit
import Parse

class TOSViewController: UIViewController {
    @IBOutlet var textView: UITextView!
    @IBOutlet var backButton: UIBarButtonItem!
    private var showingTOS = true
    var identifier = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.editable = false
        textView.attributedText = loadPolicyFile("tos")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationController?.navigationBarHidden = false
    }
    
    @IBAction func togglePolicy(sender: UIBarButtonItem) {
        if showingTOS == true {
            textView.attributedText = loadPolicyFile("privacy")
            navigationController?.navigationBar.topItem?.title = "Privacy Policy"
            sender.title = "Terms of Service"
            
            showingTOS = false
        } else {
            textView.attributedText = loadPolicyFile("tos")
            navigationController?.navigationBar.topItem?.title = "Terms of Service"
            sender.title = "Privacy Policy"
            
            showingTOS = true
        }
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier(identifier, sender: self)
    }
    
    func loadPolicyFile(name: String) -> NSAttributedString {
        do {
            let rtf = NSBundle.mainBundle().URLForResource(name, withExtension: "rtf")
            return try NSAttributedString(fileURL: rtf!, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil)
        } catch {
            print("Could not load Terms of Service")
        }
        
        return NSAttributedString()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}