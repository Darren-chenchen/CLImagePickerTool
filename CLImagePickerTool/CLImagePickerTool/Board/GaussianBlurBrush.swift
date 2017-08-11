//
//  RectangleBrush.swift
//  DrawingBoard
//
//  Created by ZhangAo on 15-2-16.
//  Copyright (c) 2015年 zhangao. All rights reserved.
// 高斯模糊

import UIKit

class GaussianBlurBrush: BaseBrush {
    
    override func drawInContext(_ context: CGContext) {
        
        if let lastPoint = self.lastPoint {
            context.move(to: CGPoint(x: lastPoint.x, y: lastPoint.y))
            context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
        } else {
            context.move(to: CGPoint(x: beginPoint.x, y: beginPoint.y))
            context.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
        }
    }
    
    override func supportedContinuousDrawing() -> Bool {
        return true
    }
}
