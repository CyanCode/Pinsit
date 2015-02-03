//
//  DetailsViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 12/20/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController, UIGestureRecognizerDelegate, UITextViewDelegate {
    @IBOutlet var downloadToggle: UISwitch!
    @IBOutlet var descriptionView: UITextView!
    @IBOutlet var map: MKMapView!
    
    var thumbnail: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionView.delegate = self
        addGesture()
        fillerText()
        setupSwitches()
        
        let img = Image()
        thumbnail = img.generateThumbnail()
    }
    
    override func viewDidAppear(animated: Bool) {
        AppDelegate.loginCheck(self)
    }

    var zoom: ZoomMap!
    var effect: UIVisualEffectView!
    override func viewDidLayoutSubviews() {
        if zoom == nil {
            zoom = ZoomMap(map: map, covered: false)
            zoom.zoomToCurrentLocation()
        }
        
        if effect == nil {
            effect = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
            effect.frame = map.bounds
            map.insertSubview(effect, aboveSubview: map)
        }
    }
    
    private func setupSwitches() {
        let fm = File()
        
        downloadToggle.enabled = fm.isUpgraded()
        downloadToggle.onTintColor = UIColor(string: "#FF2851")
    }
    
    private func pullTags() -> [String] {
        let words = descriptionView.text.componentsSeparatedByString(" ")
        var tags = [String]()
        
        for word in words {
            if word.hasPrefix("#") && countElements(word) > 1 {
                tags.append(dropFirst(word))
            }
        }
        
        return tags
    }
    
    var descriptionSet: Bool!
    private func fillerText() {
//        downloadingLabel.strokeColor = UIColor.whiteColor()
//        downloadingLabel.strokeSize = 0.5
        descriptionView.textColor = UIColor.grayColor()
        descriptionView.text = "Try adding a description!"
        descriptionSet = false
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if descriptionSet == false {
            descriptionView.text = ""
            descriptionView.textColor = UIColor.whiteColor()
            descriptionSet = true
        }
    }
    
    //MARK: Action
    @IBAction func postButton(sender: AnyObject) {
        if descriptionSet == false {
            descriptionView.text = ""
            
            PAnnotation.constructAnnotation(self)
        } else {
            PAnnotation.constructAnnotation(self)
        }
    }

//    @IBAction func switchTapped(sender: AnyObject) {
//        if downloadToggle.enabled == false {
//            let action = UIAlertController(title: "Not so fast!", message: "In order to disable video downloading, you must have an upgraded Pinsit account!", preferredStyle: .ActionSheet)
//            let cancel = UIAlertAction(title: "Okay", style: .Cancel, handler: nil)
//            
//            action.addAction(cancel)
//            self.presentViewController(action, animated: true, completion: nil)
//        }
//    }
    
    //MARK: Toggle Menu
    func addGesture() {
        var edge = UIScreenEdgePanGestureRecognizer(target: self, action: "toggleMenu:")
        edge.edges = UIRectEdge.Right
        edge.delegate = self
        self.view.addGestureRecognizer(edge)
    }
    
    func toggleMenu(sender: UIGestureRecognizer) {
        let control = tabBarController
        (tabBarController as SidebarController).sidebar.showInViewController(self, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
