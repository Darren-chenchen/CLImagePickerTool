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

    @objc var phAsset: PHAsset?
    @objc var downLoadProgress: CGFloat = 100  // 默认100
    @objc var index: Int = 0
    @objc var isCheck = true
}
