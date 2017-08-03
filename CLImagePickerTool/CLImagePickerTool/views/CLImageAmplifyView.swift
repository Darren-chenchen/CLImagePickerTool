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


class CLImageAmplifyView: UIView {
    
    var lastImageView = UIImageView()
    var originalFrame:CGRect!
    var scrollView = UIScrollView()

    
    static func setupAmplifyViewWithUITapGestureRecognizer(tap:UITapGestureRecognizer,superView:UIView,originImageAsset:PHAsset) {
        
        let amplifyView = CLImageAmplifyView.init(frame: (UIApplication.shared.keyWindow?.bounds)!)
        
        amplifyView.setupUIWithUITapGestureRecognizer(tap: tap, superView: superView,originImageAsset:originImageAsset)
        
        UIApplication.shared.keyWindow?.addSubview(amplifyView)
    }
    
    private func setupUIWithUITapGestureRecognizer(tap:UITapGestureRecognizer,superView:UIView,originImageAsset: PHAsset) {
        //scrollView作为背景
        let bgView = UIScrollView()
        bgView.frame = (UIApplication.shared.keyWindow?.bounds)!
        bgView.backgroundColor = UIColor.black
        
        bgView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.clickBgView(tapBgView:))))
        
        // 点击的图片
        let picView = tap.view
        
        let imageView = UIImageView()
        imageView.image = (tap.view as! UIImageView).image
        imageView.frame = bgView.convert((picView?.frame)!, from: superView)
        bgView.addSubview(imageView)
        
        self.addSubview(bgView)
        
        CLPickersTools.instence.getAssetOrigin(asset: originImageAsset) { (img, info) in
            imageView.image = img!
        }
        
        self.lastImageView = imageView;
        
        self.originalFrame = imageView.frame;
        
        self.scrollView = bgView;
        
        //最大放大比例
        self.scrollView.maximumZoomScale = 1.5;
        self.scrollView.delegate = self;
        
        
        UIView.animate(withDuration: 0.5) {
            var frame = imageView.frame
            frame.size.width = bgView.frame.size.width
            let bili = ((imageView.image?.size.height)! / (imageView.image?.size.width)!)
            frame.size.height = frame.size.width * bili
            frame.origin.x = 0
            frame.origin.y = (bgView.frame.size.height - frame.size.height) * 0.5
            imageView.frame = frame
            
            if frame.size.height > UIScreen.main.bounds.height {
                frame.origin.y = 0
                imageView.frame = frame
                self.scrollView.contentSize = CGSize(width: 0, height: frame.size.height)
            }
        }
    }
    
     func clickBgView(tapBgView:UITapGestureRecognizer){
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.lastImageView.frame = self.originalFrame
            self.lastImageView.alpha = 0
            tapBgView.view?.backgroundColor = UIColor.clear
            
        }) { (true:Bool) in
            tapBgView.view?.removeFromSuperview()
            
            self.removeFromSuperview()
        }
    }

}

//返回可缩放的视图
extension CLImageAmplifyView:UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.lastImageView
    }
}

