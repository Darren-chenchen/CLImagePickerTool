//
//  CLPreviewViewController.swift
//  CLImagePickerTool
//
//  Created by darren on 2017/8/8.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class CLPreviewViewController: CLBaseImagePickerViewController {
    
    @objc let ID = "Previewcell"
    @objc let VideoID = "VideoPreviewcell"

    @objc var picArray: Array<PreviewModel>!
    @objc var hiddenTextLable: Bool = false
    
    var layout = UICollectionViewFlowLayout()

    fileprivate lazy var collectionView: UICollectionView = {
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        var collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), collectionViewLayout: layout)
        layout.itemSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = true
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CLPreviewCell.classForCoder(), forCellWithReuseIdentifier: self.ID)
        collectionView.register(CLPreviewVideoCell.classForCoder(), forCellWithReuseIdentifier: self.VideoID)

        return collectionView
    }()
    
    @objc lazy var titleLabel: UILabel = {
        let textlable = UILabel()
        textlable.text = "\(1)/\(self.picArray.count)"
        textlable.textAlignment = .center
        textlable.textColor = UIColor.white
        textlable.font = UIFont.systemFont(ofSize: 16)
        return textlable
    }()
    
    lazy var selectBtn: UIButton = {
        let btn = UIButton.init()
        return btn
    }()
    @objc var currentPage: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        CLNotificationCenter.addObserver(self, selector: #selector(receiverNotification(notic:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    func initConstraints() {
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.selectBtn.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false

        self.view.addConstraints([
            NSLayoutConstraint.init(item: self.collectionView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: self.collectionView, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: self.collectionView, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0),
            NSLayoutConstraint.init(item: self.collectionView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            ])
        
        let y: CGFloat = UIDevice.current.isX() == true ? 48:28
        self.selectBtn.addConstraint(NSLayoutConstraint.init(item: self.selectBtn, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: 25))
        self.selectBtn.addConstraint(NSLayoutConstraint.init(item: self.selectBtn, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: 25))
        self.customNavBar.addConstraints([
            NSLayoutConstraint.init(item: self.selectBtn, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.customNavBar, attribute: NSLayoutAttribute.top, multiplier: 1, constant: y),
            NSLayoutConstraint.init(item: self.selectBtn, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.customNavBar, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: -20)
            ])
        
        if !hiddenTextLable {
            self.titleLabel.addConstraint(NSLayoutConstraint.init(item: self.titleLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 0, constant: 20))
            self.view.addConstraints([
                NSLayoutConstraint.init(item: self.titleLabel, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -50),
                NSLayoutConstraint.init(item: self.titleLabel, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0),
                NSLayoutConstraint.init(item: self.titleLabel, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
                ])
        }

    }
    func initView() {
        self.view.backgroundColor = UIColor.black
        self.view.addSubview(collectionView)
        if !hiddenTextLable {
            self.view.addSubview(self.titleLabel)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.toobar.alpha = 0
        self.customNavBar.navLine.isHidden = true
        self.backBtn.isHidden = false
        self.customNavBar.backgroundColor = UIColor(white: 0, alpha: 0.67)
        self.backBtn.setImage(UIImage(named: "btn_back_w", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for:UIControlState())
        self.view.bringSubview(toFront: self.customNavBar)
        self.selectBtn.setBackgroundImage(UIImage(named: "photo_sel_photoPicker", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
        CLViewsBorder(self.selectBtn, borderWidth: 1.5, borderColor: UIColor.white, cornerRadius: 25*0.5)
        self.customNavBar.addSubview(self.selectBtn)
        self.customNavBar.bringSubview(toFront: self.rightBtn)
        self.rightBtn.isSelected = true
        
        initConstraints()
    }
    
    override func rightBtnClick() {
        
        let model = self.picArray[self.currentPage-1]

        self.rightBtn.isSelected = !self.rightBtn.isSelected
        if self.rightBtn.isSelected {
            
            self.selectBtn.setBackgroundImage(UIImage(named: "photo_sel_photoPicker", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
            model.isCheck = true
            CLPickersTools.instence.savePicture(asset: (model.phAsset)!, isAdd: true)
        } else {
            self.selectBtn.setBackgroundImage(UIImage(named: "", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
            model.isCheck = false
            CLPickersTools.instence.savePicture(asset: (model.phAsset)!, isAdd: false)
        }
        
        // 通知列表刷新状态
        CLNotificationCenter.post(name: NSNotification.Name(rawValue:PreviewForSelectOrNotSelectedNotic), object: model)
        
        // 动画
        let shakeAnimation = CABasicAnimation.init(keyPath: "transform.scale")
        shakeAnimation.duration = 0.1
        shakeAnimation.fromValue = 0.8
        shakeAnimation.toValue = 1
        shakeAnimation.autoreverses = true
        self.selectBtn.layer.add(shakeAnimation, forKey: nil)
    }
    override func backBtnclick() {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

    @objc func receiverNotification(notic: Notification){
        
        let orient = UIDevice.current.orientation
        switch orient {
        case .portrait :
            self.updateCell()
            //print("屏幕正常竖向")
            break
        case .portraitUpsideDown:
            //print("屏幕倒立")
            self.updateCell()
            break
        case .landscapeLeft:
            //print("屏幕左旋转")
            self.updateCell()
            break
        case .landscapeRight:
            //print("屏幕右旋转")
            self.updateCell()
            break
        default:
            break
        }
    }
    func updateCell() {
        layout.itemSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
        self.collectionView.setContentOffset(CGPoint(x: self.view.frame.size.width * CGFloat(self.currentPage-1), y: 0), animated: true)
    }
    deinit {
        CLNotificationCenter.removeObserver(self)
        print("CLPreviewViewController销毁")
    }
}

extension CLPreviewViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.picArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = self.picArray[indexPath.row]
        if model.phAsset?.mediaType == .image {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.ID, for: indexPath) as! CLPreviewCell
            model.index = indexPath.row
            cell.identifyIndex = indexPath.row
            cell.modelArr = self.picArray
            cell.model = model
            cell.previewClouse = {() in
            }
            return cell

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.VideoID, for: indexPath) as! CLPreviewVideoCell
            cell.model = model
            cell.previewClouse = {() in
            }
            return cell

        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = (Int)(scrollView.contentOffset.x / scrollView.bounds.size.width + 0.5) % self.picArray.count
        
        let cellArr = self.collectionView.visibleCells
        for cell in cellArr {
            if cell.classForCoder == CLPreviewVideoCell.classForKeyedArchiver() {
                let cellVedio = cell as! CLPreviewVideoCell
                if cellVedio.player != nil {
                    cellVedio.player?.pause()
                    cellVedio.playBtn.isHidden = false
                    cellVedio.removeObserver()
                }
            }
        }
        
        self.titleLabel.text = String(format: "%d/%d", arguments: [page+1,self.picArray.count])
        
        self.currentPage = page+1
        let model = self.picArray[page]
        if model.isCheck {
            self.rightBtn.isSelected = true
            self.selectBtn.setBackgroundImage(UIImage(named: "photo_sel_photoPicker", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
        } else {
            self.rightBtn.isSelected = false
            self.selectBtn.setBackgroundImage(UIImage(named: "", in: BundleUtil.getCurrentBundle(), compatibleWith: nil), for: .normal)
        }
    }
}

