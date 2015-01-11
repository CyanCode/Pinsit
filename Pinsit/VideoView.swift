//
//  VideoView.swift
//  Pinsit
//
//  Created by Walker Christie on 10/2/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation

class VideoView {
    var spinner: UIActivityIndicatorView!
    var view: UIView
    
    init(view: UIView) {
        self.view = view
    }
    
    func createSpinner() {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        var frame = spinner.frame
        
        frame.origin.x = view.frame.size.width / 2 - frame.size.width / 2
        frame.origin.y = view.frame.size.height / 2 - frame.size.height / 2
        spinner.frame = frame
        
        spinner.startAnimating()
        view.addSubview(spinner)
    }
}