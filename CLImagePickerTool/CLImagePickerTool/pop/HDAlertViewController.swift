//
//  HDAlertViewController.swift
//  testPop
//
//  Created by darren on 2017/6/28.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class HDAlertViewController: UIViewController {
    
    // 屏幕宽度
    @objc let APPH = UIScreen.main.bounds.height
    // 屏幕高度
    @objc let APPW = UIScreen.main.bounds.width
    
    @objc lazy var nomalView: NomalStyleView = {
        let bottom = NomalStyleView.show()
        self.view.addSubview(bottom)
        return bottom
    }()
    @objc lazy var messageView: MessageStyleView = {
        let bottom = MessageStyleView.show()
        self.view.addSubview(bottom)
        return bottom
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
    }
    
    //MARK: - 展示控制器
    fileprivate func showVC() {
        let currentVC = PopViewUtil.getCurrentViewcontroller()
        self.modalPresentationStyle = .overFullScreen
        currentVC?.present(self, animated: false, completion: nil)
    }
}

//MARK: - 标准样式(标题，内容，左按钮，右按钮)
extension HDAlertViewController{
    @objc func  alert(title: String!,message: String!,leftTitle: String!,rightTitle: String!,leftHandler: (() -> ())?,rightHandler: (() -> ())?){
        
        // modal 控制器
        showVC()
        
        // 调整弹出框的尺寸、位置，赋值
        self.nomalView.titleLabel.text = title
        self.nomalView.contentLabel.text = message
        self.nomalView.leftBtn.setTitle(leftTitle, for: .normal)
        self.nomalView.rightBtn.setTitle(rightTitle, for: .normal)
        
        // 宽度的设置要在layoutIfNeeded方法之前
//        self.nomalView.hd_width = 100

        // 赋值后注意重新布局一下，不然如果xib中lable没有设置文字，view的尺寸会不对
        self.nomalView.layoutIfNeeded()
        
        self.nomalView.frame.size.height = self.nomalView.contentLabel.frame.maxY + self.nomalView.btnsBottomView.frame.height + self.nomalView.contentLableBottomYS.constant
        self.nomalView.center = self.view.center
        
        self.nomalView.leftHendle = { () in
            self.dismiss(animated: false, completion: nil)
            if leftHandler != nil {
                leftHandler!()
            }
        }
        self.nomalView.rightHendle = { () in
            self.dismiss(animated: false, completion: nil)
            if rightHandler != nil {
                rightHandler!()
            }
        }
    }
}

//MARK: - 一个主标题 (内容，左按钮，右按钮)
extension HDAlertViewController{
    @objc func  alert(message: String!,leftTitle: String!,rightTitle: String!,leftHandler: (() -> ())?,rightHandler: (() -> ())?){
        
        // modal 控制器
        showVC()
        
        // 调整弹出框的尺寸、位置，赋值
        self.messageView.contentLabel.text = message
        self.messageView.leftBtn.setTitle(leftTitle, for: .normal)
        self.messageView.rightBtn.setTitle(rightTitle, for: .normal)
        
        // 宽度的设置要在layoutIfNeeded方法之前
//        self.messageView.hd_width = 100
        // 赋值后注意重新布局一下，不然如果xib中lable没有设置文字，view的尺寸会不对
        self.messageView.layoutIfNeeded()
        
        self.messageView.frame.size.height = self.messageView.contentLabel.frame.maxY + self.messageView.btnsBottomView.frame.height + self.messageView.contentLableBottomYS.constant
        self.messageView.center = self.view.center
        
        if leftTitle == "" || rightTitle == ""{
            self.messageView.middleBtn.isHidden = false
            let title =  leftTitle == "" ? rightTitle:leftTitle
            self.messageView.middleBtn.setTitle(title, for: .normal)
        }
        
        self.messageView.middleHendle = { () in
            self.dismiss(animated: false, completion: nil)
            if leftTitle == "" {
                if rightHandler != nil {
                    rightHandler!()
                }
            }
            if rightTitle == "" {
                if leftHandler != nil {
                    leftHandler!()
                }
            }
        }
        self.messageView.leftHendle = { () in
            self.dismiss(animated: false, completion: nil)
            if leftHandler != nil {
                leftHandler!()
            }
        }
        self.messageView.rightHendle = { () in
            self.dismiss(animated: false, completion: nil)
            if rightHandler != nil {
                rightHandler!()
            }
        }
    }
}

