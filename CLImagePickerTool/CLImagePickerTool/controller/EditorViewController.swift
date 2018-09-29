//
//  EditorViewController.swift
//  paso-ios
//
//  Created by 陈亮陈亮 on 2017/6/19.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

typealias editorImageCompleteClouse = (UIImage)->()

class EditorViewController: UIViewController {
    
    @objc var editorImageComplete: editorImageCompleteClouse?
    
    @IBOutlet weak var BottomViewHYS: NSLayoutConstraint!
    @IBOutlet weak var TopViewHYS: NSLayoutConstraint!
    @IBOutlet weak var sureBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
   // 底部控件
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    // 下一步
    @objc var forwardBtn: UIButton!
    // 上一步
    @objc var goBackBtn: UIButton!
    // 涂鸦
    @objc var pencilBtn: UIButton!
    // 橡皮擦
    @objc var eraserBtn: UIButton!
    // 马赛克
    @objc var masicBtn: UIButton!
    // 画板
    @objc var drawBoardImageView: DrawBoard!
    // 需要编辑的图片
    @objc var editorImage: UIImage!
    
    @objc lazy var choosePencilView: PencilChooseView = {
        let chooseView = PencilChooseView.init(frame: CGRect(x: 0, y: KScreenHeight, width: KScreenWidth, height: 40))
        chooseView.clickPencilImage = {[weak self] (img:UIImage) in
            self?.drawBoardImageView.strokeColor = UIColor(patternImage: img)
        }
        return chooseView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func clickSureBtn(_ sender: Any) {
        
        if self.editorImageComplete != nil {
            self.editorImageComplete!(self.drawBoardImageView.takeImage())
        }
        
    }
    
    @IBAction func clickBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK: - 选择画笔颜色
    @objc func showPencilView(){
        self.view.addSubview(self.choosePencilView)
        self.view.bringSubview(toFront: self.bottomView)
        self.choosePencilView.cl_y = self.bottomView.cl_y
        UIView.animate(withDuration: 0.3, animations: { 
            self.choosePencilView.cl_y = self.bottomView.cl_y-40
        }) { (comp) in
        }
    }
    //MARK: - 选择画笔结束
    @objc func choosePencilViewDismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.choosePencilView.cl_y = KScreenHeight
        }) { (true) in
            self.choosePencilView.removeFromSuperview()
        }
    }
}
//MARK: - 界面相关
extension EditorViewController {
    fileprivate func initView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 10
        
        self.TopViewHYS.constant = UIDevice.current.isX() == true ? 44+44:44
        self.BottomViewHYS.constant = UIDevice.current.isX() == true ? 50+34:50

        
        self.cancelBtn.setTitle(cancelStr, for: .normal)
        self.sureBtn.setTitle(sureStr, for: .normal)
        
        let scaleImage = UIImage.scaleImage(image: self.editorImage)

        drawBoardImageView = DrawBoard.init(frame: CGRect(x: 0, y: 0, width: KScreenWidth, height: scaleImage.size.height))
        if scaleImage.size.height < KScreenHeight-44-50 {
            drawBoardImageView.cl_y = (KScreenHeight-44-50-scaleImage.size.height)*0.5
        }
        drawBoardImageView.isUserInteractionEnabled = true
        drawBoardImageView.backgroundColor = UIColor(patternImage: scaleImage)
        
        drawBoardImageView.masicImage = UIImage.scaleImage(image: UIImage.transToMosaicImage(orginImage: scaleImage, level: 25))
        
        scrollView.contentSize = CGSize(width: 0, height: scaleImage.size.height)
        scrollView?.addSubview(drawBoardImageView)
        drawBoardImageView.beginDraw = {[weak self]() in
            self?.goBackBtn.isEnabled = true
        }
        drawBoardImageView.unableDraw = {[weak self]() in
            self?.goBackBtn.isEnabled = false
        }
        drawBoardImageView.reableDraw = {[weak self]() in
            self?.forwardBtn.isEnabled = false
        }
        
        // 底部的工具
        let imageArr = ["ic_pen","ic_erase","ic_msk","ic_pre","ic_redo"]
        let imageArrSelect = ["ic_pen_grey","ic_erase_grey","ic_msk_grey","ic_pre_grey","ic_redo_grey"]
        let titleArr = [graffitiStr,eraserStr,mosaicStr,undoStr,redoStr]
        let btnW: CGFloat = 40
        let btnH: CGFloat = 40
        let marginX: CGFloat = 25
        let margin: CGFloat = (KScreenWidth-marginX*2-5*btnW)/4.0
        for i in 0..<5 {
            let btnX: CGFloat = marginX + (margin+btnW)*CGFloat(i)
            let btn = UIButton.init(frame: CGRect(x: btnX, y: 5, width: btnW, height: btnH))
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            btn.imageEdgeInsets = UIEdgeInsets(top: -11, left: 9, bottom: 0, right: 0)
            btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -26, bottom: -24, right: 0)
            btn.setImage(UIImage(named: imageArr[i], in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
            btn.setImage(UIImage(named: imageArrSelect[i], in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .selected)
            btn.setTitle(titleArr[i], for: .normal)
            btn.setTitleColor(UIColor.gray, for: .selected)
            btn.addTarget(self, action: #selector(clickBottomBtn(btn:)), for: .touchUpInside)
            self.bottomView.addSubview(btn)
            if i == 0 {
                pencilBtn = btn
            }
            if i == 1 {
                eraserBtn = btn
            }
            if i == 2 {
                masicBtn = btn
            }
            if i == 3 {
                goBackBtn = btn
                // 初始化都是不可点击的
                goBackBtn.isEnabled = false
            }
            if i == 4 {
                forwardBtn = btn
                // 初始化都是不可点击的
                forwardBtn.isEnabled = false
            }
        }
    }
    
    @objc func clickBottomBtn(btn:UIButton) {

        if btn.currentTitle == graffitiStr {
            
            pencilBtn.isSelected = !pencilBtn.isSelected
            eraserBtn.isSelected = false
            masicBtn.isSelected = false
            self.scrollView.isScrollEnabled = !pencilBtn.isSelected
            if pencilBtn.isSelected {
                self.drawBoardImageView.brush = PencilBrush()
                self.showPencilView()
            } else {
                choosePencilViewDismiss()
                self.drawBoardImageView.brush = nil
            }
        }
        if btn.currentTitle == eraserStr {

            choosePencilViewDismiss()
            eraserBtn.isSelected = !eraserBtn.isSelected
            pencilBtn.isSelected = false
            masicBtn.isSelected = false
            self.scrollView.isScrollEnabled = !eraserBtn.isSelected
            if eraserBtn.isSelected {
                self.drawBoardImageView.brush = EraserBrush()
            } else {
                self.drawBoardImageView.brush = nil
            }
        }
        if btn.currentTitle == mosaicStr {
            choosePencilViewDismiss()
            masicBtn.isSelected = !masicBtn.isSelected
            pencilBtn.isSelected = false
            eraserBtn.isSelected = false
            self.scrollView.isScrollEnabled = !masicBtn.isSelected
            if masicBtn.isSelected {
                self.drawBoardImageView.brush = RectangleBrush()
            } else {
                self.drawBoardImageView.brush = nil
            }
        }

        if btn.currentTitle == undoStr {
            if self.drawBoardImageView.canBack() {
                self.goBackBtn.isEnabled = true
                self.forwardBtn.isEnabled = true
                drawBoardImageView?.undo()
            } else {
                self.goBackBtn.isEnabled = false
            }
        }
        if btn.currentTitle == redoStr {
            if self.drawBoardImageView.canForward() {
                self.forwardBtn.isEnabled = true
                self.goBackBtn.isEnabled = true
                drawBoardImageView?.redo()
            } else {
                self.forwardBtn.isEnabled = false
            }
        }
    }
    
}
//MARK: - UIScrollViewDelegate
extension EditorViewController:UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return drawBoardImageView
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        
    }
}
