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
    
    let ID = "Previewcell"
    let VideoID = "VideoPreviewcell"

    var picArray: Array<PreviewModel>!
    var hiddenTextLable: Bool = false

    fileprivate lazy var collectionView: UICollectionView = {
        var layout = UICollectionViewFlowLayout()
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
    
    lazy var titleLabel: UILabel = {
        let textlable = UILabel(frame: CGRect(x: 0, y: self.view.frame.size.height - 50, width: self.view.frame.size.width, height: 20))
        textlable.text = "\(1)/\(self.picArray.count)"
        textlable.textAlignment = .center
        textlable.textColor = UIColor.white
        textlable.font = UIFont.systemFont(ofSize: 16)
        return textlable
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.customNavBar.isHidden = true
        self.view.backgroundColor = UIColor.black
        
        self.view.addSubview(collectionView)
        if !hiddenTextLable {
            self.view.addSubview(self.titleLabel)
        }
    }
    
    deinit {
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
            cell.model = model
            cell.previewClouse = {[weak self]() in
                self?.navigationController?.popViewController(animated: true)
            }
            return cell

        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.VideoID, for: indexPath) as! CLPreviewVideoCell
            cell.model = model
            cell.previewClouse = {[weak self]() in
                self?.navigationController?.popViewController(animated: true)
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
    }
}

