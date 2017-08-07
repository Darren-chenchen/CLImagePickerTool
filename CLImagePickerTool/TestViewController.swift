//
//  TestViewController.swift
//  CLImagePickerTool
//
//  Created by darren on 2017/8/4.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func clickBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func clickBtn2(_ sender: Any) {
        
        let imagePickTool = CLImagePickersTool()

        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,cutImage) in
        }
    }


}
