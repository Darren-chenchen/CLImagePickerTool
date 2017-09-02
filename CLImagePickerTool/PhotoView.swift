//
//  PhotoView.swift
//  paso-ios
//
//  Created by 陈亮陈亮 on 2017/6/19.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

typealias CloseBtnClickClouse = ([UIImage])->()

class PhotoView: UIView {
    
    
    var closeBtnClickClouse: CloseBtnClickClouse?
    
    var picStrArr = [String]()  // 在实际的项目中可能用于存储图片的url

    var imgView: UIImageView!
    var scrollView: UIScrollView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    fileprivate func setupUI() {
        self.scrollView = UIScrollView.init(frame: self.bounds)
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(self.scrollView)
    }
    
    /// 设置图片数组
    var picArr = [UIImage]() {
        didSet{

            for view in self.scrollView.subviews {
                view.removeFromSuperview()
            }
            
            let magin: CGFloat = 5
            let imageW: CGFloat = 80
            let imageH: CGFloat = imageW
            
            for i in 0..<picArr.count {
                let imageView = UIImageView()
                let imageX: CGFloat = magin + (magin + imageW)*CGFloat(i)
                let imageY: CGFloat = 0
                imageView.frame =  CGRect(x:imageX, y:imageY, width:imageW, height:imageH)
                imageView.contentMode = UIViewContentMode.scaleAspectFill
                imageView.clipsToBounds = true
                imageView.isUserInteractionEnabled  = true
                imageView.image = picArr[i]
                
                self.imgView = imageView
                self.scrollView.addSubview(imageView)
                if (i==(picArr.count-1)) {
                    imageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(clickChooseImage)))
                }
                
                // 加一个关闭按钮
                let closeBtn = UIButton.init(frame: CGRect(x: self.imgView.cl_width-20, y: 0, width: 20, height: 20))
                closeBtn.tag = i
                if (i != 0) {
                    closeBtn.setBackgroundImage(UIImage(named:"close"), for: .normal)
                    closeBtn.addTarget(self, action: #selector(clickCloseBtn(btn:)), for: .touchUpInside)
                    self.imgView.addSubview(closeBtn)
                }
            }
            if (picArr.count>=2) {
                self.scrollView.contentSize = CGSize(width:CGFloat(picArr.count)*imageW + CGFloat((picArr.count+1)*5), height:0);
            } else {
                self.scrollView.contentSize = CGSize(width:0, height:0);
            }

        }
    }
    
    /// 关闭按钮
    func clickCloseBtn(btn:UIButton) {
        self.picArr.remove(at: btn.tag)
        
        if self.closeBtnClickClouse != nil {
            self.closeBtnClickClouse!(self.picArr)
        }
    }
    
    /// 选择相册
    func clickChooseImage() {
      
    }
    
    /// 隐藏关闭按钮用于纯展示
    var hiddenAllCloseBtn = false {
        didSet{
            if hiddenAllCloseBtn == true {
                for view in self.scrollView.subviews {
                    for btnView in view.subviews {
                        if btnView.classForCoder == UIButton.self {
                            btnView.isHidden = true
                        }
                    }
                }
                
            }
        }
    }

}
