//
//  PreviewModel.swift
//  CLImagePickerTool
//
//  Created by darren on 2017/8/9.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import Photos
import PhotosUI


class PreviewModel: NSObject {

    var phAsset: PHAsset?
    var downLoadProgress: CGFloat = 100  // 默认100
    var index: Int = 0
    var isCheck = true
}
