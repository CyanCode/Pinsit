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
    var agreement: Agreement {
        didSet {
            setPolicy()
        }
    }
    var identifier = ""
    
    required init?(coder aDecoder: NSCoder) {
        self.agreement = .TOS
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.editable = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navigationController?.navigationBarHidden = false
    }
    
    private func setPolicy() {
        switch agreement {
        case .Privacy:
            textView.attributedText = loadPolicyFile("privacy")
            navigationController?.navigationBar.topItem?.title = "Privacy Policy"
        case .TOS:
            textView.attributedText = loadPolicyFile("tos")
            navigationController?.navigationBar.topItem?.title = "Terms of Service"
        }
    }
    
    @IBAction func donePressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadPolicyFile(name: String) -> NSAttributedString {
        let rtf = NSBundle.mainBundle().URLForResource(name, withExtension: "rtf")
        return try! NSAttributedString(fileURL: rtf!, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    class func loadViewFromNib() -> TOSViewController {
        return NSBundle.mainBundle().loadNibNamed("TOSView", owner: self, options: nil).first as! TOSViewController
    }
    
    class func conditionsConfirmation(message: String, vc: UIViewController) -> UIAlertController {
        let controller = UIAlertController(title: "Agreement", message: message, preferredStyle: .ActionSheet)
        controller.addAction(UIAlertAction(title: "View Privacy Policy", style: .Default, handler: { (action) -> Void in
            let view = TOSViewController.loadViewFromNib()
            view.agreement = .Privacy
            vc.presentViewController(view, animated: true, completion: nil)
        }))
        controller.addAction(UIAlertAction(title: "View Terms of Service", style: .Default, handler: { (action) -> Void in
            let view = TOSViewController.loadViewFromNib()
            view.agreement = .TOS
            vc.presentViewController(view, animated: true, completion: nil)
        }))
        controller.addAction(UIAlertAction(title: "Nevermind", style: .Default, handler: nil))
        
        return controller
    }
}

enum Agreement {
    case TOS
    case Privacy
}