//
//  CLImageAmplifyView.swift
//  relex_swift
//
//  Created by darren on 17/1/5.
//  Copyright © 2017年 darren. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import ImageIO
import QuartzCore

typealias singlePictureClickSureBtnClouse = ()->()
typealias singlePictureClickEditorBtnClouse = ()->()

class CLImageAmplifyView: UIView {
    
    private var imageArr: Array<CGImage> = [] // 图片数组（存放每一帧的图片）
    private var timeArr: Array<NSNumber> = [] // 时间数组 (存放每一帧的图片的时间)
    private var totalTime: Float = 0 // gif 动画时间
    
    @objc var lastImageView: UIImageView!
    var originalFrame:CGRect!
    @objc var scrollView: UIScrollView?
    @objc var circleBtn: CLCircleView?
    
    @objc let manager = PHImageManager.default()
    var imageRequestID: PHImageRequestID?
    
    // 单选模式下图片是否可以编辑
    @objc var singleModelImageCanEditor: Bool = false
    
    @objc var singlePictureClickSureBtn: singlePictureClickSureBtnClouse?
    @objc var singlePictureClickEditorBtn: singlePictureClickEditorBtnClouse?

    @objc lazy var bottomView: UIView = {
        
        let viewH: CGFloat = UIDevice.current.isX() == true ? 44+34:44
        let bottom = UIView.init(frame: CGRect(x: 0, y: KScreenHeight-viewH, width: KScreenWidth, height: viewH))
        bottom.backgroundColor = UIColor(white: 0, alpha: 0.8)
        let btn = UIButton.init(frame: CGRect(x: KScreenWidth-80, y: 0, width: 80, height: 44))
        btn.setTitle(sureStr, for: .normal)
        btn.setTitleColor(mainColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        bottom.addSubview(btn)
        btn.addTarget(self, action: #selector(clickSureBtn), for: .touchUpInside)
        
        // 编辑按钮
        if self.singleModelImageCanEditor == true {
            let btnEditor = UIButton.init(frame: CGRect(x: 0, y: 0, width: 80, height: 44))
            btnEditor.setTitle(editorStr, for: .normal)
            btnEditor.setTitleColor(mainColor, for: .normal)
            btnEditor.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            bottom.addSubview(btnEditor)
            btnEditor.addTarget(self, action: #selector(clickEditorBtn), for: .touchUpInside)
        }
        return bottom
    }()
    
    @objc static func setupAmplifyViewWithUITapGestureRecognizer(tap:UITapGestureRecognizer,superView:UIView,originImageAsset:PHAsset,isSingleChoose:Bool,singleModelImageCanEditor:Bool) -> CLImageAmplifyView{
        
        let amplifyView = CLImageAmplifyView.init(frame: (UIApplication.shared.keyWindow?.bounds)!)
        
        amplifyView.setupUIWithUITapGestureRecognizer(tap: tap, superView: superView,originImageAsset:originImageAsset,isSingleChoose:isSingleChoose,singleModelImageCanEditor:singleModelImageCanEditor)
        
        UIApplication.shared.keyWindow?.addSubview(amplifyView)
        
        return amplifyView
    }
    
    private func setupUIWithUITapGestureRecognizer(tap:UITapGestureRecognizer,superView:UIView,originImageAsset: PHAsset,isSingleChoose:Bool,singleModelImageCanEditor:Bool) {
        
        self.singleModelImageCanEditor = singleModelImageCanEditor
        
        //scrollView作为背景
        self.scrollView = UIScrollView()
        self.scrollView?.frame = (UIApplication.shared.keyWindow?.bounds)!
        self.scrollView?.backgroundColor = UIColor.black
        
        self.scrollView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.clickBgView(tapBgView:))))
        
        // 点击的图片
        let picView = tap.view
        
        self.lastImageView = UIImageView()
        self.lastImageView?.image = (tap.view as! UIImageView).image
        self.lastImageView?.frame = (self.scrollView?.convert((picView?.frame)!, from: superView))!
        self.scrollView?.addSubview((self.lastImageView)!)
        
        self.addSubview(self.scrollView!)
        CLPickersTools.instence.getAssetOrigin(asset: originImageAsset) { (img, info) in
            if img != nil {
                // 等界面加载出来再复制，放置卡顿效果
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    self.lastImageView?.image = img!
                    
                    self.dealGif(info: info,originImageAsset:originImageAsset)
                }
            } else {  // 说明本地没有需要到iCloud下载
                
                self.circleBtn = CLCircleView.init(frame: CGRect(x: (self.lastImageView?.cl_width)!-40, y: (self.cl_height)-80, width: 30, height: 30))
                self.addSubview(self.circleBtn!)
                
                let option = PHImageRequestOptions()
                option.isNetworkAccessAllowed = true
                
                option.progressHandler = {
                (progress, error, stop, info) in
                    DispatchQueue.main.async(execute: {
                        print(progress, info ?? "0000",error ?? "error")
                        if progress*100 < 10 {
                            self.circleBtn?.value = 10
                        } else {
                            self.circleBtn?.value = CGFloat(progress*100)
                        }
                    })
                }
                
                self.imageRequestID = self.manager.requestImageData(for: originImageAsset, options: option, resultHandler: { (imageData, string, imageOrientation, info) in
                    if imageData != nil {
                        self.lastImageView?.image = UIImage.init(data: imageData!)
                        self.circleBtn?.removeFromSuperview()
                        self.circleBtn = nil
                        
                        self.dealGif(info: info,originImageAsset:originImageAsset)
                    }
                })
            }
        }
        
        self.originalFrame = self.lastImageView?.frame
        
        //最大放大比例
        self.scrollView?.maximumZoomScale = 1.5;
        self.scrollView?.delegate = self
        
        UIView.animate(withDuration: 0.5) {
            var frameImg = self.lastImageView?.frame
            frameImg?.size.width = (self.scrollView?.cl_width)!
            let bili = (self.lastImageView.image?.size.height)! / (self.lastImageView.image?.size.width)!
            let h =  (frameImg?.size.width)! * bili
            frameImg?.size.height = h
            frameImg?.origin.x = 0
            frameImg?.origin.y = ((self.scrollView?.frame.size.height)! - (h)) * 0.5
            self.lastImageView?.frame = frameImg!

            if (frameImg?.size.height)! > UIScreen.main.bounds.height {
                frameImg?.origin.y = 0
                self.lastImageView?.frame = frameImg!
                self.scrollView?.contentSize = CGSize(width: 0, height: (frameImg?.size.height)!)
            }
        }
        
        if isSingleChoose {   // 单选
            self.setupBottomView()
        }
    }
    
    
     @objc func clickBgView(tapBgView:UITapGestureRecognizer){
        
        self.bottomView.removeFromSuperview()
        
        self.scrollView?.contentOffset = CGPoint(x: 0, y: 0)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.lastImageView?.frame = self.originalFrame
            self.lastImageView?.contentMode = .scaleAspectFill
            self.lastImageView?.layer.masksToBounds = true
            
            tapBgView.view?.backgroundColor = UIColor.clear
            self.circleBtn?.removeFromSuperview()
            self.circleBtn = nil
            
            if self.imageRequestID != nil {
                self.manager.cancelImageRequest(self.imageRequestID!)
            }
            
        }) { (true:Bool) in
            tapBgView.view?.removeFromSuperview()
            self.imageRequestID = nil
            self.lastImageView?.removeFromSuperview()
            self.lastImageView = nil
            self.scrollView?.removeFromSuperview()
            self.scrollView = nil
            self.removeFromSuperview()
        }
    }
    
    @objc func setupBottomView() {
        self.addSubview(self.bottomView)
    }
    
    @objc func clickSureBtn() {
        
        if self.singlePictureClickSureBtn != nil {
            self.singlePictureClickSureBtn!()
        }
        
        self.lastImageView?.removeFromSuperview()
        self.lastImageView = nil
        self.scrollView?.removeFromSuperview()
        self.scrollView = nil
        self.removeFromSuperview()
        
        if self.imageRequestID != nil {
            self.manager.cancelImageRequest(self.imageRequestID!)
            self.imageRequestID = nil
        }
    }
    
    // 编辑图片
    @objc func clickEditorBtn() {
        if self.singlePictureClickEditorBtn != nil {
            self.singlePictureClickEditorBtn!()
        }
        
        self.lastImageView?.removeFromSuperview()
        self.lastImageView = nil
        self.scrollView?.removeFromSuperview()
        self.scrollView = nil
        self.removeFromSuperview()
        
        if self.imageRequestID != nil {
            self.manager.cancelImageRequest(self.imageRequestID!)
            self.imageRequestID = nil
        }
    }
}

//返回可缩放的视图
extension CLImageAmplifyView:UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.lastImageView
    }
}

extension CLImageAmplifyView: CAAnimationDelegate {
    func dealGif(info: [AnyHashable:Any]?,originImageAsset: PHAsset) {
        if info != nil {
            let url = (info!["PHImageFileURLKey"] ?? "") as? NSURL
            let urlstr  = url?.path ?? ""
            if urlstr.contains(".gif") || urlstr.contains(".GIF") {
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                self.manager.requestImageData(for: originImageAsset, options: option, resultHandler: { (gifImgData, str, imageOrientation, info) in
                    if gifImgData != nil {
                        self.createKeyFram(imgData: gifImgData!)
                    }
                })
            }
        }
    }
    // 获取GIF 图片的每一帧有关的东西 比如：每一帧的图片、每一帧图片执行的时间
    func createKeyFram(imgData: Data) {
        
        let gifSource = CGImageSourceCreateWithData(imgData as CFData, nil)
        if gifSource == nil {
            return
        }
        let imageCount = CGImageSourceGetCount(gifSource!) // 总共图片张数
        
        for i in 0..<imageCount {
            let imageRef = CGImageSourceCreateImageAtIndex(gifSource!, i, nil) // 取得每一帧的图
            self.imageArr.append(imageRef!)
            
            let sourceDict = CGImageSourceCopyPropertiesAtIndex(gifSource!, i, nil) as NSDictionary!
            let gifDict = sourceDict![String(kCGImagePropertyGIFDictionary)] as! NSDictionary?
            let time = gifDict![String(kCGImagePropertyGIFUnclampedDelayTime)] as! NSNumber // 每一帧的动画时间
            self.timeArr.append(time)
            self.totalTime += time.floatValue
            
            // 获取图片的尺寸 (适应)
            let imageWidth = sourceDict![String(kCGImagePropertyPixelWidth)] as! NSNumber
            let imageHeight = sourceDict![String(kCGImagePropertyPixelHeight)] as! NSNumber
            
            if (imageWidth.floatValue / imageHeight.floatValue) != Float(self.frame.size.width/self.frame.size.height) {
                self.fitScale(imageWidth: CGFloat(imageWidth.floatValue), imageHeight: CGFloat(imageHeight.floatValue))
            }
        }
        
        self.showAnimation()
    }
    
    /**
     *  适应
     */
    private func fitScale(imageWidth: CGFloat, imageHeight: CGFloat) {
        var newWidth: CGFloat
        var newHeight: CGFloat
        if imageWidth/imageHeight > self.bounds.width/self.bounds.height {
            newWidth = self.bounds.width
            newHeight = self.frame.size.width/(imageWidth/imageHeight)
        } else {
            newHeight = self.frame.size.height
            newWidth = self.frame.size.height/(imageHeight/imageWidth)
        }
        let point = self.center;
        
        self.lastImageView.frame.size = CGSize(width: newWidth, height: newHeight)
        self.lastImageView.center = point
    }
    
    /**
     *  展示动画
     */
    private func showAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "contents")
        var current: Float = 0
        var timeKeys: Array<NSNumber> = []
        
        for time in timeArr {
            timeKeys.append(NSNumber(value: current/self.totalTime))
            current += time.floatValue
        }
        
        animation.keyTimes = timeKeys
        animation.delegate = self
        animation.values = self.imageArr
        animation.repeatCount = MAXFLOAT
        animation.duration = TimeInterval(totalTime)
        animation.isRemovedOnCompletion = false
        self.lastImageView.layer.add(animation, forKey: "GifView")
    }
    // Delegate 动画结束
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
    }
}

