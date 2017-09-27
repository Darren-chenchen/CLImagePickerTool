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
            CLPickersTools.instence.getAssetThumbnail(targetSize: CGSize(width:cellH, height: cellH), asset: model.phAsset!) { (image, info) in
                self.iconView.image = image
            }
            
            self.circleBtn?.value = model.downLoadProgress
            
            CLPickersTools.instence.getAssetOrigin(asset: model.phAsset!) { (img, info) in
                if img != nil {
                    self.iconView.image = img!
                    self.circleBtn?.removeFromSuperview()
                    self.circleBtn = nil
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
                            self.iconView.image = UIImage.init(data: imageData!)
                            
                            if self.model?.index == self.identifyIndex {
                                self.circleBtn?.removeFromSuperview()
                                self.circleBtn = nil
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
