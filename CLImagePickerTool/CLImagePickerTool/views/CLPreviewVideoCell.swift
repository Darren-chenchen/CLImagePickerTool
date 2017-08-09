//
//  CLPreviewVideoCell.swift
//  CLImagePickerTool
//
//  Created by darren on 2017/8/8.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import PhotosUI
import Photos

class CLPreviewVideoCell: UICollectionViewCell {
    
    var previewClouse: CLPreviewCellClouse?

    var imageRequestID: PHImageRequestID?
    
    let manager = PHImageManager.default()
    
    var playerItem: AVPlayerItem?
    var player: AVPlayer?

    
    lazy var iconView: UIImageView = {
        let img = UIImageView.init(frame:  CGRect(x: 0, y: 0, width: self.cl_width, height: self.cl_height))
        img.isUserInteractionEnabled = true
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    lazy var playBtn: UIButton = {
        let btn = UIButton.init(frame: CGRect(x: 0.5*(KScreenWidth-80), y: 0.5*(KScreenHeight-80), width: 80, height: 80))
        
        btn.setBackgroundImage(UIImage(named: "clvedioplaybtn", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
        return btn
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.iconView)
        self.iconView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(clickImage)))
        
        self.addSubview(self.playBtn)
        
        self.playBtn.addTarget(self, action: #selector(self.clickPlayBtn), for: .touchUpInside)
    }
    
    var model: PreviewModel! {
        didSet{
            CLPickersTools.instence.getAssetThumbnail(targetSize: CGSize(width:cellH, height: cellH), asset: model.phAsset!) { (image, info) in
                self.iconView.image = image
            }
        }
    }
    
    func clickImage() {
        
        self.removeObserver()

        if self.previewClouse != nil {
            self.previewClouse!()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconView.frame = CGRect(x: 0, y: 0, width: self.cl_width, height: self.cl_height)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func clickPlayBtn() {
        self.playBtn.isHidden = true
        
        if self.model.phAsset == nil {
            return
        }
        let manager = PHImageManager.default()
        let videoRequestOptions = PHVideoRequestOptions()
        videoRequestOptions.deliveryMode = .automatic
        videoRequestOptions.version = .current
        videoRequestOptions.isNetworkAccessAllowed = true
        
        videoRequestOptions.progressHandler = {
            (progress, error, stop, info) in
            
            DispatchQueue.main.async(execute: {
                print(progress, info ?? "0000")
            })
        }
        
        PopViewUtil.share.showLoading()
        manager.requestPlayerItem(forVideo: self.model.phAsset!, options: videoRequestOptions) { (playItem, info) in
            
            DispatchQueue.main.async(execute: {
                self.removeObserver()
                
                self.playerItem = playItem
                self.player = AVPlayer(playerItem: self.playerItem)
                let playerLayer = AVPlayerLayer(player: self.player)
                playerLayer.frame = self.bounds
                playerLayer.videoGravity = AVLayerVideoGravityResizeAspect //视频填充模式
                self.iconView.layer.addSublayer(playerLayer)
                
                self.addObserver()
            })
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
            
            self.player = nil
            self.playerItem = nil
        }
    }
    
    func playerItemDidReachEnd(notification:Notification) {
        self.playBtn.isHidden = false
        self.removeObserver()
        
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
                PopViewUtil.alert(message: "播放出错", leftTitle: "", rightTitle: "确定", leftHandler: {
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
