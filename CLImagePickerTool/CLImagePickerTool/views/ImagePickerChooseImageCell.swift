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
    
    @objc let btnBackColor = UIColor(white: 0, alpha: 0.6)
    // 视频和照片只能选择一种，不能同时选择,默认可以同时选择
    @objc var onlyChooseImageOrVideo: Bool = false
    
    @objc var imagePickerChooseImage: imagePickerChooseImageCellClouse?
    
    @objc var model: CLImagePickerPhotoModel? {
        didSet{
            
            // 图片
            if model?.pictureImg != nil {
                self.iconView.image = model?.pictureImg
            }else {
                if model?.phAsset != nil {
                    
                    CLPickersTools.instence.getAssetThumbnail(targetSize: CGSize(width:cellH, height: cellH), asset: (self.model?.phAsset)!) { (image, info) in
                        self.iconView.image = image
                        self.model?.pictureImg = image
                    }
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
            if self.chooseImageBtn.isSelected {
                self.chooseImageBtn.setBackgroundImage(UIImage(named: "photo_sel_photoPicker", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
            } else {
                self.chooseImageBtn.setBackgroundImage(UIImage(named:""), for: .normal)
            }
            
            setupCellCover()
        }
    }
    
    // 设置cell的阴影
    @objc func setupCellCover() {
        // 视频，图片只能选择1中
        if self.onlyChooseImageOrVideo {
            if self.chooseImageBtn.isSelected {
                self.iconView.alpha = 0.5
                self.backgroundColor = UIColor.white
                self.chooseImageBtn.isHidden = false
            } else {
                self.iconView.alpha = (self.model?.onlyChooseImageOrVideo ?? false) ? 0.5:1
                self.backgroundColor = UIColor(white: 0, alpha: 0.8)
                self.chooseImageBtn.isHidden = (self.model?.onlyChooseImageOrVideo ?? false) ? true:false
            }
        } else {
            self.iconView.alpha = self.chooseImageBtn.isSelected ? 0.5:1
            self.backgroundColor = UIColor.white
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
    
    @objc func clickIconView(ges:UITapGestureRecognizer) {
        if self.model?.phAsset == nil {
            return
        }
        
        // 视频图片只能选择一种
        if self.onlyChooseImageOrVideo {
            if (self.model?.onlyChooseImageOrVideo ?? false) {
                return
            }
        }

        // 相册
        if self.model?.phAsset?.mediaType == .image {
            _ = CLImageAmplifyView.setupAmplifyViewWithUITapGestureRecognizer(tap: ges, superView: self.contentView,originImageAsset:(self.model?.phAsset)!,isSingleChoose:false, singleModelImageCanEditor: false)
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
                
                PopViewUtil.alert(message:String(format: maxPhotoCountStr, maxCount), leftTitle: "", rightTitle: knowStr, leftHandler: {
                    
                }, rightHandler: {
                    
                })
                return
            }
        }
        
        if self.onlyChooseImageOrVideo {
            if (self.model?.onlyChooseImageOrVideo ?? false) {
                PopViewUtil.alert(message:imageAndVideoOnlyOneStr, leftTitle: knowStr, rightTitle: "", leftHandler: {
                    
                }, rightHandler: { 
                    
                })
                return
            }
        }
        
        self.chooseBtn.isSelected = !self.chooseBtn.isSelected
        self.chooseImageBtn.isSelected = self.chooseBtn.isSelected
        self.model?.isSelect = self.chooseImageBtn.isSelected
        setupCellCover()
        
        if self.chooseImageBtn.isSelected {
            
            // 如果是视频和照片只能选择一种，先判断用户第一次选择的是视频还是照片，并记录下来
            if self.onlyChooseImageOrVideo {
                if CLPickersTools.instence.getSavePictureCount() == 0 {
                    UserDefaults.standard.set(self.model?.phAsset?.mediaType.rawValue, forKey: UserChooserType)
                    UserDefaults.standard.synchronize()
                    CLNotificationCenter.post(name: NSNotification.Name(rawValue:OnlyChooseImageOrVideoNotic), object: self.model?.phAsset?.mediaType.rawValue)
                }
            }
            
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
            
            if self.onlyChooseImageOrVideo {
                if CLPickersTools.instence.getSavePictureCount() == 0 {
                    // 判断是不是所有都取消了，如果是记得清除记录用户第一次选择的类型（照片或者视频）
                    UserDefaults.standard.set(0, forKey: UserChooserType)
                    UserDefaults.standard.synchronize()
                    
                    // 发送通知，更新模型的状态
                    CLNotificationCenter.post(name: NSNotification.Name(rawValue:OnlyChooseImageOrVideoNoticCencel), object: nil)
                }
            }

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
