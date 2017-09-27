//
//  HDAlertWindowView.swift
//  ImageDeal
//
//  Created by darren on 2017/8/1.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class HDAlertWindowView: UIView {

    // 屏幕宽度
    @objc let APPH = UIScreen.main.bounds.height
    // 屏幕高度
    @objc let APPW = UIScreen.main.bounds.width
    
    @objc lazy var coverView: UIView = {
        let cover = UIView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height))
        cover.backgroundColor = UIColor(white: 0, alpha: 0.6)
        return cover
    }()
    
    @objc lazy var nomalView: NomalStyleView = {
        let bottom = NomalStyleView.show()
        self.addSubview(bottom)
        return bottom
    }()
    @objc lazy var messageView: MessageStyleView = {
        let bottom = MessageStyleView.show()
        self.addSubview(bottom)
        return bottom
    }()
    
    //MARK: - 展示控制器
    fileprivate func showVC() {
        UIApplication.shared.keyWindow?.addSubview(self.coverView)
        UIApplication.shared.keyWindow?.addSubview(self)
    }
    fileprivate func dismissView() {
        self.coverView.removeFromSuperview()
        self.removeFromSuperview()
    }
}

//MARK: - 标准样式(标题，内容，左按钮，右按钮)
extension HDAlertWindowView{
    @objc func  alert(title: String!,message: String!,leftTitle: String!,rightTitle: String!,leftHandler: (() -> ())?,rightHandler: (() -> ())?){
        
        // modal
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
        self.nomalView.center = self.center
        
        self.nomalView.leftHendle = { () in
            self.dismissView()
            if leftHandler != nil {
                leftHandler!()
            }
        }
        self.nomalView.rightHendle = { () in
            self.dismissView()
            if rightHandler != nil {
                rightHandler!()
            }
        }
    }
}

//MARK: - 一个主标题 (内容，左按钮，右按钮)
extension HDAlertWindowView{
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
        self.messageView.center = self.center
        
        if leftTitle == "" || rightTitle == ""{
            self.messageView.middleBtn.isHidden = false
            let title =  leftTitle == "" ? rightTitle:leftTitle
            self.messageView.middleBtn.setTitle(title, for: .normal)
        }
        
        self.messageView.middleHendle = { () in
            self.dismissView()
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
            self.dismissView()
            if leftHandler != nil {
                leftHandler!()
            }
        }
        self.messageView.rightHendle = { () in
            self.dismissView()
            if rightHandler != nil {
                rightHandler!()
            }
        }
    }
}
