//
//  EraserBrush.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/19.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
// 橡皮擦

import UIKit

class EraserBrush: PencilBrush {
    override func drawInContext(_ context: CGContext) {
        context.setBlendMode(CGBlendMode.clear)
        
        super.drawInContext(context)
    }
}
