//
//  messageStyleView.swift
//  testPop
//
//  Created by darren on 2017/6/28.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class MessageStyleView: UIView {
    var leftHendle: leftHendleClouse?
    var rightHendle: rightHendleClouse?
    var middleHendle: middleHendleClouse?

    @IBOutlet weak var middleBtn: UIButton!
    @IBOutlet weak var contentLableBottomYS: NSLayoutConstraint!
    @IBOutlet weak var btnsBottomView: UIView!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    
    static func show() -> MessageStyleView {
        return BundleUtil.getCurrentBundle().loadNibNamed("MessageStyleView", owner: nil, options: nil)?.last as! MessageStyleView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    @IBAction func clickRightBtn(_ sender: Any) {
        if rightHendle != nil {
            rightHendle!()
        }
        
    }
    @IBAction func clickLeftBtn(_ sender: Any) {
        if leftHendle != nil {
            leftHendle!()
        }
        
    }

    @IBAction func clickMiddleBtn(_ sender: Any) {
        if middleHendle != nil {
            middleHendle!()
        }
    }

}
