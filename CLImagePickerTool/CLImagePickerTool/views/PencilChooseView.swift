//
//  PencilChooseView.swift
//  testDemoSwift
//
//  Created by 陈亮陈亮 on 2017/5/23.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

typealias clickPencilImageClouse = (UIImage) -> ()

class PencilChooseView: UIView {
    
    var scrollView: UIScrollView!
    
    var clickPencilImage: clickPencilImageClouse?
    
    var currentImage: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.8)
        
        scrollView = UIScrollView()
        scrollView?.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(scrollView!)
        
        let imageArr = ["clr_red","clr_orange","clr_blue","clr_green","clr_purple","clr_black"]
        
        let imgW: CGFloat = 20
        let imgH: CGFloat = 20
        let imgY: CGFloat = 0.5*(self.cl_height-imgH)
        let magin: CGFloat = (KScreenWidth-CGFloat(imageArr.count)*imgW)/CGFloat(imageArr.count+1)
        for i in 0..<imageArr.count {
            let imgX: CGFloat = magin + (magin+imgW)*CGFloat(i)
            let img = UIImageView.init(frame: CGRect(x: imgX, y: imgY, width: imgW, height: imgH))
            
            img.image = UIImage(named: imageArr[i], in: BundleUtil.getCurrentBundle(), compatibleWith: nil)
            img.isUserInteractionEnabled = true
            CLViewsBorder(img, borderWidth: 1.5, borderColor: UIColor.white, cornerRadius: 3)
            scrollView.addSubview(img)
            
            img.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(PencilChooseView.clickPencilImageView(tap:))))
            
            // 默认选中红色
            if i == 0 {
                self.currentImage = img
                self.currentImage?.alpha = 0.5
                CLViewsBorder(self.currentImage!, borderWidth: 0, borderColor: UIColor.white, cornerRadius: 3)
            }
        }
        
        scrollView.contentSize = CGSize(width: magin*CGFloat(imageArr.count+1)+imgW*CGFloat(imageArr.count)-KScreenWidth, height: 0)
    }
    
    func clickPencilImageView(tap:UITapGestureRecognizer) {
        if clickPencilImage != nil {
            
            self.currentImage?.alpha = 1
            CLViewsBorder(self.currentImage!, borderWidth: 1.5, borderColor: UIColor.white, cornerRadius: 3)
            
            let imageView = tap.view as! UIImageView
            imageView.alpha = 0.5
            CLViewsBorder(imageView, borderWidth: 0, borderColor: UIColor.white, cornerRadius: 3)
            
            self.currentImage = imageView

            self.clickPencilImage!(imageView.image!)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
