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

 let CLWindow = UIApplication.shared.keyWindow

//导航栏高度
let KNavgationBarHeight: CGFloat = UIDevice.current.isX() == true ? 88.0:64.0
//tabbar高度
let KTabBarHeight: CGFloat = UIDevice.current.isX() == true ? 83.0:49.0

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
// 预览界面设置选中与取消，通知列表界面刷新
let PreviewForSelectOrNotSelectedNotic = "PreviewForSelectOrNotSelectedNotic"

// MARK:- 设置圆角
func CLViewsBorder(_ view:UIView, borderWidth:CGFloat, borderColor:UIColor?=nil,cornerRadius:CGFloat){
    view.layer.borderWidth = borderWidth;
    view.layer.borderColor = borderColor?.cgColor
    view.layer.cornerRadius = cornerRadius
    view.layer.masksToBounds = true
}

// 主题色
var mainColor = CoustomColor(85, g: 182, b: 55, a: 1)


// 所有照片的可能情况
let allPhoto = "所有照片"
let allPhoto2 = "All Photos"
let allPhoto3 = "Camera Roll"
let allPhoto4 = "相机胶卷"
let allPhoto5 = "最近项目"

// 本地化
let sureStr = BundleUtil.cl_localizedStringForKey(key: "确定")
let resetStr = BundleUtil.cl_localizedStringForKey(key: "重置")
let previewStr = BundleUtil.cl_localizedStringForKey(key: "预览")
let cancelStr = BundleUtil.cl_localizedStringForKey(key: "取消")
let photoStr = BundleUtil.cl_localizedStringForKey(key: "相册")
let errorStr = BundleUtil.cl_localizedStringForKey(key: "错误")
let editorStr = BundleUtil.cl_localizedStringForKey(key: "编辑")
let playErrorStr = BundleUtil.cl_localizedStringForKey(key: "播放出错")
let maxPhotoCountStr = BundleUtil.cl_localizedStringForKey(key: "您最多只能选择%zd张照片")
let knowStr = BundleUtil.cl_localizedStringForKey(key: "知道了")
let imageAndVideoOnlyOneStr = BundleUtil.cl_localizedStringForKey(key: "视频文件和图片文件只能选择1种")

let graffitiStr = BundleUtil.cl_localizedStringForKey(key: "涂鸦")
let eraserStr = BundleUtil.cl_localizedStringForKey(key: "橡皮擦")
let mosaicStr = BundleUtil.cl_localizedStringForKey(key: "马赛克")
let undoStr = BundleUtil.cl_localizedStringForKey(key: "上一步")
let redoStr = BundleUtil.cl_localizedStringForKey(key: "下一步")

let photoLimitStr = BundleUtil.cl_localizedStringForKey(key: "照片访问受限")
let clickSetStr = BundleUtil.cl_localizedStringForKey(key: "点击“设置”，允许访问您的照片")
let setStr = BundleUtil.cl_localizedStringForKey(key: "设置")

let cameraLimitStr = BundleUtil.cl_localizedStringForKey(key: "相机访问受限")
let clickCameraStr = BundleUtil.cl_localizedStringForKey(key: "点击“设置”，允许访问您的相机")

let tackPhotoStr = BundleUtil.cl_localizedStringForKey(key: "拍照")
let chooseStr = BundleUtil.cl_localizedStringForKey(key: "从手机相册选择")

let favStr = BundleUtil.cl_localizedStringForKey(key: "收藏")
let videoStr = BundleUtil.cl_localizedStringForKey(key: "视频")
let allPStr = BundleUtil.cl_localizedStringForKey(key: "所有照片")
let rencentStr = BundleUtil.cl_localizedStringForKey(key: "最近添加")
let shotStr = BundleUtil.cl_localizedStringForKey(key: "屏幕快照")
let selfStr = BundleUtil.cl_localizedStringForKey(key: "自拍")
let delectStr = BundleUtil.cl_localizedStringForKey(key: "最近删除")

