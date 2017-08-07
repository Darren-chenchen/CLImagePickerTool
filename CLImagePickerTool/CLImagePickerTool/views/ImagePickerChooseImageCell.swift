//
//  ImagePickerChooseImageCell.swift
//  ImageDeal
//
//  Created by darren on 2017/7/27.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import Photos

typealias imagePickerChooseImageCellClouse = () -> ()

class ImagePickerChooseImageCell: UICollectionViewCell {

    @IBOutlet weak var vedioImageView: UIImageView!
    @IBOutlet weak var timerLable: UILabel!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var chooseBtn: UIButton!
    @IBOutlet weak var chooseImageBtn: CLCircleView!
    
    let btnBackColor = UIColor(white: 0, alpha: 0.6)
    
    var imagePickerChooseImage: imagePickerChooseImageCellClouse?
    
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
            
            // 是否选中
            self.chooseBtn.isSelected = self.model?.isSelect ?? false
            self.chooseImageBtn.isSelected = self.model?.isSelect ?? false
            self.iconView.alpha = self.chooseImageBtn.isSelected ? 0.5:1
            if self.chooseImageBtn.isSelected {
                self.chooseImageBtn.setBackgroundImage(UIImage(named: "photo_sel_photoPicker", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
            } else {
                self.chooseImageBtn.setBackgroundImage(UIImage(named:""), for: .normal)
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CLPickersTools.instence.setupBottomViewGradient(superView: self.bottomView)
        self.bottomView.bringSubview(toFront: self.timerLable) // 防止渐变色同化label
        self.bottomView.bringSubview(toFront: self.vedioImageView)
        
        self.iconView.isUserInteractionEnabled = true
        
        // 初始化按钮状态
        CLViewsBorder(self.chooseImageBtn, borderWidth: 1.5, borderColor: UIColor.white, cornerRadius: self.chooseImageBtn.cl_width*0.5)
        self.chooseImageBtn.backgroundColor = self.btnBackColor
        self.chooseImageBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        
        self.iconView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(clickIconView(ges:))))
    }
    
    func clickIconView(ges:UITapGestureRecognizer) {
        if self.model?.phAsset == nil {
            return
        }
        // 相册
        if self.model?.phAsset?.mediaType == .image {
            _ = CLImageAmplifyView.setupAmplifyViewWithUITapGestureRecognizer(tap: ges, superView: self.contentView,originImageAsset:(self.model?.phAsset)!,isSingleChoose:false)
        }
        // 视频
        if self.model?.phAsset?.mediaType == .video {
            _ = CLVideoPlayView.setupAmplifyViewWithUITapGestureRecognizer(tap: ges, superView: self.contentView,originImageAsset:(self.model?.phAsset)!, isSingleChoose: false)
        }
    }
    
    @IBAction func clickChooseBtn(_ sender: Any) {
        
        if self.model?.phAsset == nil {
            return
        }
        
        if self.chooseImageBtn.isSelected == false {
            // 判断是否超过限制
            let maxCount = UserDefaults.standard.integer(forKey: CLImagePickerMaxImagesCount)
            if CLPickersTools.instence.getSavePictureCount() >= maxCount {
                PopViewUtil.alert(message: "您最多只能选择\(maxCount)张照片", leftTitle: "", rightTitle: "知道了", leftHandler: {
                    
                }, rightHandler: {
                    
                })
                return
            }
        }
        
        self.chooseBtn.isSelected = !self.chooseBtn.isSelected
        self.chooseImageBtn.isSelected = self.chooseBtn.isSelected
        self.iconView.alpha = self.chooseImageBtn.isSelected ? 0.5:1
        self.model?.isSelect = self.chooseImageBtn.isSelected
        
        if self.chooseImageBtn.isSelected {
            CLPickersTools.instence.savePicture(asset: (self.model?.phAsset)!, isAdd: true)
            if imagePickerChooseImage != nil {
                imagePickerChooseImage!()
            }
            
            self.chooseImageBtn.setBackgroundImage(UIImage(named: "photo_sel_photoPicker", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
        } else {
            CLPickersTools.instence.savePicture(asset: (self.model?.phAsset)!, isAdd: false)
            if imagePickerChooseImage != nil {
                imagePickerChooseImage!()
            }
            
            self.chooseImageBtn.setBackgroundImage(UIImage(named:""), for: .normal)
        }
        
        // 动画
        let shakeAnimation = CABasicAnimation.init(keyPath: "transform.scale")
        shakeAnimation.duration = 0.1
        shakeAnimation.fromValue = 0.8
        shakeAnimation.toValue = 1
        shakeAnimation.autoreverses = true
        self.chooseImageBtn?.layer.add(shakeAnimation, forKey: nil)
    }
}
