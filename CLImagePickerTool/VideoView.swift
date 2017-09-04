//
//  PhotoView.swift
//  paso-ios
//
//  Created by 陈亮陈亮 on 2017/6/19.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

typealias VedioViewCloseBtnClickClouse = ([UIImage])->()
typealias VedioViewVisitPhotoBtnClickClouse = ()->()

class VideoView: UIView {
    
    var closeBtnClickClouse: VedioViewCloseBtnClickClouse?
    var visitPhotoBtnClickClouse: VedioViewVisitPhotoBtnClickClouse?

    var picStrArr = [String]()  // 在实际的项目中可能用于存储图片的url

    var imgView: UIImageView!
    var scrollView: UIScrollView!
    
    var assetArr = [PHAsset]()
    
    var playBtn: UIButton!
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?

    var asset: PHAsset?
    
    var playBtnArr = [UIButton]()

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
            
            self.playBtnArr.removeAll()
            
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
                if i==0 {
                    imageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(clickChooseImage)))
                }
                
                // 加一个关闭按钮
                let closeBtn = UIButton.init(frame: CGRect(x: self.imgView.cl_width-20, y: 0, width: 20, height: 20))
                let playerBtn = UIButton.init(frame: CGRect(x: 0.5*(self.imgView.cl_width-30), y:  0.5*(self.imgView.cl_height-30), width: 30, height: 30))
                closeBtn.tag = i
                playerBtn.tag = 999+i
                playBtnArr.append(playerBtn)
                
                if (i != 0) {
                    closeBtn.setBackgroundImage(UIImage(named:"close"), for: .normal)
                    closeBtn.addTarget(self, action: #selector(clickCloseBtn(btn:)), for: .touchUpInside)
                    self.imgView.addSubview(closeBtn)
                    
                    playerBtn.setBackgroundImage(UIImage(named: "clvedioplaybtn"), for: .normal)
                    playerBtn.addTarget(self, action: #selector(self.clickPlayBtn(btn:)), for: .touchUpInside)
                    self.imgView.addSubview(playerBtn)
                }
            }
            if (picArr.count>=2) {
                self.scrollView.contentSize = CGSize(width:CGFloat(picArr.count)*imageW + CGFloat((picArr.count+1)*5), height:0);
            } else {
                self.scrollView.contentSize = CGSize(width:0, height:0);
            }

        }
    }
    
    func clickPlayBtn(btn:UIButton) {
        
        self.playBtn = btn
        self.playBtn.alpha = 0
        self.asset = self.assetArr[btn.tag - 1000]
        
        if self.asset == nil {
            return
        }
        PopViewUtil.share.showLoading()
        CLImagePickersTool.convertAssetToAvPlayerItem(asset: self.asset!, successClouse: { (playerItem) in
            DispatchQueue.main.async(execute: {
                self.removeObserver()
                
                self.playerItem = playerItem
                self.player = AVPlayer(playerItem: self.playerItem)
                let playerLayer = AVPlayerLayer(player: self.player)
                playerLayer.frame = self.imgView.bounds
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspect //视频填充模式
                btn.superview?.layer.addSublayer(playerLayer)
                
                self.addObserver()
            })
        }, failedClouse: { 
            
        }) { (progress) in
            print("视频下载进度\(progress)")
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
        if self.visitPhotoBtnClickClouse != nil {
            self.visitPhotoBtnClickClouse!()
        }
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

    
    
    func addObserver(){
        
        //为AVPlayerItem添加status属性观察，得到资源准备好，开始播放视频
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CLVideoPlayView.playerItemDidReachEnd(notification:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    func removeObserver() {
        if self.playerItem != nil {
            self.playerItem?.removeObserver(self, forKeyPath: "status")
            NotificationCenter.default.removeObserver(self, name:  Notification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
        }
        
    }
    
    func playerItemDidReachEnd(notification:Notification) {
        self.playBtn.alpha = 1
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let object = object as? AVPlayerItem  else { return }
        guard let keyPath = keyPath else { return }
        if keyPath == "status"{
            if object.status == .readyToPlay{ //当资源准备好播放，那么开始播放视频
                self.player?.play()
                                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1, execute: {
                    PopViewUtil.share.stopLoading()
                })
            }else if object.status == .failed || object.status == .unknown{
                print("播放出错")
                PopViewUtil.alert(message: playErrorStr, leftTitle: "", rightTitle:sureStr, leftHandler: {
                }, rightHandler: {
                })
                PopViewUtil.share.stopLoading()
            }
        }
    }
    
    deinit {
        self.removeObserver()
    }

}
