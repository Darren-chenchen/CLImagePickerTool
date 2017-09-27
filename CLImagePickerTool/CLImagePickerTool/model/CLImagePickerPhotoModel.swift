//
//  CLImagePickerPhotoModel.swift
//  ImageDeal
//
//  Created by darren on 2017/7/31.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class CLImagePickerPhotoModel: NSObject {

    @objc var phAsset: PHAsset? {
        didSet{
            if self.phAsset?.mediaType == .video {
                if self.phAsset?.duration == nil {
                    self.videoLength = ""
                } else {
                    self.videoLength = self.getNewTimeFromDurationSecond(duration: (self.phAsset?.duration)!)
                }
            }
        }
    }
    var isSelect: Bool? = false
    @objc var videoLength: String?
    @objc var progressValue: CGFloat = 0
    
    @objc var pictureImg: UIImage?
    
    // 在用户配置了onlyChooseImageOrVideo的情况下，如果模型中的onlyChooseImageOrVideo为true，那么就显示alpha,
    @objc var onlyChooseImageOrVideo: Bool = false
    
    @objc func getNewTimeFromDurationSecond(duration:Double) -> String{
        
        var newTimer = ""
        if duration < 10 {
            newTimer = String(format: "0:0%d", arguments: [Int(duration)])
            return newTimer
        } else if duration < 60 && duration >= 10 {
            newTimer = String(format: "0:%.0f", arguments: [duration])
            return newTimer
        } else {
            let min = Int(duration/60)
            let sec = Int(duration - (Double(min)*60))
            if sec < 10 {
                newTimer = String(format: "%d:0%d", arguments: [min ,sec])
                return newTimer
            } else {
                newTimer = String(format: "%d:%d", arguments: [min ,sec])
                return newTimer
            }
        }
    }
    
}
