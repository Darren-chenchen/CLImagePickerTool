//
//  nomalStyleView.swift
//  testPop
//
//  Created by darren on 2017/6/28.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

typealias leftHendleClouse = () -> ()
typealias rightHendleClouse = () -> ()
typealias middleHendleClouse = () -> ()

class NomalStyleView: UIView {
    
    var leftHendle: leftHendleClouse?
    var rightHendle: rightHendleClouse?
    var middleHendle: middleHendleClouse?

    @IBOutlet weak var contentLableBottomYS: NSLayoutConstraint!
    @IBOutlet weak var btnsBottomView: UIView!
    @IBOutlet weak var rightBtn: UIButton!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    static func show() -> NomalStyleView {
        return BundleUtil.getCurrentBundle().loadNibNamed("NomalStyleView", owner: nil, options: nil)?.last as! NomalStyleView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
}
