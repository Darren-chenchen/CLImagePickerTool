//
//  CLImagePickerAnotherViewController.swift
//  CLImagePickerTool
//
//  Created by darren on 2017/11/17.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import Photos

class CLImagePickerAnotherViewController: UIViewController {

    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var bottomHYS: NSLayoutConstraint!
    @objc let imageCellID = "imagecellID"

    // 是否隐藏视频文件，默认不隐藏
    @objc public var isHiddenVideo: Bool = false
    // 是否隐藏图片文件，显示视频文件，默认不隐藏
    @objc public var isHiddenImage: Bool = false
    // 视频和照片只能选择一种，不能同时选择,默认可以同时选择
    @objc var onlyChooseImageOrVideo: Bool = false

    @objc var photoArr: [CLImagePickerPhotoModel]?
    
    var MaxImagesCount: Int = 0
    
    @objc var singleChooseImageCompleteClouse: CLImagePickerSingleChooseImageCompleteClouse?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initView()
        
        self.bottomHYS.constant = UIDevice.current.isX() == true ? 50 + 34:50
        
        CLNotificationCenter.addObserver(self, selector: #selector(CLImagePickerAnotherViewController.PreviewForSelectOrNotSelectedNoticFunc), name: NSNotification.Name(rawValue:PreviewForSelectOrNotSelectedNotic), object: nil)
    }
    deinit {
        CLNotificationCenter.removeObserver(self)
    }
    @objc func PreviewForSelectOrNotSelectedNoticFunc(notic:Notification) {
        
        let modelPreView = notic.object as! PreviewModel
        for model in (self.photoArr ?? []) {
            if model.phAsset == modelPreView.phAsset {
                model.isSelect = modelPreView.isCheck
            }
        }
        
        if CLPickersTools.instence.getSavePictureCount() > 0 {
            let title = "\(sureStr)(\(CLPickersTools.instence.getSavePictureCount()))"
            self.sureBtn.setTitle(title, for: .normal)
            self.sureBtn.isEnabled = true
            self.resetBtn.isEnabled = true
        } else {
            self.sureBtn.isEnabled = false
            self.resetBtn.isEnabled = false
        }
        
        self.collectionView.reloadData()
    }
    func initView() {
        // 存储用户设置的最多图片数量
        UserDefaults.standard.set(MaxImagesCount, forKey: CLImagePickerMaxImagesCount)
        UserDefaults.standard.synchronize()
        
        CLPickersTools.instence.isHiddenVideo = isHiddenVideo  // 是否隐藏视频文件赋值
        CLPickersTools.instence.isHiddenImage = isHiddenImage
        
        // 清除保存的数据
        CLPickersTools.instence.clearPicture()
        // 如果用户之前设置的是onlyChooseImageOrVideo类型，记得将这个类型刚开始就置空
        UserDefaults.standard.set(0, forKey: UserChooserType)
        UserDefaults.standard.synchronize()
        
        self.resetBtn.setTitle(resetStr, for: .normal)
        self.sureBtn.setTitle(sureStr, for: .normal)
        self.cancelBtn.setTitle(cancelStr, for: .normal)
        
        if CLPickersTools.instence.getSavePictureCount() > 0 {
            let title = "\(sureStr)(\(CLPickersTools.instence.getSavePictureCount()))"
            self.sureBtn.setTitle(title, for: .normal)
            self.sureBtn.isEnabled = true
            self.resetBtn.isEnabled = true
        } else {
            self.sureBtn.isEnabled = false
            self.resetBtn.isEnabled = false
        }
        
        let flowout = UICollectionViewFlowLayout.init()
        self.collectionView.collectionViewLayout = flowout
        flowout.scrollDirection = .horizontal
        flowout.minimumInteritemSpacing = 10

        self.collectionView.register(UINib.init(nibName: "ImagePickerChooseImageCellV2", bundle: BundleUtil.getCurrentBundle()), forCellWithReuseIdentifier: imageCellID)
        
        self.photoArr = CLPickersTools.instence.loadPhotoForAll().first?.values.first?.reversed()
        self.collectionView.reloadData()
    }

    @IBAction func clickSureBtn(_ sender: Any) {
        
        self.dismiss(animated: true) {
            if self.singleChooseImageCompleteClouse != nil {
                self.singleChooseImageCompleteClouse!(CLPickersTools.instence.getChoosePictureArray(),nil)
            }
        }

    }
    @IBAction func clickResetBtn(_ sender: Any) {
        if self.photoArr != nil {
            for model in self.photoArr! {
                model.isSelect = false
            }
        }
        
        CLPickersTools.instence.clearPicture()
        
        self.resetBtn.isEnabled = false
        self.sureBtn.isEnabled = false
        self.sureBtn.setTitle(sureStr, for: .normal)
        
        if self.onlyChooseImageOrVideo {
            for model in (self.photoArr ?? []) {
                model.onlyChooseImageOrVideo = false
            }
            // 重置选择的类型
            UserDefaults.standard.set(0, forKey: UserChooserType)
            UserDefaults.standard.synchronize()
        }
        
        self.collectionView.reloadData()
    }
    @IBAction func clickCancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func clickEditorBtn(_ sender: Any) {
        
    }
    @IBAction func clickPhotoBtn(_ sender: Any) {

    }
}

extension CLImagePickerAnotherViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = self.photoArr?[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellID, for: indexPath) as! ImagePickerChooseImageCellV2
        cell.onlyChooseImageOrVideo = self.onlyChooseImageOrVideo
        cell.model = model
        cell.imagePickerChooseImage = {[weak self] () in
            let chooseCount = CLPickersTools.instence.getSavePictureCount()
            if chooseCount == 0 {
                self?.sureBtn.setTitle(sureStr, for: .normal)
                self?.sureBtn.isEnabled = false
                self?.resetBtn.isEnabled = false
            } else {
                self?.sureBtn.setTitle("\(sureStr)(\(chooseCount))", for: .normal)
                self?.sureBtn.isEnabled = true
                self?.resetBtn.isEnabled = true
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout:UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let model = self.photoArr![indexPath.row]
        var W: CGFloat = (CGFloat(model.phAsset?.pixelWidth ?? 0))
        let H: CGFloat = CGFloat(model.phAsset?.pixelHeight ?? 0)
        
        if W / H < 1 {
            W = KScreenWidth/3.2
        } else {
            W = KScreenWidth/1.2
        }

        return CGSize(width: W, height: 230)
    }

}
