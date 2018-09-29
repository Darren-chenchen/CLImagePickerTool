//
//  CustomNavgationView.swift
//  CloudscmSwift
//
//  Created by 陈亮陈亮 on 2017/5/16.
//  Copyright © 2017年 RexYoung. All rights reserved.
//

import UIKit

class CustomNavgationView: UIView {

    @objc lazy var titleLable:UILabel = {
        let titleLable = UILabel()
        titleLable.textAlignment = .center
        titleLable.textColor = UIColor.black
        titleLable.font = UIFont.boldSystemFont(ofSize: 18)
        return titleLable
    }()
    @objc lazy var navLine:UIView = {
        let navLine = UIView()
        navLine.backgroundColor = UIColor.gray
        return navLine;
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.titleLable)
        self.addSubview(self.navLine)
        self.backgroundColor = UIColor.clear
        
        initEventHendle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
    func initEventHendle() {
        self.titleLable.translatesAutoresizingMaskIntoConstraints = false
        self.navLine.translatesAutoresizingMaskIntoConstraints = false

        let titleY: CGFloat = UIDevice.current.isX() == true ? 40:20
        self.titleLable.addConstraint(NSLayoutConstraint.init(item: self.titleLable, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 44))
        self.addConstraints([
            NSLayoutConstraint.init(item: self.titleLable, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 50),
            NSLayoutConstraint.init(item: self.titleLable, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: titleY),
            NSLayoutConstraint.init(item: self.titleLable, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -50)
            ])
        
        self.navLine.addConstraint(NSLayoutConstraint.init(item: self.navLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 0.5))
        self.addConstraints([
            NSLayoutConstraint.init(item: self.navLine, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: self.navLine, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: self.navLine, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
            ])
    }
    override func layoutSubviews() {
    }
}
