//
//  ViewController.swift
//  CLImagePickerTool
//
//  Created by darren on 2017/8/3.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var img3: UIImageView!
    
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
        
        self.PhotoScrollView.picArr.append(UIImage(named: "takePicture")!)
        self.photoScrollView2.picArr.append(UIImage(named: "takePicture")!)

        self.PhotoScrollView.closeBtnClickClouse = { (imageArr) in
            self.PhotoScrollView.picArr = imageArr
        }
        self.photoScrollView2.closeBtnClickClouse = { (imageArr) in
            self.photoScrollView2.picArr = imageArr
        }

    }

    // 相机在内部
    @IBAction func clickBtn1(_ sender: Any) {
        
        let imagePickTool = CLImagePickersTool()
        
        imagePickTool.setupImagePickerWith(MaxImagesCount: 10, superVC: self) { (asset,cutImage) in
            print("返回的asset数组是\(asset)")
            
            
            PopViewUtil.share.showLoading()
            
            self.PhotoScrollView.picArr.removeAll()
            self.PhotoScrollView.picArr.append(UIImage(named: "takePicture")!)
            
            var imageArr = [UIImage]()
            
            // 获取原图，异步
            // scale 指定压缩比
            // 内部提供的方法可以异步获取图片，同步获取的话时间比较长，不建议！，如果是iCloud中的照片就直接从icloud中下载，下载完成后返回图片,同时也提供了下载失败的方法
            CLImagePickersTool.convertAssetArrToOriginImage(assetArr: asset, scale: 0.1, successClouse: {[weak self] (image) in
                imageArr.append(image)
                self?.PhotoScrollView.picArr.append(image)

                // 图片下载完成后再去掉我们的转转转控件，这里没有考虑assetArr中含有视频文件的情况
                if imageArr.count == asset.count {
                    PopViewUtil.share.stopLoading()
                }
            }, failedClouse: { () in
                PopViewUtil.share.stopLoading()
            })
        }
    }
    @IBAction func clickBtnTh(_ sender: Any) {
        let imagePickTool = CLImagePickersTool()
        imagePickTool.setupImagePickerWith(MaxImagesCount: 10, superVC: self) { (asset,cutImage) in
            print("返回的asset数组是\(asset)")

            //获取缩略图，耗时较短
            let imageArr = CLImagePickersTool.convertAssetArrToThumbnailImage(assetArr: asset, targetSize: CGSize(width: 200, height: 200))
            print(imageArr)
            
            self.photoScrollView2.picArr.removeAll()
            self.photoScrollView2.picArr.append(UIImage(named: "takePicture")!)

            for item in imageArr {
                self.photoScrollView2.picArr.append(item)
            }
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
    @IBAction func clickSingleBtn(_ sender: Any) {
        let imagePickTool = CLImagePickersTool()

        imagePickTool.singleImageChooseType = .singlePicture
        imagePickTool.isHiddenVideo = true
        
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,cutImage) in
            
        }
    }
    @IBAction func clickSinglebtn2(_ sender: Any) {
        
        let imagePickTool = CLImagePickersTool()
        
        imagePickTool.singleImageChooseType = .singlePictureCrop

        imagePickTool.setupImagePickerWith(MaxImagesCount: 1, superVC: self) { (asset,cutImage) in
            self.img3.image = cutImage
        }

    }
    @IBAction func clickJumpBtn(_ sender: Any) {
        let imagePickTool = CLImagePickersTool()
        
        imagePickTool.singleImageChooseType = .singlePictureCrop
        imagePickTool.singlePictureCropScale = 2  // 宽/高
        
        imagePickTool.setupImagePickerWith(MaxImagesCount: 1, superVC: self) { (asset,cutImage) in
            self.img3.image = cutImage
        }
    }
    @IBAction func clickOnlyBtn(_ sender: Any) {
        let imagePickTool = CLImagePickersTool()
        imagePickTool.onlyChooseImageOrVideo = true
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,cutImage) in
            
        }
    }
    @IBAction func clickMoreBtn(_ sender: Any) {
        let test = TestViewController.init(nibName: "TestViewController", bundle: nil)
        self.present(test, animated: true, completion: nil)
    }
}

