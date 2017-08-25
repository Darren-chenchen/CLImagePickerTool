//
//  TestViewController.swift
//  CLImagePickerTool
//
//  Created by darren on 2017/8/4.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var img: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func clickBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func clickBtn2(_ sender: Any) {
        
        let imagePickTool = CLImagePickersTool()
        imagePickTool.singleImageChooseType = .singlePicture
        imagePickTool.singleModelImageCanEditor = true
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,editorImage) in
            
            self.img.image = editorImage
        }
    }

    // 隐藏图片文件，展示视频文件
    @IBAction func clickBtn3(_ sender: Any) {
        let imagePickTool = CLImagePickersTool()
        imagePickTool.isHiddenImage = true
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,editorImage) in
            
        }
    }

}
