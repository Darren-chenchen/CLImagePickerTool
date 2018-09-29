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
    
    var originalFrame:CGRect!
    
    @objc let manager = PHImageManager.default()
    var imageRequestID: PHImageRequestID?
    
    // 单选模式下图片是否可以编辑
    @objc var singleModelImageCanEditor: Bool = false
    
    @objc var singlePictureClickSureBtn: singlePictureClickSureBtnClouse?
    @objc var singlePictureClickEditorBtn: singlePictureClickEditorBtnClouse?
    
    var originImageAsset: PHAsset?
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        return scroll
    }()
    lazy var circleBtn: CLCircleView = {
        let btn = CLCircleView.init()
        return btn
    }()
    lazy var lastImageView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    lazy var selectBtn: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        return btn
    }()

    lazy var singleSureBtn: UIButton = {
        let btn = UIButton.init()
        btn.setTitle(sureStr, for: .normal)
        btn.setTitleColor(mainColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(clickSureBtn), for: .touchUpInside)
        return btn
    }()
    lazy var btnEditor: UIButton = {
        let btnEditor = UIButton.init()
        btnEditor.setTitle(editorStr, for: .normal)
        btnEditor.setTitleColor(mainColor, for: .normal)
        btnEditor.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btnEditor.addTarget(self, action: #selector(clickEditorBtn), for: .touchUpInside)
        return btnEditor
    }()
    @objc lazy var bottomView: UIView = {
        let bottom = UIView.init()
        bottom.backgroundColor = UIColor(white: 0, alpha: 0.8)
        return bottom
    }()
    
    @objc static func setupAmplifyViewWithUITapGestureRecognizer(tap:UITapGestureRecognizer,superView:UIView,originImageAsset:PHAsset,isSingleChoose:Bool,singleModelImageCanEditor:Bool,isSelect: Bool) -> CLImageAmplifyView{
        
        let amplifyView = CLImageAmplifyView.init(frame: (UIApplication.shared.keyWindow?.bounds)!)
        UIApplication.shared.keyWindow?.addSubview(amplifyView)
        
        amplifyView.setupUIWithUITapGestureRecognizer(tap: tap, superView: superView,originImageAsset:originImageAsset,isSingleChoose:isSingleChoose,singleModelImageCanEditor:singleModelImageCanEditor,isSelect: isSelect)
        
        return amplifyView
    }
    
    func initLayout() {
        
        let win = UIApplication.shared.keyWindow

        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.singleSureBtn.translatesAutoresizingMaskIntoConstraints = false
        self.btnEditor.translatesAutoresizingMaskIntoConstraints = false
        self.selectBtn.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.circleBtn.translatesAutoresizingMaskIntoConstraints = false

        win?.addConstraints([
            NSLayoutConstraint.init(item: self, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: win, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: self, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: win, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: self, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: win, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: self, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: win, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            ])
        self.addConstraints([
            NSLayoutConstraint.init(item: self.scrollView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: self.scrollView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: self.scrollView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: self.scrollView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            ])
        
        if self.selectBtn.superview == self {
            self.selectBtn.addConstraint(NSLayoutConstraint.init(item: self.selectBtn, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: 25))
            self.selectBtn.addConstraint(NSLayoutConstraint.init(item: self.selectBtn, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: 25))
            self.addConstraints([
                NSLayoutConstraint.init(item: self.selectBtn, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 28),
                NSLayoutConstraint.init(item: self.selectBtn, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -20)
                ])
        }
        
        if self.bottomView.superview == self {
            let viewH: CGFloat = UIDevice.current.isX() == true ? 44+34:44
            self.bottomView.addConstraint(NSLayoutConstraint.init(item: self.bottomView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: viewH))
            self.addConstraints([
                NSLayoutConstraint.init(item: self.bottomView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0),
                NSLayoutConstraint.init(item: self.bottomView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint.init(item: self.bottomView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
                ])
        }
        
        if self.singleSureBtn.superview == self.bottomView {
            self.singleSureBtn.addConstraint(NSLayoutConstraint.init(item: self.singleSureBtn, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: 44))
            self.singleSureBtn.addConstraint(NSLayoutConstraint.init(item: self.singleSureBtn, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: 80))
            self.bottomView.addConstraints([
                NSLayoutConstraint.init(item: self.singleSureBtn, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.bottomView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0),
                NSLayoutConstraint.init(item: self.singleSureBtn, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.bottomView, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
                ])
        }

        if self.btnEditor.superview == self.bottomView {
            self.btnEditor.addConstraint(NSLayoutConstraint.init(item: self.btnEditor, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: 44))
            self.btnEditor.addConstraint(NSLayoutConstraint.init(item: self.btnEditor, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: 80))
            self.bottomView.addConstraints([
                NSLayoutConstraint.init(item: self.btnEditor, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.bottomView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0),
                NSLayoutConstraint.init(item: self.btnEditor, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.bottomView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
                ])
        }
        if self.circleBtn.superview == self {
            self.circleBtn.addConstraint(NSLayoutConstraint.init(item: self.circleBtn, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: 30))
            self.circleBtn.addConstraint(NSLayoutConstraint.init(item: self.circleBtn, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: 30))
            self.addConstraints([
                NSLayoutConstraint.init(item: self.circleBtn, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -10),
                NSLayoutConstraint.init(item: self.circleBtn, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -80)
                ])
        }
    }
    private func setupUIWithUITapGestureRecognizer(tap:UITapGestureRecognizer,superView:UIView,originImageAsset: PHAsset,isSingleChoose:Bool,singleModelImageCanEditor:Bool,isSelect: Bool) {
        
        self.singleModelImageCanEditor = singleModelImageCanEditor
        self.originImageAsset = originImageAsset
        
        //scrollView作为背景
        self.scrollView.frame = (UIApplication.shared.keyWindow?.bounds)!
        self.scrollView.backgroundColor = UIColor.black
        self.scrollView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.clickBgView(tapBgView:))))
        
        // 点击的图片
        let picView = tap.view
        
        self.lastImageView.image = (tap.view as! UIImageView).image
        self.lastImageView.frame = (self.scrollView.convert((picView?.frame)!, from: superView))
        self.scrollView.addSubview((self.lastImageView))
        
        self.addSubview(self.scrollView)
        
        CLPickersTools.instence.getAssetOrigin(asset: originImageAsset) { (img, info) in
            if img != nil {
                // 等界面加载出来再复制，放置卡顿效果
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    self.lastImageView.image = img!

                    self.dealGif(info: info,originImageAsset:originImageAsset)
                }
            } else {  // 说明本地没有需要到iCloud下载

                self.addSubview(self.circleBtn)

                let option = PHImageRequestOptions()
                option.isNetworkAccessAllowed = true

                option.progressHandler = {
                (progress, error, stop, info) in
                    DispatchQueue.main.async(execute: {
                        print(progress, info ?? "0000",error ?? "error")
                        if progress*100 < 10 {
                            self.circleBtn.value = 10
                        } else {
                            self.circleBtn.value = CGFloat(progress*100)
                        }
                    })
                }

                self.imageRequestID = self.manager.requestImageData(for: originImageAsset, options: option, resultHandler: { (imageData, string, imageOrientation, info) in
                    if imageData != nil {
                        self.lastImageView.image = UIImage.init(data: imageData!)
                        self.circleBtn.removeFromSuperview()

                        self.dealGif(info: info,originImageAsset:originImageAsset)
                    }
                })
            }
        }

        self.originalFrame = self.lastImageView.frame

        //最大放大比例
        self.scrollView.maximumZoomScale = 1.5
        self.scrollView.delegate = self

        if isSingleChoose {   // 单选
            self.setupBottomView()
        } else {  // 多选
            self.addSubview(self.selectBtn)
            if isSelect {
                self.selectBtn.setBackgroundImage(UIImage(named: "photo_sel_photoPicker", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
                selectBtn.isSelected = true
            } else {
                self.selectBtn.setBackgroundImage(UIImage(named: "", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
                selectBtn.isSelected = false
            }
            CLViewsBorder(self.selectBtn, borderWidth: 1.5, borderColor: UIColor.white, cornerRadius: 25*0.5)
        }
        
        self.initLayout()

        self.show()
    }
    func show() {
        var frameImg = self.lastImageView.frame
        frameImg.size.width = (self.scrollView.cl_width)
        let bili = (self.lastImageView.image?.size.height)! / (self.lastImageView.image?.size.width)!
        let h =  (frameImg.size.width) * bili
        frameImg.size.height = h
        frameImg.origin.x = 0
        frameImg.origin.y = ((self.scrollView.frame.size.height) - (h)) * 0.5
        if (frameImg.size.height) > UIScreen.main.bounds.height {
            frameImg.origin.y = 0
            self.scrollView.contentSize = CGSize(width: 0, height: (frameImg.size.height))
        }
        UIView.animate(withDuration: 0.5) {
            self.lastImageView.frame = frameImg
        }
    }
    @objc func clickBtn() {
        self.selectBtn.isSelected = !self.selectBtn.isSelected
        let model = PreviewModel()
        model.phAsset = self.originImageAsset ?? PHAsset()
        if self.selectBtn.isSelected {
            // 判断是否超过限制
            let maxCount = UserDefaults.standard.integer(forKey: CLImagePickerMaxImagesCount)
            if CLPickersTools.instence.getSavePictureCount() >= maxCount {
                
                PopViewUtil.alert(message:String(format: maxPhotoCountStr, maxCount), leftTitle: "", rightTitle: knowStr, leftHandler: {
                    
                }, rightHandler: {
                    
                })
                return
            }
            self.selectBtn.setBackgroundImage(UIImage(named: "photo_sel_photoPicker", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
            model.isCheck = true
            CLPickersTools.instence.savePicture(asset: (model.phAsset)!, isAdd: true)
        } else {
            self.selectBtn.setBackgroundImage(UIImage(named: "", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
            model.isCheck = false
            CLPickersTools.instence.savePicture(asset: (model.phAsset)!, isAdd: false)
        }
        // 通知列表刷新状态
        CLNotificationCenter.post(name: NSNotification.Name(rawValue:PreviewForSelectOrNotSelectedNotic), object: model)
        
        // 动画
        let shakeAnimation = CABasicAnimation.init(keyPath: "transform.scale")
        shakeAnimation.duration = 0.1
        shakeAnimation.fromValue = 0.8
        shakeAnimation.toValue = 1
        shakeAnimation.autoreverses = true
        self.selectBtn.layer.add(shakeAnimation, forKey: nil)
    }
    
     @objc func clickBgView(tapBgView:UITapGestureRecognizer){
        
        self.bottomView.removeFromSuperview()
        
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.lastImageView.frame = self.originalFrame
            self.lastImageView.contentMode = .scaleAspectFill
            self.lastImageView.layer.masksToBounds = true
            
            tapBgView.view?.backgroundColor = UIColor.clear
            self.circleBtn.removeFromSuperview()
            self.selectBtn.alpha = 0
            
            if self.imageRequestID != nil {
                self.manager.cancelImageRequest(self.imageRequestID!)
            }
            
        }) { (true:Bool) in
            tapBgView.view?.removeFromSuperview()
            self.imageRequestID = nil
            self.lastImageView.removeFromSuperview()
            self.selectBtn.removeFromSuperview()
            self.scrollView.removeFromSuperview()
            self.removeFromSuperview()
        }
    }
    
    @objc func setupBottomView() {
        // 编辑按钮
        if self.singleModelImageCanEditor == true {
            self.bottomView.addSubview(self.btnEditor)
        }
        self.bottomView.addSubview(self.singleSureBtn)
        self.addSubview(self.bottomView)
    }
    
    @objc func clickSureBtn() {
        
        if self.singlePictureClickSureBtn != nil {
            self.singlePictureClickSureBtn!()
        }
        
        self.lastImageView.removeFromSuperview()
        self.scrollView.removeFromSuperview()
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
        
        self.lastImageView.removeFromSuperview()
        self.scrollView.removeFromSuperview()
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
            
            let sourceDict = CGImageSourceCopyPropertiesAtIndex(gifSource!, i, nil) as NSDictionary?
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

