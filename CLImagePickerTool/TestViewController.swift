//
//  TestViewController.swift
//  CLImagePickerTool
//
//  Created by darren on 2017/8/4.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var clipImage: UIImageView!
    @IBOutlet weak var img: UIImageView!
    let imagePickTool = CLImagePickersTool()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func clickBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickSinglebtn(_ sender: Any) {
        let imagePickTool = CLImagePickersTool()
        imagePickTool.singleImageChooseType = .singlePicture
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,editorImage) in
        }

    }
    
    
    @IBAction func clickSingleBtn2(_ sender: Any) {
        let imagePickTool = CLImagePickersTool()
        imagePickTool.singleImageChooseType = .singlePictureCrop
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,editorImage) in
            self.clipImage.image = editorImage
        }

    }
    
    @IBAction func clickSingleBtn3(_ sender: Any) {
        let imagePickTool = CLImagePickersTool()
        imagePickTool.singleImageChooseType = .singlePictureCrop
        imagePickTool.singlePictureCropScale = 2
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,editorImage) in
            self.clipImage.image = editorImage
        }
        

    }

    @IBAction func clickBtn2(_ sender: Any) {
        
        let imagePickTool = CLImagePickersTool()
        imagePickTool.singleImageChooseType = .singlePicture
        imagePickTool.singleModelImageCanEditor = true
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,editorImage) in
            
            self.img.image = editorImage
        }
    }
    
    
    @IBAction func clickOnlyBtn(_ sender: Any) {
        let imagePickTool = CLImagePickersTool()
        imagePickTool.onlyChooseImageOrVideo = true
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,editorImage) in
        }

    }

    // 隐藏图片文件，展示视频文件
    @IBAction func clickBtn3(_ sender: Any) {
        let imagePickTool = CLImagePickersTool()
        imagePickTool.isHiddenImage = true
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,editorImage) in
            
        }
    }

    @IBAction func clickBtn4(_ sender: Any) {
        let imagePickTool = CLImagePickersTool()
        imagePickTool.navColor = UIColor.red
        imagePickTool.navTitleColor = UIColor.white
        imagePickTool.statusBarType = .white
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,editorImage) in
            
        }
    }
    @IBAction func clickBtn5(_ sender: Any) {
        let test2 = Test2ViewController.init(nibName: "Test2ViewController", bundle: nil)
        self.present(test2, animated: true, completion: nil)
    }
    @IBAction func clickBtn6(_ sender: Any) {
        imagePickTool.cameraOut = true
        imagePickTool.isHiddenVideo = true
        imagePickTool.singleImageChooseType = .singlePictureCrop
        imagePickTool.singlePictureCropScale = 230/144.5
        imagePickTool.setupImagePickerWith(MaxImagesCount: 1, superVC: self) { (asset,editorImage) in
            self.clipImage.image = editorImage
        }
    }
}
