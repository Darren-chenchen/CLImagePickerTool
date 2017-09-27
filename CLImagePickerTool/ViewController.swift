//
//  ViewController.swift
//  CLImagePickerTool
//
//  Created by darren on 2017/8/3.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    @IBOutlet weak var videoScrollView: VideoView!
    @IBOutlet weak var PhotoScrollView: PhotoView!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var photoScrollView2: PhotoView!
    @IBOutlet weak var btn1: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.btn1.titleLabel?.numberOfLines = 0
        self.btn2.titleLabel?.numberOfLines = 0
        self.btn1.sizeToFit()
        self.btn2.sizeToFit()
        
        // 先拼接一个图片
        self.PhotoScrollView.picArr.append(UIImage(named: "takePicture")!)
        self.photoScrollView2.picArr.append(UIImage(named: "takePicture")!)
        self.videoScrollView.picArr.append(UIImage(named: "takePicture")!)

        // 点击了删除，更新界面
        self.PhotoScrollView.closeBtnClickClouse = {[weak self] (imageArr) in
            self?.PhotoScrollView.picArr = imageArr
        }
        self.photoScrollView2.closeBtnClickClouse = {[weak self] (imageArr) in
            self?.photoScrollView2.picArr = imageArr
        }
        self.videoScrollView.closeBtnClickClouse = {[weak self] (imageArr) in
            self?.videoScrollView.picArr = imageArr
        }
        
        // 访问相册,完成后将asset对象通过异步的方式转换为image对象，图片较清晰
        self.PhotoScrollView.visitPhotoBtnClickClouse = {[weak self] () in
            self?.setupPhoto1()
        }

        // 访问相册,完成后将asset对象通过同步的方式转换为image对象，图片较模糊
        self.photoScrollView2.visitPhotoBtnClickClouse = {[weak self] () in
            self?.setupPhoto2()
        }
        
        // 访问相册,完成后将asset对象转换成AVPlayeritem对象
        self.videoScrollView.visitPhotoBtnClickClouse = {[weak self] () in
            self?.setupVideo()
        }

    }
    
    // 异步原图
    private func setupPhoto1() {
        let imagePickTool = CLImagePickersTool()
        
        imagePickTool.isHiddenVideo = true
        
        imagePickTool.setupImagePickerWith(MaxImagesCount: 10, superVC: self) { (assetArr,cutImage) in
            print("返回的asset数组是\(assetArr)")
            
            PopViewUtil.share.showLoading()
            
            self.PhotoScrollView.picArr.removeAll()
            self.PhotoScrollView.picArr.append(UIImage(named: "takePicture")!)
            
            var imageArr = [UIImage]()
            var index = assetArr.count // 标记失败的次数
            
            // 获取原图，异步
            // scale 指定压缩比
            // 内部提供的方法可以异步获取图片，同步获取的话时间比较长，不建议！，如果是iCloud中的照片就直接从icloud中下载，下载完成后返回图片,同时也提供了下载失败的方法
            CLImagePickersTool.convertAssetArrToOriginImage(assetArr: assetArr, scale: 0.1, successClouse: {[weak self] (image,assetItem) in
                imageArr.append(image)
                self?.PhotoScrollView.picArr.append(image)
                
                self?.dealImage(imageArr: imageArr, index: index)
                
                }, failedClouse: { () in
                    index = index - 1
                    self.dealImage(imageArr: imageArr, index: index)
            })
            
        }
    }
    
    @objc func dealImage(imageArr:[UIImage],index:Int) {
        // 图片下载完成后再去掉我们的转转转控件，这里没有考虑assetArr中含有视频文件的情况
        if imageArr.count == index {
            PopViewUtil.share.stopLoading()
        }
        // 图片显示出来以后可能还要上传到云端的服务器获取图片的url，这里不再细说了。
    }
    
    // 同步，缩略图
    private func setupPhoto2() {
        let imagePickTool = CLImagePickersTool()
        imagePickTool.isHiddenVideo = true
        imagePickTool.setupImagePickerWith(MaxImagesCount: 10, superVC: self) { (asset,cutImage) in
            print("返回的asset数组是\(asset)")
            
            //获取缩略图，耗时较短
            let imageArr = CLImagePickersTool.convertAssetArrToThumbnailImage(assetArr: asset, targetSize: CGSize(width: 80, height: 80))
            print(imageArr)
            
            self.photoScrollView2.picArr.removeAll()
            self.photoScrollView2.picArr.append(UIImage(named: "takePicture")!)
            
            for item in imageArr {
                self.photoScrollView2.picArr.append(item)
            }
        }
    }

    @IBAction func clickBtn1(_ sender: Any) {
        self.setupPhoto1()
        
    }
    @IBAction func clickBtnTh(_ sender: Any) {
        self.setupPhoto2()
    }
    
    @IBAction func clickClooseVideobtn(_ sender: Any) {
        self.setupVideo()
    }
    
    
    
//=============================下面是视频的处理===================================
    private func setupVideo() {
        let imagePickTool = CLImagePickersTool()
        imagePickTool.isHiddenImage = true
        imagePickTool.setupImagePickerWith(MaxImagesCount: 5, superVC: self) { (assetArr,cutImage) in
            
            PopViewUtil.share.showLoading()
            
            self.videoScrollView.picArr.removeAll()
            self.videoScrollView.picArr.append(UIImage(named: "takePicture")!)
            
            var imageArr = [UIImage]()
            var index = assetArr.count // 标记失败的次数
            
            var successAssetArr = [PHAsset]()
            
            // 获取原图，异步
            // scale 指定压缩比
            // 内部提供的方法可以异步获取图片，同步获取的话时间比较长，不建议！，如果是iCloud中的照片就直接从icloud中下载，下载完成后返回图片,同时也提供了下载失败的方法
            CLImagePickersTool.convertAssetArrToOriginImage(assetArr: assetArr, scale: 0.1, successClouse: {[weak self] (image,assetItem) in
                imageArr.append(image)
                self?.videoScrollView.picArr.append(image)
                successAssetArr.append(assetItem)
                
                if imageArr.count == index {
                    self?.videoScrollView.assetArr = successAssetArr
                    PopViewUtil.share.stopLoading()
                }
                
                }, failedClouse: { () in
                    index = index-1
                    if imageArr.count == index {
                        self.videoScrollView.assetArr = successAssetArr
                        PopViewUtil.share.stopLoading()
                    }
            })
        }
    }
    
    
    
    
    
    
    
    // 相机在外部
    @IBAction func clickBtn2(_ sender: Any) {
        
        let imagePickTool = CLImagePickersTool()
        
        imagePickTool.cameraOut = true

        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,cutImage) in
            print("返回的asset数组是\(asset)")
        }

    }
    @IBAction func clickMoreBtn(_ sender: Any) {
        let test = TestViewController.init(nibName: "TestViewController", bundle: nil)
        self.present(test, animated: true, completion: nil)
    }
}

