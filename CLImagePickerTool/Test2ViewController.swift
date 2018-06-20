//
//  Test2ViewController.swift
//  CLImagePickerTool
//
//  Created by darren on 2017/11/17.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class Test2ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    let imagePickTool = CLImagePickerTool()
    let imagePickTool2 = CLImagePickerTool()
    let imagePickTool3 = CLImagePickerTool()
    let imagePickTool4 = CLImagePickerTool()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func clickBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickBtn1(_ sender: Any) {
        let imagePickTool = CLImagePickerTool()
        imagePickTool.setupImagePickerAnotherWayWith(maxImagesCount: 1, superVC: self) { (asserArr, img) in
            print("成功返回\(asserArr)")
        }
        
        /*
         *注意点
         1.该种类型目前只有3种属性可以控制显示
         imagePickTool.isHiddenVideo = true
         imagePickTool.isHiddenVideo = true
         imagePickTool.onlyChooseImageOrVideo = true
         2. 如果是在cell中或者指定的view中那么使用该方法拿到当前控制器即可
         imagePickTool.setupImagePickerAnotherWayWith(superVC: PopViewUtil.getCurrentViewcontroller()!)
         */
    }
    
    // 直接访问相机
    @IBAction func clickBtn2(_ sender: Any) {
        imagePickTool.camera(superVC: self)
        imagePickTool.clPickerToolClouse = {(assetArr,img) in
            print(assetArr)
            print(img ?? "nil")
            self.imageView.image = img
        }
    }
    @IBAction func clickBtn3(_ sender: Any) {
        imagePickTool2.cameraOut = true
        imagePickTool2.isHiddenVideo = true
        imagePickTool2.singleImageChooseType = .singlePicture
        imagePickTool2.singleModelImageCanEditor = true
        imagePickTool2.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,editorImage) in
            self.imageView.image = editorImage
        }
    }
    @IBAction func clickBtn4(_ sender: Any) {
        imagePickTool3.cameraOut = true
        imagePickTool3.isHiddenVideo = true
        imagePickTool3.singlePictureCropScale = 2
        imagePickTool3.singleImageChooseType = .singlePictureCrop
        imagePickTool3.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,editorImage) in
            self.imageView.image = editorImage
        }
    }
    @IBAction func clickBtn5(_ sender: Any) {
        imagePickTool4.cameraOut = true
        imagePickTool4.isHiddenVideo = true
        imagePickTool4.singleImageChooseType = .singlePictureCrop
        imagePickTool4.singlePictureCropScale = 230/144.5
        imagePickTool4.singleModelImageCanEditor = true
        imagePickTool4.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,editorImage) in
            self.imageView.image = editorImage
        }
    }
}
