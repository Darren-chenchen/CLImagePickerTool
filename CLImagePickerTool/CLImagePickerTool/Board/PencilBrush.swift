//
//  PencilBrush.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/19.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
// 铅笔工具

import UIKit

class PencilBrush: BaseBrush {
    //如果lastPoint为nil，则基于beginPoint画线，反之则基于lastPoint画线。
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
