//
//  Image.swift
//  Pinsit
//
//  Created by Walker Christie on 9/22/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class Image {
    func generateThumbnail() -> UIImage {
        let asset = AVURLAsset(URL: self.videoPath(), options: nil)
        let ima = AVAssetImageGenerator(asset: asset)
        ima.appliesPreferredTrackTransform = true
        
        let time = CMTimeMake(0, 60)
        let imgRef: CGImage!
        do {
            imgRef = try ima.copyCGImageAtTime(time, actualTime: nil)
        } catch let error as NSError {
            print("Error generating thumbnail\n \(error.localizedDescription)")
            imgRef = nil
        }
        
        return self.resizeImg(imgRef, size: 30)
    }
    
    func generateVideoImage() -> UIImage {
        let asset = AVURLAsset(URL: self.videoPath(), options: nil)
        let ima = AVAssetImageGenerator(asset: asset)
        ima.appliesPreferredTrackTransform = true
        
        let time = CMTimeMake(0, 60)
        let imgRef: CGImage!
        do {
            imgRef = try ima.copyCGImageAtTime(time, actualTime: nil)
        } catch let error as NSError {
            print("Error generating video image\n \(error.localizedDescription)")
            imgRef = nil
        }
        
        return self.resizeImg(imgRef, size: 600)
    }
    
    private func resizeImg(imgRef: CGImageRef, size: Int32) -> UIImage {
        let image = UIImage(CGImage: imgRef)
        let rect = CGRectMake(0, 0, CGFloat(size), CGFloat(size))
    
        UIGraphicsBeginImageContext(rect.size)
        image.drawInRect(rect)
        let sizedImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imgData = UIImagePNGRepresentation(sizedImg)
        let finalImg = UIImage(data: imgData!)
        
        return finalImg!
    }
    
    func videoPath() -> NSURL {
        let videoInput = NSTemporaryDirectory() + "output.mov"
        let videoURL = NSURL.fileURLWithPath(videoInput)
        
        return videoURL
    }
}

extension UIImage {
    func resize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        
        let rect = CGRectMake(0, 0, size.width, size.height)
        
        self.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
}