//
//  Test2ViewController.swift
//  CLImagePickerTool
//
//  Created by darren on 2017/11/17.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class Test2ViewController: UIViewController {

    let imagePickTool = CLImagePickersTool()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func clickBackBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickBtn1(_ sender: Any) {
        let imagePickTool = CLImagePickersTool()
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
        }
    }
}
