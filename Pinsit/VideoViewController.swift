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
    @IBOutlet var videoView: UIView!
    @IBOutlet var switchCamBtn: UIButton!
    @IBOutlet var recordBtn: UIButton!
    @IBOutlet var torchBtn: UIButton!
    @IBOutlet var loadingActivity: UIActivityIndicatorView!
    @IBOutlet var videoProgress: UIProgressView!
    
    var videoManager: Media!
    var play: Playback!
    var time: TimeKeeper!
    var recordingTime: NSTimer!
    var recording: Bool!
    var recordingFinished: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGesture()
        recordingLongPress()
        recordingTime = NSTimer(timeInterval: 0.1, target: self, selector: "timeFired:", userInfo: nil, repeats: true)
        time = TimeKeeper(progress: videoProgress, responder: self)
        recordingFinished = false
    }
    
    var mapManage: ZoomMap!
    override func viewWillAppear(animated: Bool) {
//        if (mapManage == nil) {
//            mapManage = ZoomMap(map: map, covered: false)
//        }
//        
//        mapManage.zoomToCurrentLocation()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.videoManager = Media(resView: self.videoView)
            self.videoManager.toggleLoading(self.loadingActivity, enable: true)
            self.videoManager.view = self.videoView
            self.videoManager.createPreview()
            self.videoManager.toggleLoading(self.loadingActivity, enable: false)
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.videoManager.video.endSession()
            self.videoManager.removeLayers()
        })
    }
    
    var effect: UIVisualEffectView!
    override func viewDidAppear(animated: Bool) {
//        if effect == nil {
//            effect = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
//            effect.frame = map.bounds
//            
//            map.insertSubview(effect, aboveSubview: map)
//        }
        
        AppDelegate.loginCheck(self)
        self.view.bringSubviewToFront(recordBtn)
        self.view.bringSubviewToFront(switchCamBtn)
        self.view.bringSubviewToFront(torchBtn)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Button Actions
    @IBAction func switchCam(sender: AnyObject) {
        if recordingFinished == false {
            videoManager.camera.switchCamPosition()
        }
    }
    
    var inPlaybackMode: Bool!
    func restartVideo() {
        play.deconstructPlayback()
        
        recordBtn.setImage(UIImage(named: "record-inactive.png"), forState: UIControlState.Normal)
        
        self.switchCamBtn.userInteractionEnabled = true
        self.videoProgress.setProgress(0.0, animated: true)
        self.videoManager = Media(resView: self.videoView)
        self.videoManager.toggleLoading(self.loadingActivity, enable: true)
        self.videoManager.view = self.videoView
        self.videoManager.createPreview()
        self.videoManager.toggleLoading(self.loadingActivity, enable: false)
        inPlaybackMode = false
    }
    
    @IBAction func commitVideo(sender: AnyObject) {
        if inPlaybackMode != nil && inPlaybackMode == true {
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
    
    //MARK: Long Press
    private func recordingLongPress() {
        recording = false
        let press = UILongPressGestureRecognizer(target: self, action: "handleRecordingPress:")
        recordBtn.addGestureRecognizer(press)
    }
    
    private func doneRecording() {
        println("Time is up")
        switchCamBtn.userInteractionEnabled = false
        recordBtn.setImage(UIImage(named: "check.png"), forState: UIControlState.Normal)
        videoManager.progress.endRecording()
        time.endTime()
        play = Playback(view: videoView)
        play.startPlayback()
        recordingFinished = true
        inPlaybackMode = true
    }
    
    func handleRecordingPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began && recordingFinished != true { //Start recording
            recording = true
            recordBtn.setImage(UIImage(named: "progress.png"), forState: UIControlState.Normal)
            time.startTime()
            videoManager.progress.startRecording()
            recordingFinished = false
            inPlaybackMode = false
        } else if recognizer.state == UIGestureRecognizerState.Ended && recordingFinished != true { //Finished Recording
            recording = false
            recordBtn.setImage(UIImage(named: "check.png"), forState: UIControlState.Normal)
            time.endTime()
            doneRecording()
        }
    }
    
    //MARK: Shaking
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if (recordingFinished == true) {
            var alert = UIAlertController(title: "Are you sure?", message: "Do you really want to delete your masterpiece?", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: { action in
                println("Deletion Cancelled")
            }))
            
            alert.addAction(UIAlertAction(title: "Delete It", style: .Default, handler: { action in
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
    
    func togglePlayback(tap: UITapGestureRecognizer) {
        if (recordingFinished == true) {
            if (play.playing == true && play.donePlaying == false) { //Playing, pause
                play.pausePlayback()
            } else if (play.playing == false && play.donePlaying == false){ //Paused, unpause
                play.startPlayback()
            } else if (play.donePlaying == true) { //Stopped, restart
                play.startPlayback()
            }
        }
    }
    
    //MARK: Times up
    @objc func timeUp(notification: NSNotification) {
        recording = false
        recordBtn.setImage(UIImage(named: "check.png"), forState: UIControlState.Normal)
        time.endTime()
        doneRecording()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
