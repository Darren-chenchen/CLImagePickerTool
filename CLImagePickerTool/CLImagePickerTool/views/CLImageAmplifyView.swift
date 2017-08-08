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


typealias singlePictureClickSureBtnClouse = ()->()

class CLImageAmplifyView: UIView {
    
    var lastImageView: UIImageView?
    var originalFrame:CGRect!
    var scrollView: UIScrollView?
    var circleBtn: CLCircleView?
    
    let manager = PHImageManager.default()
    var imageRequestID: PHImageRequestID?
    
    var singlePictureClickSureBtn: singlePictureClickSureBtnClouse?
    
    lazy var bottomView: UIView = {
        let bottom = UIView.init(frame: CGRect(x: 0, y: KScreenHeight-44, width: KScreenWidth, height: 44))
        bottom.backgroundColor = UIColor(white: 0, alpha: 0.8)
        let btn = UIButton.init(frame: CGRect(x: KScreenWidth-80, y: 0, width: 80, height: 44))
        btn.setTitle("确定", for: .normal)
        btn.setTitleColor(mainColor, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        bottom.addSubview(btn)
        btn.addTarget(self, action: #selector(clickSureBtn), for: .touchUpInside)
        return bottom
    }()
    
    static func setupAmplifyViewWithUITapGestureRecognizer(tap:UITapGestureRecognizer,superView:UIView,originImageAsset:PHAsset,isSingleChoose:Bool) -> CLImageAmplifyView{
        
        let amplifyView = CLImageAmplifyView.init(frame: (UIApplication.shared.keyWindow?.bounds)!)
        
        amplifyView.setupUIWithUITapGestureRecognizer(tap: tap, superView: superView,originImageAsset:originImageAsset,isSingleChoose:isSingleChoose)
        
        UIApplication.shared.keyWindow?.addSubview(amplifyView)
        
        return amplifyView
    }
    
    private func setupUIWithUITapGestureRecognizer(tap:UITapGestureRecognizer,superView:UIView,originImageAsset: PHAsset,isSingleChoose:Bool) {
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
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                    self.lastImageView?.image = img!
                }
            } else {  // 说明本地没有需要到iCloud下载
                
                self.circleBtn = CLCircleView.init(frame: CGRect(x: (self.lastImageView?.cl_width)!-40, y: (self.lastImageView?.cl_height)!-40, width: 30, height: 30))
                self.lastImageView?.addSubview(self.circleBtn!)
                
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
                    }
                })
            }
        }
        
        self.originalFrame = self.lastImageView?.frame
        
        //最大放大比例
        self.scrollView?.maximumZoomScale = 1.5;
        self.scrollView?.delegate = self;
        
        
        UIView.animate(withDuration: 0.5) {
            var frame = self.lastImageView?.frame
            frame?.size.width = (self.scrollView?.frame.size.width)!
            let bili = ((self.lastImageView?.image?.size.height)! / (self.lastImageView?.image?.size.width)!)
            frame?.size.height = (frame?.size.width)! * bili
            frame?.origin.x = 0
            frame?.origin.y = ((self.scrollView?.frame.size.height)! - (frame?.size.height)!) * 0.5
            self.lastImageView?.frame = frame!
            
            if (frame?.size.height)! > UIScreen.main.bounds.height {
                frame?.origin.y = 0
                self.lastImageView?.frame = frame!
                self.scrollView?.contentSize = CGSize(width: 0, height: (frame?.size.height)!)
            }
        }
        
        if isSingleChoose {   // 单选
            self.setupBottomView()
        }
    }
    
     func clickBgView(tapBgView:UITapGestureRecognizer){
        self.scrollView?.contentOffset = CGPoint(x: 0, y: 0)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.lastImageView?.frame = self.originalFrame
            self.lastImageView?.alpha = 0
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
    
    func setupBottomView() {
        self.addSubview(self.bottomView)
    }
    
    func clickSureBtn() {
        
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
}

//返回可缩放的视图
extension CLImageAmplifyView:UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.lastImageView
    }
}

