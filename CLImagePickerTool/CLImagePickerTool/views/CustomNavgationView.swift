//
//  CustomNavgationView.swift
//  CloudscmSwift
//
//  Created by 陈亮陈亮 on 2017/5/16.
//  Copyright © 2017年 RexYoung. All rights reserved.
//

import UIKit

class CustomNavgationView: UIView {

    lazy var titleLable:UILabel = {
        let titleLable = UILabel()
        titleLable.textAlignment = .center
        titleLable.textColor = UIColor.black
        titleLable.font = UIFont.boldSystemFont(ofSize: 18)
        return titleLable
    }()
    lazy var navLine:UILabel = {
        let navLine = UILabel()
        navLine.backgroundColor = UIColor.gray
        return navLine;
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
       
        self.addSubview(self.titleLable)
        self.addSubview(self.navLine)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
    
    override func layoutSubviews() {
        let titleY: CGFloat = UIDevice.current.isX() == true ? 40:20
        self.titleLable.frame = CGRect(x: 50, y: titleY, width: KScreenWidth-100, height: 44)
        self.navLine.frame = CGRect(x: 0, y: KNavgationBarHeight, width: KScreenWidth, height: 0.26)
    }
}
