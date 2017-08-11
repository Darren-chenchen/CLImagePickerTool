//
//  DrawBoard.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/19.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
// 参考：http://blog.csdn.net/zhangao0086/article/details/43836789

import UIKit

// 开始编辑就改变撤销按钮的状态，让其可以点击
typealias beginDrawClouse = () -> ()
// 当撤销到第一张图片，
typealias undoUnableActionClouse = () -> ()
// 前进到最后一张图片就让按钮不可点击
typealias redoUnableActionClouse = () -> ()

enum DrawingState {
    case began, moved, ended
}

class DrawBoard: UIImageView {
    
    // 开始绘画就让控制器中的返回按钮可点击
    var beginDraw: beginDrawClouse?
    // 不能再撤销或者前进
    var unableDraw: undoUnableActionClouse?
    var reableDraw: redoUnableActionClouse?
    
    fileprivate var boardUndoManager = DBUndoManager() // 缓存或Undo控制器
    var canUndo: Bool {
        get {
            return self.boardUndoManager.canUndo
        }
    }
    
    var canRedo: Bool {
        get {
            return self.boardUndoManager.canRedo
        }
    }
    
    // 绘图状态
    fileprivate var drawingState: DrawingState!
    // 绘图的基类
    var brush: BaseBrush?
    //保存当前的图形
    fileprivate var realImage: UIImage?
    var strokeWidth: CGFloat = 3
    // 画笔颜色，文本输入框的字体颜色
    var strokeColor: UIColor = UIColor.red
    // 和马赛克相关的图片
    var masicImage: UIImage!
    // 高斯模糊
    var strokeGauussianColor: UIColor = UIColor.clear

    // 橡皮擦效果图片
    lazy var eraserImage: UIImageView = {
        let img = UIImageView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.addSubview(img)
        return img
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.lastPoint = nil
            
            brush.beginPoint = touches.first!.location(in: self)
            brush.endPoint = brush.beginPoint
            
            self.drawingState = .began
            
            // 如果是橡皮擦，展示橡皮擦的效果
            if self.brush?.classForKeyedArchiver == EraserBrush.classForCoder() {
                self.eraserImage.isHidden = false
                let imageW = self.strokeWidth*10
                self.eraserImage.frame = CGRect(origin: brush.beginPoint, size: CGSize(width: imageW, height: imageW))
                self.eraserImage.layer.cornerRadius = imageW*0.5
                self.eraserImage.layer.masksToBounds = true
                self.eraserImage.backgroundColor = mainColor
            }
            
            // 如果是文本输入就展示文本，其他的是绘图
            if self.brush?.classForKeyedArchiver == InputBrush.classForCoder()  {
            } else {
                self.drawingImage()
                if beginDraw != nil {
                    self.beginDraw!()
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = touches.first!.location(in: self)
            
            self.drawingState = .moved
            // 如果是橡皮擦，展示橡皮擦的效果
            if self.brush?.classForKeyedArchiver == EraserBrush.classForCoder() {
                let imageW = self.strokeWidth*10
                self.eraserImage.frame = CGRect(origin: brush.endPoint, size: CGSize(width: imageW, height: imageW))
            }
            
            if self.brush?.classForKeyedArchiver == InputBrush.classForCoder()  {
            } else {
                self.drawingImage()

            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = nil
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let brush = self.brush {
            brush.endPoint = touches.first!.location(in: self)
            
            self.drawingState = .ended
            
            // 如果是橡皮擦，展示橡皮擦的效果
            if self.brush?.classForKeyedArchiver == EraserBrush.classForCoder() {
                self.eraserImage.isHidden = true
            }
            if self.brush?.classForKeyedArchiver == InputBrush.classForCoder()  {
            } else {
                self.drawingImage()

            }
        }
    }
    //MARK: - 返回画板上的图片，用于保存
    func takeImage() -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        self.backgroundColor?.setFill()
        UIRectFill(self.bounds)
        
        self.image?.draw(in: self.bounds)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        return image!
    }
    
    // 撤销
    func undo() {
        if self.canUndo == false {
            return
        }
        self.image = self.boardUndoManager.imageForUndo()
        self.realImage = self.image
        
        // 已经撤销到第一张图片
        if self.boardUndoManager.index == -1 {
            if self.unableDraw != nil {
                self.unableDraw!()
            }
        }
    }
    // 前进
    func redo() {
        if self.canRedo == false {
            return
        }
        self.image = self.boardUndoManager.imageForRedo()
        self.realImage = self.image
        
        // 已经撤前进到最后一张图片
        if self.boardUndoManager.index == self.boardUndoManager.imageArray.count-1 {
            if self.reableDraw != nil {
                self.reableDraw!()
            }
        }
    }
    // 还原
    func retureAction() {
        self.image = nil
        self.realImage = self.image
        
        
    }
    
    // 是否可以撤销
    func canBack() -> Bool {
        return self.canUndo
    }
    // 是否可以前进
    func canForward() -> Bool {
        return self.canRedo
    }
    deinit {
        //移除通知
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension DrawBoard {
    
    // MARK: - drawing
    fileprivate func drawingImage() {
        if let brush = self.brush {
            
            // 1.开启一个新的ImageContext，为保存每次的绘图状态作准备。
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
            
            // 2.初始化context，进行基本设置（画笔宽度、画笔颜色、画笔的圆润度等）。
            let context = UIGraphicsGetCurrentContext()
            
            UIColor.clear.setFill()
            UIRectFill(self.bounds)
            
            context?.setLineCap(CGLineCap.round)
            context?.setLineWidth(self.strokeWidth)
            context?.setStrokeColor(self.strokeColor.cgColor)
            
            if self.brush?.classForKeyedArchiver == GaussianBlurBrush.classForCoder()  {
                context?.setLineWidth(self.strokeWidth*10)
                context?.setStrokeColor(self.strokeGauussianColor.cgColor)
            }
            
            if self.brush?.classForKeyedArchiver == EraserBrush.classForCoder()  {
                context?.setLineWidth(self.strokeWidth*10)
                context?.setStrokeColor(self.strokeGauussianColor.cgColor)
            }
            
            // 马赛克
            if self.brush?.classForKeyedArchiver == RectangleBrush.classForCoder()  {
                context?.setLineWidth(30)
                context?.setStrokeColor(UIColor.init(patternImage: self.masicImage).cgColor)
            }
            
            // 3.把之前保存的图片绘制进context中。
            if let realImage = self.realImage {
                realImage.draw(in: self.bounds)
            }
            
            // 4.设置brush的基本属性，以便子类更方便的绘图；调用具体的绘图方法，并最终添加到context中。
            brush.strokeWidth = self.strokeWidth
            brush.drawInContext(context!)
            context?.strokePath()
            
            // 5.从当前的context中，得到Image，如果是ended状态或者需要支持连续不断的绘图，则将Image保存到realImage中。
            let previewImage = UIGraphicsGetImageFromCurrentImageContext()
            if self.drawingState == .ended || brush.supportedContinuousDrawing() {
                self.realImage = previewImage
            }
            UIGraphicsEndImageContext()
            // 6.实时显示当前的绘制状态，并记录绘制的最后一个点
            self.image = previewImage;
            
            // 用 Ended 事件代替原先的 Began 事件
            if self.drawingState == .ended {
                // 如果是第一次绘制,同时让前进按钮处于不可点击状态
                if self.boardUndoManager.index == -1 {
                    if self.reableDraw != nil {
                        self.reableDraw!()
                    }
                }
                self.boardUndoManager.addImage(self.image!)
            }
            
            brush.lastPoint = brush.endPoint
        }
    }
}

