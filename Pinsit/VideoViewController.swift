//
//  VideoViewController.swift
//  Pinsit
//
//  Created by Walker Christie on 10/13/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import UIKit
import MapKit

class VideoViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var videoView: RecordingView!
    @IBOutlet var switchCamBtn: UIButton!
    @IBOutlet var recordBtn: UIButton!
    @IBOutlet var torchBtn: UIButton!
    @IBOutlet var loadingActivity: UIActivityIndicatorView!
    @IBOutlet var videoProgress: UIProgressView!
    
    var time: TimeKeeper!
    var recordingTime: NSTimer!
    var recording: Bool!
    var recordingFinished: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.loginCheck(self)

        addGesture()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button Actions
    @IBAction func switchCam(sender: AnyObject) {
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
    
    @IBAction func commitVideo(sender: AnyObject) {
        if videoView.recStatus == .READY {
            let setDetails = UIView.detailViewFromNib()
            setDetails.presentViewInController(self, popupPoint: CGPointMake(recordBtn.center.x, recordBtn.center.y + 23))
            
            //self.performSegueWithIdentifier("detail", sender: self)
        }
    }
    
    @IBAction func toggleTorch(sender: AnyObject) {
        if inPlaybackMode == nil || inPlaybackMode == false {
            CameraManager.toggleTorch()
        }
    }
    
    private func doneRecording() {
        switchCamBtn.userInteractionEnabled = false
        changeVideoState(VideoState.DONE)
        
        videoView.endRecordingSession()
        time.endTime()
    }
    
    var isRecording: Bool = false
    @IBAction func handleRecordingTap(recognizer: UITapGestureRecognizer) {
        if videoView.recStatus != .READY && videoView.recStatus != .RECORDING { //Start recording
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
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if (videoView.recStatus == .DONE_RECORDING || videoView.recStatus == .READY) {
            var alert = UIAlertController(title: "Are you sure?", message: "Do you really want to delete your masterpiece?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: { action in
                println("Deletion Cancelled")
            })); alert.addAction(UIAlertAction(title: "Delete It", style: .Default, handler: { action in
                self.restartVideo()
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    //MARK: Toggle Video Playback
    func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: "togglePlayback:")
        videoView.addGestureRecognizer(tap)
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
        case .READY: recordBtn.setImage(UIImage(named: "record-inactive.png"), forState: .Normal)
        case .RECORDING: recordBtn.setImage(UIImage(named: "progress.png"), forState: .Normal)
        case .DONE: recordBtn.setImage(UIImage(named: "check.png"), forState: .Normal)
        }
    }
    
    enum VideoState {
        case READY
        case RECORDING
        case DONE
    }
}
