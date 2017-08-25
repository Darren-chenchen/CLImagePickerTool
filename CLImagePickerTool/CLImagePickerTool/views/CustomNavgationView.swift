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
        self.titleLable.frame = CGRect(x: 50, y: 20, width: KScreenWidth-100, height: 64-20);
        self.navLine.frame = CGRect(x: 0, y: 64, width: KScreenWidth, height: 0.26);
    }
}
