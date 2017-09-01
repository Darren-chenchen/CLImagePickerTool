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
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img: UIImageView!
    
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn1: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.btn1.titleLabel?.numberOfLines = 0
        self.btn2.titleLabel?.numberOfLines = 0
        self.btn1.sizeToFit()
        self.btn2.sizeToFit()
    }

    // 相机在内部
    @IBAction func clickBtn1(_ sender: Any) {
        
        let imagePickTool = CLImagePickersTool()
        
        imagePickTool.setupImagePickerWith(MaxImagesCount: 10, superVC: self) { (asset,cutImage) in
            print("返回的asset数组是\(asset)")
            
            // 获取原图，耗时较长
            // scale 指定压缩比
            let imageArr = CLImagePickersTool.convertAssetArrToImage(assetArr: asset, scale: 0.1)
            
            print(imageArr)
        }
    }
    @IBAction func clickBtnTh(_ sender: Any) {
        let imagePickTool = CLImagePickersTool()
        imagePickTool.setupImagePickerWith(MaxImagesCount: 10, superVC: self) { (asset,cutImage) in
            print("返回的asset数组是\(asset)")

            //获取缩略图，耗时较短
            let imageArr = CLImagePickersTool.convertAssetArrToThumbnailImage(assetArr: asset, targetSize: CGSize(width: 80, height: 80))
            print(imageArr)
            self.img.image = imageArr.first
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

