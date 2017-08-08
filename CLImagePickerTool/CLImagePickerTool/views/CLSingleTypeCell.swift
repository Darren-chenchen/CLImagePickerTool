//
//  CLSingleTypeCell.swift
//  CLImagePickerTool
//
//  Created by darren on 2017/8/4.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import Photos
import PassKit

typealias singleChoosePictureClouse = ([PHAsset],UIImage) -> ()

class CLSingleTypeCell: UICollectionViewCell {

    @IBOutlet weak var vedioImageView: UIImageView!
    @IBOutlet weak var timerLable: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    
    var singleChoosePicture: singleChoosePictureClouse?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        CLPickersTools.instence.setupBottomViewGradient(superView: self.bottomView)
        self.bottomView.bringSubview(toFront: self.timerLable) // 防止渐变色同化label
        self.bottomView.bringSubview(toFront: self.vedioImageView)
        
        self.iconView.isUserInteractionEnabled = true
                
        self.iconView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(clickIconView(ges:))))
    }
    
    var model: CLImagePickerPhotoModel? {
        didSet{
            
            // 图片
            if model?.phAsset != nil {
                CLPickersTools.instence.getAssetThumbnail(targetSize: CGSize(width:cellH, height: cellH), asset: (model?.phAsset)!) { (image, info) in
                    self.iconView.image = image
                }
            }
            
            // 视频时长
            self.timerLable.text = model?.videoLength
            
            // 视频底部阴影
            if model?.phAsset?.mediaType == .video {
                self.bottomView.isHidden = false
            } else {
                self.bottomView.isHidden = true
            }
        }
    }
    
    
    func clickIconView(ges:UITapGestureRecognizer) {
        // 相册
        if self.model?.phAsset?.mediaType == .image {
            let amplifyView =  CLImageAmplifyView.setupAmplifyViewWithUITapGestureRecognizer(tap: ges, superView: self.contentView,originImageAsset:(self.model?.phAsset)!,isSingleChoose:true)
            amplifyView.singlePictureClickSureBtn = {[weak self] () in
                if self?.singleChoosePicture != nil {
                    self?.singleChoosePicture!([(self?.model?.phAsset)!],amplifyView.lastImageView?.image ?? UIImage())
                }
            }
        }
        // 视频
        if self.model?.phAsset?.mediaType == .video {
            let amplifyView = CLVideoPlayView.setupAmplifyViewWithUITapGestureRecognizer(tap: ges, superView: self.contentView,originImageAsset:(self.model?.phAsset)!,isSingleChoose:true)
            amplifyView.singleVideoClickSureBtn = {[weak self] () in
                if self?.singleChoosePicture != nil {
                    self?.singleChoosePicture!([(self?.model?.phAsset)!],amplifyView.lastImageView.image ?? UIImage())
                }
            }
        }
    }
}
