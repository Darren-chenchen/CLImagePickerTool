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
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // 相机在内部
    @IBAction func clickBtn1(_ sender: Any) {
        
        let imagePickTool = CLImagePickersTool()
        
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,cutImage) in
            print("返回的asset数组是\(asset)")
            
            let imageArr = CLImagePickersTool.convertAssetArrToImage(assetArr: asset, scale: 0.2)
            self.img.image = imageArr.first
            
            let imageArr2 = CLImagePickersTool.convertAssetArrToImage(assetArr: asset, scale: 1)
            self.img2.image = imageArr2.first
            
            if imageArr.first == nil {
                return
            }
            if imageArr2.first == nil {
                return
            }

            let imageData = UIImageJPEGRepresentation(imageArr.first!,1)!
            let imageData2 = UIImageJPEGRepresentation(imageArr2.first!,1)!
            self.label1.text = "压缩后\(String(describing: imageData))"
            self.label2.text = "压缩前\(String(describing: imageData2))"
        }
    }
    // 相机在外部
    @IBAction func clickBtn2(_ sender: Any) {
        
        let imagePickTool = CLImagePickersTool()
        
        imagePickTool.cameraOut = true

        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,cutImage) in
            print("返回的asset数组是\(asset)")
            
            let imageArr = CLImagePickersTool.convertAssetArrToImage(assetArr: asset, scale: 0.2)
            self.img.image = imageArr.first
            
            let imageArr2 = CLImagePickersTool.convertAssetArrToImage(assetArr: asset, scale: 1)
            self.img2.image = imageArr2.first
            
            if imageArr.first == nil {
                return
            }
            if imageArr2.first == nil {
                return
            }

            let imageData = UIImageJPEGRepresentation(imageArr.first!,1)!
            let imageData2 = UIImageJPEGRepresentation(imageArr2.first!,1)!
            self.label1.text = "压缩后\(String(describing: imageData))"
            self.label2.text = "压缩前\(String(describing: imageData2))"
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

