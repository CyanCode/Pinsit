//
//  NewRecordingViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 8/4/15.
//  Copyright © 2015 Walker Christie. All rights reserved.
//

import UIKit
import AVFoundation

class NewRecordingViewController: UIViewController {
    @IBOutlet var deleteRecordingButton: ToolbarButton!
    @IBOutlet var flipCameraButton: ToolbarButton!
    @IBOutlet var toggleTorchButton: ToolbarButton!
    @IBOutlet var recordingButton: RecordingButton!
    @IBOutlet var recordingProgress: RecordingProgressView!
    
    @IBOutlet var recordingView: RecordVideoView!
    @IBOutlet var playbackView: PlaybackRecordingView!
    
    var status: RecordingViewStatus = .Inactive {
        didSet {
            switch status {
            case .Recording:
                deleteRecordingButton.enabled = false
                flipCameraButton.enabled = false
                toggleTorchButton.enabled = true
                recordingButton.selected = true
                recordingButton.displayCheck = false
            case .Playback:
                deleteRecordingButton.enabled = true
                flipCameraButton.enabled = false
                toggleTorchButton.enabled = false
                recordingButton.selected = false
                recordingButton.displayCheck = true
            case .Inactive:
                deleteRecordingButton.enabled = false
                flipCameraButton.enabled = true
                toggleTorchButton.enabled = true
                recordingButton.selected = false
                recordingButton.displayCheck = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteRecordingButton.imageTintColor = UIColor.whiteColor()
        flipCameraButton.imageTintColor = UIColor.whiteColor()
        toggleTorchButton.imageTintColor = UIColor.whiteColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        status = .Inactive
        if status == .Playback { playbackView.playbackRecordedVideo() }
        if status == .Inactive {
            recordingView.recording.startSession({ () -> Void in
                self.recordingView.startCameraPreview()
            })
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if status == .Playback { playbackView.endPlayback() }
        if status == .Inactive {
            recordingView.stopCameraPreview()
            recordingView.recording.endSession()
        }
    }
    
    func setActiveView(active: ActiveView) {
        if active == .Recording {
            recordingView.hidden = false
            playbackView.hidden = true
        } else {
            recordingView.hidden = true
            playbackView.hidden = false
        }
    }
    
    @IBAction func deleteRecordingPressed(sender: AnyObject) {
        let controller = UIAlertController(title: "Are you sure..?", message: "Are you sure you want to delete your masterpiece?", preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Delete It", style: .Default, handler: { (action) -> Void in
            self.recordingProgress.setProgress(0.0, animated: true)
            self.setActiveView(.Recording)
            self.playbackView.endPlayback()
            self.recordingView.startCameraPreview()
            self.status = .Inactive
            self.deleteRecordingButton.enabled = false
        }))
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func flipCameraPressed(sender: AnyObject) {
        recordingView.recording.switchCamera()
    }
    
    @IBAction func toggleTorchPressed(sender: AnyObject) {
        if recordingView.recording.videoDevice.position == AVCaptureDevicePosition.Back {
            recordingView.recording.toggleTorch()
        }
    }
    
    @IBAction func recordingPressed(sender: AnyObject) {
        if status == .Inactive {
            status = .Recording
            recordingView.startRecording()
            
            recordingProgress.startAnimatingToMax { () -> Void in
                self.stopRecording()
            }
        } else if status == .Recording {
            recordingProgress.stopTrackingTime()
            stopRecording()
            recordingButton.displayCheck = true
        } else {
            let detailView = UIView.detailViewFromNib()
            detailView.presentViewInController(self, popupPoint: CGPointMake(recordingButton.center.x, recordingButton.center.y + 23))
        }
    }
    
    private func stopRecording() {
        self.status = .Playback
        self.setActiveView(.Playback)
        self.recordingView.stopRecording({ () -> Void in
            self.recordingView.stopCameraPreview()
            self.playbackView.playbackRecordedVideo()
        })
    }
}

enum RecordingViewStatus {
    case Recording
    case Playback
    case Inactive
}

enum ActiveView {
    case Recording
    case Playback
}

@IBDesignable class RecordingButton: UIButton {
    @IBInspectable override var backgroundColor: UIColor? { didSet {} }
    @IBInspectable var selectedBorderColor: UIColor = UIColor.blackColor() { didSet {} }
    @IBInspectable var unselectedBorderColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.layer.borderColor = unselectedBorderColor.CGColor
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var displayCheck: Bool = false {
        didSet {
            if displayCheck {
                let img = UIImage(named: "check")?.imageWithRenderingMode(.AlwaysTemplate)
                self.setImage(img, forState: .Normal)
                self.imageView!.tintColor = UIColor.whiteColor()
                self.tintColor = UIColor.whiteColor()
                self.imageView!.hidden = false
            } else {
                self.imageView?.image = UIImage()
                self.setImage(UIImage(), forState: .Normal)
                self.imageView!.hidden = true
            }
        }
    }
    
    override var selected: Bool {
        didSet {
            if selected {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.layer.borderColor = self.selectedBorderColor.CGColor
                })
            } else {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.layer.borderColor = self.unselectedBorderColor.CGColor
                })
            }
        }
    }
}

class RecordingProgressView: UIProgressView {
    typealias RecordingTimeDoneHandler = () -> Void
    var doneBlock: RecordingTimeDoneHandler!
    var currentTime = 0.0
    var maxTime = Upgrade().isUpgraded() ? 10 : 7
    var timer: NSTimer!
    
    func startAnimatingToMax(done: RecordingTimeDoneHandler) {
        self.doneBlock = done
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "timeIncrement:", userInfo: nil, repeats: true)
    }
    
    func timeIncrement(time: NSTimer) {
        currentTime += 0.1
        setProgress(Float(currentTime / Double(maxTime)), animated: true)
        
        if currentTime >= Double(maxTime) {
            time.invalidate()
            currentTime = 0
            doneBlock()
        }
    }
    
    func stopTrackingTime() {
        timer.invalidate()
        currentTime = 0
    }
}

@IBDesignable class ToolbarButton: UIButton {
    @IBInspectable var imageTintColor: UIColor = UIColor.whiteColor() {
        didSet {
            let img = self.imageView?.image?.imageWithRenderingMode(.AlwaysTemplate)
            self.setImage(img, forState: .Normal)
            self.tintColor = imageTintColor
            self.imageView?.tintColor = imageTintColor
        }
    }
}