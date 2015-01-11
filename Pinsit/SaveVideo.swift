//
//  DownloadVideo.swift
//  Pinsit
//
//  Created by Walker Christie on 10/7/14.
//  Copyright (c) 2014 Walker Christie. All rights reserved.
//

import Foundation

class SaveVideo {
    var vidURL: NSURL?
    var error: NSError?
    
    init(vidURL: NSURL) {
        self.vidURL = vidURL
    }
    
    func saveToAlbums() -> NSError? {
        let err = PError()
        let error = err.constructErrorWithCode(PError.ErrorCode.PVideoSaveError.rawValue)
        
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(vidURL?.path) {
            let path = vidURL?.path
            UISaveVideoAtPathToSavedPhotosAlbum(path, nil, nil, nil)

            return nil
        } else {
            return error
        }
    }
}