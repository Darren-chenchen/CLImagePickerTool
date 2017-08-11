//
//  BaseBrush.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/19.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import CoreGraphics

//supportedContinuousDrawing，表示是否是连续不断的绘图
//drawInContext，基于Context的绘图方法，子类必须实现具体的绘图
//只要是实现了PaintBrush接口的类，我们就当作是一个绘图工具（如铅笔、直尺等）
protocol PaintBrush {
    
    func supportedContinuousDrawing() -> Bool
    
    func drawInContext(_ context: CGContext)
}

class BaseBrush : NSObject, PaintBrush {
    var beginPoint: CGPoint!
    var endPoint: CGPoint!
    var lastPoint: CGPoint?
    
    var strokeWidth: CGFloat!
    
    func supportedContinuousDrawing() -> Bool {
        return false
    }
    
    func drawInContext(_ context: CGContext) {
        assert(false, "must implements in subclass.")
    }
}

