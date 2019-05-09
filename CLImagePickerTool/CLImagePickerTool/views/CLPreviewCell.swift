//
//  CLPreviewCell.swift
//  CLImagePickerTool
//
//  Created by darren on 2017/8/8.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import PhotosUI
import Photos

typealias CLPreviewCellClouse = () -> ()

class CLPreviewCell: UICollectionViewCell {
    
    private var imageArr: Array<CGImage> = [] // 图片数组（存放每一帧的图片）
    private var timeArr: Array<NSNumber> = [] // 时间数组 (存放每一帧的图片的时间)
    private var totalTime: Float = 0 // gif 动画时间
    @objc var previewClouse: CLPreviewCellClouse?
    
    @objc var circleBtn: CLCircleView?
    
    var imageRequestID: PHImageRequestID?
    
    @objc let manager = PHImageManager.default()
    
    @objc lazy var iconView: UIImageView = {
        let img = UIImageView.init(frame:  CGRect(x: 0, y: 0, width: self.cl_width, height: self.cl_height))
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    @objc var modelArr: Array<PreviewModel>!

    @objc var identifyIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.iconView)
        self.iconView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(clickImage)))
        
        self.circleBtn = CLCircleView.init(frame: CGRect(x: (self.iconView.cl_width)-40, y: (self.iconView.cl_height)-50, width: 30, height: 30))
        self.addSubview(self.circleBtn!)
    }
    
    @objc var model: PreviewModel! {
        didSet{

            self.imageArr.removeAll()
            self.timeArr.removeAll()
            
            self.circleBtn?.value = model.downLoadProgress
            
            CLPickersTools.instence.getAssetOrigin(asset: model.phAsset!) { (img, info) in
                if img != nil {
                    self.circleBtn?.removeFromSuperview()
                    self.circleBtn = nil
                    
                    if info != nil {
                        let url = (info!["PHImageFileURLKey"] ?? "") as? NSURL
                        let urlstr  = url?.path ?? ""
                        if urlstr.contains(".gif") || urlstr.contains(".GIF") {
                            self.dealGif(originImageAsset:self.modelArr[self.identifyIndex].phAsset ?? PHAsset())
                        } else {
                            self.iconView.image = img!
                        }
                    }
                    

                } else {  // 说明本地没有需要到iCloud下载

                    let option = PHImageRequestOptions()
                    option.isNetworkAccessAllowed = true
                    
                    option.progressHandler = {
                        (progress, error, stop, info) in
                        DispatchQueue.main.async(execute: {
                            print(progress, info ?? "0000",error ?? "error")
                            if self.model?.index == self.identifyIndex {
                                if progress*100 < 10 {
                                    self.circleBtn?.value = 10
                                } else {
                                    self.circleBtn?.value = CGFloat(progress*100)
                                }
                                if self.circleBtn != nil {
                                    self.model.downLoadProgress = (self.circleBtn?.value)!
                                }
                            }
                        })
                    }
                    
                    self.imageRequestID = self.manager.requestImageData(for: self.model.phAsset!, options: option, resultHandler: { (imageData, string, imageOrientation, info) in
                        if imageData != nil {
                            
                            if self.model?.index == self.identifyIndex {
                                self.circleBtn?.removeFromSuperview()
                                self.circleBtn = nil
                            }
                            if info != nil {
                                let url = (info!["PHImageFileURLKey"] ?? "") as? NSURL
                                let urlstr  = url?.path ?? ""
                                if urlstr.contains(".gif") || urlstr.contains(".GIF") {
                                    self.dealGif(originImageAsset:self.modelArr[self.identifyIndex].phAsset ?? PHAsset())
                                } else {
                                    self.iconView.image = UIImage.init(data: imageData!)
                                }
                            }
                        }
                    })
                }
            }

        }
    }
    
    @objc func clickImage() {
        if self.imageRequestID != nil  {
            self.manager.cancelImageRequest(self.imageRequestID!)
        }
        
        if self.previewClouse != nil {
            self.previewClouse!()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.frame = CGRect(x: 0, y: 0, width: self.cl_width, height: self.cl_height)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension CLPreviewCell: CAAnimationDelegate {
    func dealGif(originImageAsset: PHAsset) {
        let option = PHImageRequestOptions()
        option.isSynchronous = true
        PHImageManager.default().requestImageData(for: originImageAsset, options: option, resultHandler: { (gifImgData, str, imageOrientation, info) in
            if gifImgData != nil {
                self.createKeyFram(imgData: gifImgData!)
            }
        })
    }
    // 获取GIF 图片的每一帧有关的东西 比如：每一帧的图片、每一帧图片执行的时间
    func createKeyFram(imgData: Data) {
        
        let gifSource = CGImageSourceCreateWithData(imgData as CFData, nil)
        
        guard let gifSource_v = gifSource else {
            return
        }
        let imageCount = CGImageSourceGetCount(gifSource_v) // 总共图片张数
        
        for i in 0..<imageCount {
            let imageRef = CGImageSourceCreateImageAtIndex(gifSource_v, i, nil) // 取得每一帧的图
            self.imageArr.append(imageRef!)
            
            let sourceDict = CGImageSourceCopyPropertiesAtIndex(gifSource_v, i, nil) as NSDictionary?
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
        
        self.iconView.frame.size = CGSize(width: newWidth, height: newHeight)
        self.iconView.center = point
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
        if self.identifyIndex == self.model.index {
            self.iconView.layer.add(animation, forKey: "GifView")
        }
    }
    // Delegate 动画结束
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
    }
}
