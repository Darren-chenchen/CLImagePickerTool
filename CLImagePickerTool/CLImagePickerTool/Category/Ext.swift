//
//  Ext.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/22.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

extension UIImage {
    // 对截取的长图进行压缩，因为项目中的长图是设置为背景颜色，如果不压缩到适当的尺寸图片就会平铺
    @objc static func scaleImage(image: UIImage) -> UIImage {
        let picBili: CGFloat = image.size.width/image.size.height

        // 图片大小   UIScreen.main.scale屏幕密度，不加这个图片会不清晰
        UIGraphicsBeginImageContextWithOptions(CGSize(width:KScreenWidth,height:KScreenWidth/picBili), false, UIScreen.main.scale)
        
        image.draw(in: CGRect(x: 0, y:0 , width: KScreenWidth, height: KScreenWidth/picBili))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    // 截取一部分
    @objc static func screenShotForPart(view:UIView,size:CGSize) -> UIImage{
        var image = UIImage()
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    // 生成马赛克图片
    @objc static func transToMosaicImage(orginImage: UIImage,level: NSInteger) -> UIImage{
        
        
        let context: CIContext = CIContext.init()
        let filter = CIFilter(name: "CIPixellate")!
        let inputImage = CIImage(image: orginImage)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(level, forKey: kCIInputScaleKey) //值越大马赛克就越大(使用默认)
        let fullPixellatedImage = filter.outputImage
        let cgImage = context.createCGImage(fullPixellatedImage!,from: fullPixellatedImage!.extent)
        return UIImage.init(cgImage: cgImage!)
    }
    
    //创建打码区域
    @objc func createMaskImage(rect: CGRect ,centerX: CGFloat, centerY: CGFloat, radius:CGFloat)-> CIImage{
        let radialGradient = CIFilter(name: "CIRadialGradient",withInputParameters: ["inputRadius0" : radius,"inputRadius1" : radius + 1,"inputColor0" : CIColor(red: 0, green: 1, blue: 0, alpha: 1),"inputColor1" : CIColor(red: 0, green: 0, blue: 0, alpha: 0),kCIInputCenterKey : CIVector(x: centerX, y: centerY)])
        let radialGradientOutputImage = radialGradient!.outputImage!.cropped(to: rect)
        return radialGradientOutputImage
    }

}
extension UIView {
    
    /// x
    @objc var cl_x: CGFloat {
        get {
            return frame.origin.x
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.x    = newValue
            frame                 = tempFrame
        }
    }
    
    /// y
    @objc var cl_y: CGFloat {
        get {
            return frame.origin.y
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.origin.y    = newValue
            frame                 = tempFrame
        }
    }
    
    /// height
    @objc var cl_height: CGFloat {
        get {
            return frame.size.height
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size.height = newValue
            frame                 = tempFrame
        }
    }
    
    /// width
    @objc var cl_width: CGFloat {
        get {
            return frame.size.width
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size.width = newValue
            frame = tempFrame
        }
    }
    
    /// size
    @objc var cl_size: CGSize {
        get {
            return frame.size
        }
        set(newValue) {
            var tempFrame: CGRect = frame
            tempFrame.size = newValue
            frame = tempFrame
        }
    }
    
    /// centerX
    @objc var cl_centerX: CGFloat {
        get {
            return center.x
        }
        set(newValue) {
            var tempCenter: CGPoint = center
            tempCenter.x = newValue
            center = tempCenter
        }
    }
    
    /// centerY
    @objc var cl_centerY: CGFloat {
        get {
            return center.y
        }
        set(newValue) {
            var tempCenter: CGPoint = center
            tempCenter.y = newValue
            center = tempCenter;
        }
    }
    
}

extension UIDevice {
    @objc public func isX() -> Bool {
        if UIScreen.main.bounds.height == 812 {
            return true
        }
        
        return false
    }
    
    @objc public func isIOS11() -> Bool{
        if #available(iOS 11.0, *) {
            return true
        } else {
            return false
        }
    }
}
