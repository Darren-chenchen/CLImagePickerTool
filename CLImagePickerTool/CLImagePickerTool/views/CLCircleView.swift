//
//  CLCircleView.swift
//  ImageDeal
//
//  Created by darren on 2017/8/1.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit


class CLCircleView: UIButton {

    @objc var value: CGFloat = 0 {
        didSet {
            if value >= 100 {
               self.value = 100
            }
            self.setNeedsDisplay()
        }
    }
    
    @objc var maximumValue: CGFloat = 100
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    @objc func setupUI() {
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        
        //线宽度
        let lineWidth: CGFloat = 10
        //半径
        let radius:CGFloat = rect.width/2-lineWidth
        //中心点x
        let centerX = rect.midX
        //中心点y
        let centerY = rect.midY
        //弧度起点
        let startAngle = CGFloat(-90 * Double.pi / 180)
        //弧度终点
        let endAngle = CGFloat(((self.value / self.maximumValue) * 360.0 - 90.0) ) * CGFloat(Double.pi) / 180.0
        
        //创建一个画布
        let context = UIGraphicsGetCurrentContext()
        
        //画笔颜色
        context!.setStrokeColor(UIColor.white.cgColor)
        context?.setFillColor(UIColor.white.cgColor)
        //画笔宽度
        context!.setLineWidth(lineWidth)
        
        //（1）画布 （2）中心点x（3）中心点y（4）圆弧起点（5）圆弧结束点（6） 0顺时针 1逆时针
        context?.addArc(center: CGPoint(x:centerX,y:centerY), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        //绘制路径
        context!.strokePath()
        
    }
}
