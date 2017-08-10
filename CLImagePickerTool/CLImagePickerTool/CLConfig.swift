//
//  Config.swift
//  ImageDeal
//
//  Created by darren on 2017/7/27.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

/* 屏幕宽度 */
let KScreenWidth  = UIScreen.main.bounds.width
/* 屏幕高度 */
let KScreenHeight = UIScreen.main.bounds.height

func CoustomColor(_ r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
}

let CLNotificationCenter =  NotificationCenter.default

// cell的宽度
var cellH = (KScreenWidth-15)/4.0

// asset标识数据库
let CLChooseImageAssetLocalIdentifierKey = "CLChooseImageAssetLocalIdentifierKey"
// 更新列表的通知
let CLPhotoListRefreshNotic = "CLPhotoListRefreshNotic"
// 选择的最大图片数量
let CLImagePickerMaxImagesCount = "CLImagePickerMaxImagesCount"
// 是够允许选择视频的key
let CLIsHiddenVideo = "CLIsHiddenVideo"
// 用户第一次选择的类型
let UserChooserType = "UserChooserType"
// 用户选择了图片，更新控制器的数据源，将视频全部置灰
let OnlyChooseImageOrVideoNotic = "OnlyChooseImageOrVideoNotic"
// 用户全部取消后，更新数据源为最初状态
let OnlyChooseImageOrVideoNoticCencel = "OnlyChooseImageOrVideoNoticCencel"

// MARK:- 设置圆角
func CLViewsBorder(_ view:UIView, borderWidth:CGFloat, borderColor:UIColor?=nil,cornerRadius:CGFloat){
    view.layer.borderWidth = borderWidth;
    view.layer.borderColor = borderColor?.cgColor
    view.layer.cornerRadius = cornerRadius
    view.layer.masksToBounds = true
}

// 主题色
let mainColor = CoustomColor(85, g: 182, b: 55, a: 1)

extension UIView {
        
    /// x
    var cl_x: CGFloat {
        get {
            return frame.origin.x
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.x    = newValue
            frame                 = tempFrame
        }
    }
    
    /// y
    var cl_y: CGFloat {
        get {
            return frame.origin.y
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.y    = newValue
            frame                 = tempFrame
        }
    }
    
    /// height
    var cl_height: CGFloat {
        get {
            return frame.size.height
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size.height = newValue
            frame                 = tempFrame
        }
    }
    
    /// width
    var cl_width: CGFloat {
        get {
            return frame.size.width
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size.width = newValue
            frame = tempFrame
        }
    }
    
    /// size
    var cl_size: CGSize {
        get {
            return frame.size
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size = newValue
            frame = tempFrame
        }
    }
    
    /// centerX
    var cl_centerX: CGFloat {
        get {
            return center.x
        }
        set(newValue) {
            var tempCenter: CGPoint = center
            tempCenter.x = newValue
            center = tempCenter
        }
    }
    
    /// centerY
    var cl_centerY: CGFloat {
        get {
            return center.y
        }
        set(newValue) {
            var tempCenter: CGPoint = center
            tempCenter.y = newValue
            center = tempCenter;
        }
    }
    
}
