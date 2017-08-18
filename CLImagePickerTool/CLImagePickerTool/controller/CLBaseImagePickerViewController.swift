//
//  BaseNavViewController.swift
//  CloudscmSwift
//
//  Created by Darren on 17/5/2.
//  Copyright © 2017年 RexYoung. All rights reserved.
//

import UIKit

class CLBaseImagePickerViewController: UIViewController {
    
    // 自定义导航栏
    lazy var customNavBar: CustomNavgationView = {
        let nav = CustomNavgationView()
        nav.frame = CGRect(x: 0, y: 0, width: KScreenWidth, height: 64)
        return nav
    }()
    // 右边第一个按钮
    lazy var rightBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: KScreenWidth-64, y: 20, width: 64, height: 44);
        btn.adjustsImageWhenHighlighted = false
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(CLBaseImagePickerViewController.rightBtnClick), for: UIControlEvents.touchUpInside)
        return btn
    }()
    // 标题
    var navTitle = "" {
        didSet{
            customNavBar.titleLable.text = navTitle
        }
    }
    // 返回按钮
    lazy var backBtn: UIButton = {
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 20, width: 50, height: 44);
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 0)
        btn.setImage(UIImage(named: "btn_back2", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for:UIControlState())
        btn.addTarget(self, action: #selector(CLBaseImagePickerViewController.backBtnclick), for: .touchUpInside)
        return btn
    }()
    
    lazy var toobar: UIToolbar = {
        // 添加磨玻璃
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: 64))
        toolBar.barStyle = .default
        return toolBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.automaticallyAdjustsScrollViewInsets = false;
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.isTranslucent = false
        
        self.setupNav()
    }
    
    // 先不要写在initview中，因为如果写在initview中就需要在子类中必须实现initView方法，并且调用super.initView()
    fileprivate func setupNav(){
        // 添加导航栏
        self.view.addSubview(self.customNavBar)
        // 右边按钮
        self.customNavBar.addSubview(self.rightBtn)
        // 毛玻璃效果
        self.customNavBar.addSubview(self.toobar)
        self.customNavBar.sendSubview(toBack: self.toobar)
        
        self.customNavBar.addSubview(self.backBtn)
        self.backBtn.isHidden = true
    }
    
    func rightBtnClick(){
        
    }
    func backBtnclick(){
        
    }
}

