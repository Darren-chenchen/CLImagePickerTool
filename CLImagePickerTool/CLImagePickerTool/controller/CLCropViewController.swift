//
//  CLCropViewController.swift
//  CLCropView
//
//  Created by darren on 2017/8/7.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import Photos
import PassKit

enum EnterType {
    case normal
    case camero
}

typealias CLCropViewControllerClouse = (UIImage)->()
typealias CLCropViewControllerCancelClouse = ()->()

class CLCropViewController: CLBaseImagePickerViewController {
    
    @objc var scale: CGFloat = 1  // 宽/高
    
    @objc var originalImage: UIImage?
    
    @objc var imageView: UIImageView?
    
    @objc var asset: PHAsset?
    
    @objc var clCropClouse: CLCropViewControllerClouse?
    @objc var cancelClouse: CLCropViewControllerCancelClouse?

    @objc var circleBtn: CLCircleView?
    
    var enterType: EnterType = .normal
    
    @objc let manager = PHImageManager.default()
    var imageRequestID: PHImageRequestID?

    @objc lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView.init(frame: CGRect(x: 0, y: 0.5*(UIScreen.main.bounds.size.height-UIScreen.main.bounds.size.width/self.scale), width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width/self.scale))
        scroll.bouncesZoom = true
        scroll.minimumZoomScale = 1
        scroll.maximumZoomScale = 3
        scroll.zoomScale = 1
        scroll.delegate = self
        scroll.layer.masksToBounds = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.layer.borderWidth = 1.5
        scroll.layer.borderColor = UIColor.white.cgColor
        return scroll
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavBar.isHidden = true
        
        self.view.addSubview(self.scrollView)
        self.view.backgroundColor = UIColor.black
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.layer.masksToBounds = true
        
        if originalImage != nil {
            self.imageView = UIImageView.init(image: self.originalImage)
            
            let img_width = UIScreen.main.bounds.size.width
            let img_height = (self.originalImage?.size.height)! * (img_width/(self.originalImage?.size.width)!)
            
            let img_y = 0.5*(img_height - self.scrollView.frame.size.height)
            
            self.imageView?.frame = CGRect(x:0,y:0, width:img_width, height:img_height)
            self.imageView?.isUserInteractionEnabled = true
            
            self.scrollView.addSubview(self.imageView!)
            
            self.scrollView.contentSize = CGSize(width:img_width, height:img_height)
            self.scrollView.contentOffset = CGPoint(x:0, y:img_y)
            
            self.loadData()
        }
        self.userInterface()
    }
    
    
    @objc func userInterface() {
        let cropframe = self.scrollView.frame
        let path = UIBezierPath.init(roundedRect: self.view.bounds, cornerRadius: 0)
        let cropPath = UIBezierPath.init(roundedRect:cropframe, cornerRadius: 0)
        path.append(cropPath)
        
        let layer = CAShapeLayer()
        layer.fillColor = UIColor(white: 0, alpha: 0.5).cgColor
        layer.fillRule = kCAFillRuleEvenOdd
        layer.path = path.cgPath
        self.view.layer.addSublayer(layer)
        
        let viewH: CGFloat = UIDevice.current.isX() == true ? 46+34:46

        let bottomView = UIView.init(frame: CGRect(x: 0, y: self.view.bounds.size.height - viewH, width: self.view.bounds.size.width, height: viewH))
        bottomView.backgroundColor = UIColor(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 0.7)
        self.view.addSubview(bottomView)
        
        let cancelBtn = UIButton.init(frame: CGRect(x: 0, y: 0, width: 80, height: 46))
        cancelBtn.setTitle(cancelStr, for: .normal)
        cancelBtn.addTarget(self, action: #selector(clickCancelBtn), for: .touchUpInside)
        bottomView.addSubview(cancelBtn)
        
        let sureBtn = UIButton.init(frame: CGRect(x: bottomView.frame.size.width-80, y: 0, width: 80, height: 46))
        sureBtn.setTitle(sureStr, for: .normal)
        sureBtn.addTarget(self, action: #selector(clickSureBtn), for: .touchUpInside)
        bottomView.addSubview(sureBtn)

    }
    
    @objc func clickCancelBtn() {
        if self.imageRequestID != nil {
            self.manager.cancelImageRequest(self.imageRequestID!)
        }
        if enterType == .normal {
            self.navigationController?.popViewController(animated: true)
        }
        if enterType == .camero {
            if cancelClouse != nil {
                self.cancelClouse!()
            }
        }
    }
    
    deinit {
        print("CLCropViewController裁剪释放")
    }
    
    @objc func clickSureBtn() {
        
        if self.imageRequestID != nil {
            self.manager.cancelImageRequest(self.imageRequestID!)
        }
        
        if self.clCropClouse != nil {
            self.clCropClouse!(self.cropImage())
        }
    }
    
    @objc func loadData() {
        CLPickersTools.instence.getAssetOrigin(asset: self.asset!) { (img, info) in
            if img != nil {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: {
                    if img != nil {
                        self.imageView?.image = img!
                    }
                })
            } else {  // 说明本地没有需要到iCloud下载
                
                self.circleBtn = CLCircleView.init(frame: CGRect(x: KScreenWidth-40, y: KScreenHeight-100, width: 30, height: 30))
                self.view.addSubview(self.circleBtn!)
                
                let option = PHImageRequestOptions()
                option.isNetworkAccessAllowed = true
                
                option.progressHandler = {
                    (progress, error, stop, info) in
                    DispatchQueue.main.async(execute: {
                        print(progress, info ?? "0000")
                        if progress*100 < 10 {
                            self.circleBtn?.value = 10
                        } else {
                            self.circleBtn?.value = CGFloat(progress*100)
                        }
                    })
                }
                
                self.imageRequestID = self.manager.requestImageData(for: self.asset!, options: option, resultHandler: { (imageData, string, imageOrientation, info) in
                    if imageData != nil {
                        self.imageView?.image = UIImage.init(data: imageData!)
                        self.circleBtn?.removeFromSuperview()
                        self.circleBtn = nil
                    }
                })
            }
        }

    }
}

extension CLCropViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerContent()
    }
        
    @objc func centerContent() {
        
        guard var imageViewFrame =  self.imageView?.frame else {
            return
        }
        
        let scrollBounds = CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.width/self.scale)
        
        if (imageViewFrame.size.height) > scrollBounds.size.height {
            imageViewFrame.origin.y = 0.0
        }else {
            imageViewFrame.origin.y = (scrollBounds.size.height - (imageViewFrame.size.height)) / 2.0
        }
        if (imageViewFrame.size.width) < scrollBounds.size.width {
            imageViewFrame.origin.x = (scrollBounds.size.width - (imageViewFrame.size.width)) / 2.0
        }else {
            imageViewFrame.origin.x = 0.0
        }
        self.imageView?.frame = imageViewFrame
    }
    
    @objc func cropImage() -> UIImage {        
        var offset = self.scrollView.contentOffset
        //图片缩放比例
        let zoom = (self.imageView?.frame.size.width)!/(self.originalImage?.size.width)!
        //视网膜屏幕倍数相关
//        zoom = zoom / UIScreen.main.scale

        var width = self.scrollView.frame.size.width
        var height = width/self.scale
        if (self.imageView?.frame.size.height)! < self.scrollView.frame.size.height {//太胖了,取中间部分
            offset = CGPoint(x:offset.x + (width - (self.imageView?.frame.size.height)!)/2.0, y:0)
            width = (self.imageView?.frame.size.height)!
            height = (self.imageView?.frame.size.height)!
        }

        let rec = CGRect(x:offset.x/zoom, y:offset.y/zoom,width:width/zoom,height:height/zoom)
    
        let imageRef = (self.originalImage?.cgImage!)!.cropping(to: rec)
        
        let image = UIImage.init(cgImage: imageRef!)
        return image
    }
}
