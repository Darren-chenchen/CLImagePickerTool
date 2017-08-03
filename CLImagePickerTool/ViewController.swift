//
//  ViewController.swift
//  CLImagePickerTool
//
//  Created by darren on 2017/8/3.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // 相机在内部
    @IBAction func clickBtn1(_ sender: Any) {
        CLImagePickersTool.share.setupImagePickerWith(MaxImagesCount: 6, cameraOut: false, superVC: self) { (asset) in
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
        CLImagePickersTool.share.setupImagePickerWith(MaxImagesCount: 6, cameraOut: true, superVC: self) { (asset) in
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
}

