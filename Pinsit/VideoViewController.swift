//
//  VideoViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 10/13/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit
import MapKit

class VideoViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var videoView: RecordingView!
    @IBOutlet var switchCamBtn: UIButton!
    @IBOutlet var recordBtn: UIButton!
    @IBOutlet var torchBtn: UIButton!
    @IBOutlet var videoProgress: UIProgressView!
    
    var time: TimeKeeper!
    var recordingTime: NSTimer!
    var recording: Bool!
    var recordingFinished: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.loginCheck(self)

        videoView.userInteractionEnabled = false
        recordingTime = NSTimer(timeInterval: 0.1, target: self, selector: "timeFired:", userInfo: nil, repeats: true)
        time = TimeKeeper(progress: videoProgress, responder: self)
        recordingFinished = false
    }
    
    var loaded: Bool = false
    override func viewDidLayoutSubviews() {
        if loaded == false {
            loaded = true
            
            videoView.createSessions({ () -> Void in
                self.videoView.previewCamera()
            })
        }
    }
    
    //MARK: Button Actions
    var isBackCam: Bool = true
    @IBAction func switchCam(sender: UIButton) {
        if isBackCam == true {
            sender.setImage(UIImage(named: "back_cam.png"), forState: .Normal)
            isBackCam = false
        } else {
            sender.setImage(UIImage(named: "front_cam.png"), forState: .Normal)
            isBackCam = true
        }
        
        if videoView.recStatus != .RECORDING {
            videoView.switchCameraPositions()
        }
    }
    
    var inPlaybackMode: Bool!
    ///Readies view for recording
    func restartVideo() {
        changeVideoState(VideoState.READY)
        self.switchCamBtn.userInteractionEnabled = true
        self.videoProgress.setProgress(0.0, animated: true)
        self.videoView.stopPlayback()
        self.videoView.previewCamera()
        self.videoView.recStatus = .NOT_STARTED
    
        inPlaybackMode = false
    }
    
    var isTorchOn: Bool = false
    @IBAction func toggleTorch(sender: AnyObject) {
        if isTorchOn == true {
            sender.setImage(UIImage(named: "torch_off.png"), forState: .Normal)
            isTorchOn = false
        } else {
            sender.setImage(UIImage(named: "torch_on.png"), forState: .Normal)
            isTorchOn = true
        }
        
        if inPlaybackMode == nil || inPlaybackMode == false {
            videoView.toggleTorch()
        }
    }
    
    private func doneRecording() {
        switchCamBtn.userInteractionEnabled = false
        changeVideoState(VideoState.DONE)
        
        toggleSwitches(false)
        videoView.endRecordingSession()
        time.endTime()
    }
    
    private func toggleSwitches(enable: Bool) {
        switchCamBtn.hidden = !enable
        torchBtn.hidden = !enable
        
        switchCamBtn.enabled = enable
        torchBtn.enabled = enable
    }
    
    var isRecording: Bool = false
    @IBAction func handleRecordingTap(recognizer: UITapGestureRecognizer) {
        if videoView.recStatus == .READY {
            let setDetails = UIView.detailViewFromNib()
            setDetails.presentViewInController(self, popupPoint: CGPointMake(recordBtn.center.x, recordBtn.center.y + 23))
            
            //self.performSegueWithIdentifier("detail", sender: self)
        }; if videoView.recStatus != .READY && videoView.recStatus != .RECORDING { //Start recording
            isRecording = true
            
            time.startTime()
            videoView.stopPlayback()
            videoView.startRecordingVideo(nil)
            
            changeVideoState(VideoState.RECORDING)
        } else if videoView.recStatus == .RECORDING { //End recording
            isRecording = false
            self.doneRecording()
        }
    }
    
    //MARK: Shaking
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if (videoView.recStatus == .DONE_RECORDING || videoView.recStatus == .READY) {
            let alert = UIAlertController(title: "Are you sure?", message: "Do you really want to delete your masterpiece?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: { action in
                print("Deletion Cancelled")
            })); alert.addAction(UIAlertAction(title: "Delete It", style: .Default, handler: { action in
                self.toggleSwitches(true)
                self.restartVideo()
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //MARK: Times up
    @objc func timeUp(notification: NSNotification) {
        recording = false
        changeVideoState(VideoState.DONE)
        time.endTime()
        doneRecording()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    private func changeVideoState(state: VideoState) {
        switch state {
        case .READY: recordBtn.setImage(UIImage(named: "record_inactive.png"), forState: .Normal)
        case .RECORDING: recordBtn.setImage(UIImage(named: "record_active.png"), forState: .Normal)
        case .DONE: recordBtn.setImage(UIImage(named: "check.png"), forState: .Normal)
        }
    }
    
    enum VideoState {
        case READY
        case RECORDING
        case DONE
    }
}
