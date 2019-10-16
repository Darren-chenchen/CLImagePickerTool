//
//  CLImagePickerSingleViewController.swift
//  ImageDeal
//
//  Created by darren on 2017/7/27.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import PhotosUI
import Photos

typealias  CLImagePickerSingleChooseImageCompleteClouse = (Array<PHAsset>,UIImage?)->()

class CLImagePickerSingleViewController: CLBaseImagePickerViewController {

    fileprivate var previousPreheatRect = CGRect.zero
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize! = CGSize(width:(UIScreen.main.bounds.width-15)/4.0*UIScreen.main.scale, height: (UIScreen.main.bounds.width-15)/4.0*UIScreen.main.scale)
    
    @objc var photoArr: [CLImagePickerPhotoModel]?
        
    @objc var cameraPicker: UIImagePickerController!
    
    @objc var singleChooseImageCompleteClouse: CLImagePickerSingleChooseImageCompleteClouse?
    
    @objc let imageCellID = "imagecellID"
    
    // 标记是不是所有照片。如果是所有照片再添加拍照图片
    @objc var isAllPhoto: Bool = false
    // 单选状态的类型
    var singleType: CLImagePickerToolType?
    // 视频和照片只能选择一种，不能同时选择,默认可以同时选择
    @objc var onlyChooseImageOrVideo: Bool = false
    // 图片裁剪比例
    var singlePictureCropScale: CGFloat?
    // 单选模式下图片可以编辑
    @objc var singleModelImageCanEditor: Bool = false
    // 相册中是否展示相机
    var showCamaroInPicture = true
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var flowout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var bottomViewHYS: NSLayoutConstraint!
    @IBOutlet weak var bottomViewYS: NSLayoutConstraint!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var lookBtn: UIButton!
    @IBOutlet weak var sureBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bottomViewHYS.constant = UIDevice.current.isX() == true ? 34+44:44
        
         //假如用户在收藏相册详情中选中了一张照片，那么就应该把全部照片中的数据源刷新一下，这样才能显示选中状态
         //将所有模型至为未选中
        if self.photoArr != nil {
            for model in self.photoArr! {
                model.isSelect = false
            }
        }
        let chooseAssetArr = CLPickersTools.instence.getChoosePictureArray()
        for item in chooseAssetArr {
            guard let photoArrVaile = self.photoArr else {
                continue
            }
            for model in photoArrVaile {
                if model.phAsset?.localIdentifier == item.localIdentifier {
                    model.isSelect = true
                    continue
                }
            }
        }

        // 图片和视频只能选择一种
        if self.onlyChooseImageOrVideo {
            let chooseType = UserDefaults.standard.integer(forKey: UserChooserType)
            if chooseType != 0 {
                for model in (self.photoArr ?? []) {
                    if model.phAsset?.mediaType.rawValue != chooseType {
                        model.onlyChooseImageOrVideo = true
                    } else {
                        model.onlyChooseImageOrVideo = false
                    }
                }
            } else {
                for model in (self.photoArr ?? []) {
                    model.onlyChooseImageOrVideo = false
                }
            }
        }
        
        // 数组中新增一个数据代表相机图片
        if self.isAllPhoto && showCamaroInPicture {
            let model = CLImagePickerPhotoModel()
            let assetArrResult = PHAsset.fetchAssets(withLocalIdentifiers: [(self.photoArr?.first?.phAsset?.localIdentifier)!], options: nil)
            model.phAsset = assetArrResult.firstObject
            self.photoArr?.append(model)
        }
        
        initView()
        
        resetCachedAssets()

        self.initEventHendle()
    }

    func initEventHendle() {
        CLNotificationCenter.addObserver(self, selector: #selector(OnlyChooseImageOrVideoNoticFunc), name: NSNotification.Name(rawValue:OnlyChooseImageOrVideoNotic), object: nil)
        CLNotificationCenter.addObserver(self, selector: #selector(OnlyChooseImageOrVideoNoticCencelFunc), name: NSNotification.Name(rawValue:OnlyChooseImageOrVideoNoticCencel), object: nil)
        CLNotificationCenter.addObserver(self, selector: #selector(CLImagePickerSingleViewController.PreviewForSelectOrNotSelectedNoticFunc), name: NSNotification.Name(rawValue:PreviewForSelectOrNotSelectedNotic), object: nil)
    }
    
    @objc func PreviewForSelectOrNotSelectedNoticFunc(notic:Notification) {
        
        let modelPreView = notic.object as! PreviewModel
        for model in (self.photoArr ?? []) {
            if model.phAsset == modelPreView.phAsset {
                model.isSelect = modelPreView.isCheck
            }
        }
        
        if CLPickersTools.instence.getSavePictureCount() > 0 {
            let title = "\(sureStr)(\(CLPickersTools.instence.getSavePictureCount()))"
            self.sureBtn.setTitle(title, for: .normal)
            self.sureBtn.isEnabled = true
            self.lookBtn.isEnabled = true
            self.resetBtn.isEnabled = true
        } else {
            self.sureBtn.setTitle(sureStr, for: .normal)
            self.sureBtn.isEnabled = false
            self.lookBtn.isEnabled = false
            self.resetBtn.isEnabled = false
            
            // 全部取消了，如果是视频和照片2选1的类型，当全部取消后，还要刷新界面
            self.OnlyChooseImageOrVideoNoticCencelFunc()
        }
        
        self.collectionView.reloadData()
    }
    
    @objc func OnlyChooseImageOrVideoNoticFunc(notic:Notification) {
        let chooseType = notic.object as! Int
        for model in (self.photoArr ?? []) {
            if model.phAsset?.mediaType.rawValue != chooseType {
                model.onlyChooseImageOrVideo = true
            }
        }
        
        self.collectionView.reloadData()
    }
    @objc func OnlyChooseImageOrVideoNoticCencelFunc() {
        for model in (self.photoArr ?? []) {
            model.onlyChooseImageOrVideo = false
        }
        self.collectionView.reloadData()
    }
    
    // 重置
    @IBAction func clickResetBtn(_ sender: Any) {
        if self.photoArr != nil {
            for model in self.photoArr! {
                model.isSelect = false
            }
        }
        
        CLPickersTools.instence.clearPicture()
        
        self.lookBtn.isEnabled = false
        self.resetBtn.isEnabled = false
        self.sureBtn.isEnabled = false
        self.sureBtn.setTitle(sureStr, for: .normal)
        
        if self.onlyChooseImageOrVideo {
            for model in (self.photoArr ?? []) {
                model.onlyChooseImageOrVideo = false
            }
            // 重置选择的类型
            UserDefaults.standard.set(0, forKey: UserChooserType)
            UserDefaults.standard.synchronize()
        }

        self.collectionView.reloadData()
    }
    // 预览
    @IBAction func clickLookBtn(_ sender: Any) {
        let previewVC = CLPreviewViewController()
        
        var array = [PreviewModel]()
        for item in CLPickersTools.instence.getChoosePictureArray() {
            let model = PreviewModel()
            model.phAsset = item
            model.isCheck = true
            array.append(model)
        }
        previewVC.picArray = array
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    // 点击确定
    @IBAction func clickSureBtn(_ sender: Any) {
        self.choosePictureComplete(assetArr: CLPickersTools.instence.getChoosePictureArray(), img: nil)
    }
    
    @objc func choosePictureComplete(assetArr:Array<PHAsset>,img:UIImage?) {
        
        weak var weakSelf = self
        // 记得pop，不然控制器释放不掉
        weakSelf?.dismiss(animated: true) {
            weakSelf?.navigationController?.popViewController(animated: true)
            
            if weakSelf?.singleChooseImageCompleteClouse != nil {
                weakSelf?.singleChooseImageCompleteClouse!(assetArr,img)
            } 
        }
    }
    
    @objc func initView() {
        self.backBtn.isHidden = false

        self.rightBtn.setTitle(cancelStr, for: .normal)

        self.lookBtn.setTitle(previewStr, for: .normal)
        self.resetBtn.setTitle(resetStr, for: .normal)
        self.sureBtn.setTitle(sureStr, for: .normal)
        
        self.rightBtn.setTitleColor(CLPickersTools.instence.tineColor, for: .normal)
        self.lookBtn.setTitleColor(CLPickersTools.instence.tineColor, for: .normal)
        self.resetBtn.setTitleColor(CLPickersTools.instence.tineColor, for: .normal)
        self.sureBtn.setTitleColor(CLPickersTools.instence.tineColor, for: .normal)


        if CLPickersTools.instence.getSavePictureCount() > 0 {
            let title = "\(sureStr)(\(CLPickersTools.instence.getSavePictureCount()))"
            self.sureBtn.setTitle(title, for: .normal)
            self.sureBtn.isEnabled = true
            self.lookBtn.isEnabled = true
            self.resetBtn.isEnabled = true
        } else {
            self.sureBtn.isEnabled = false
            self.lookBtn.isEnabled = false
            self.resetBtn.isEnabled = false
        }
        
        self.flowout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 30, right: 0)
        self.flowout.footerReferenceSize = CGSize(width: KScreenWidth, height: 30)
        self.flowout.minimumLineSpacing = 5
        self.flowout.minimumInteritemSpacing = 0
        self.flowout.itemSize = CGSize(width: (UIScreen.main.bounds.width-15)/4.0, height:(UIScreen.main.bounds.width-15)/4.0)

        self.collectionView.register(UINib.init(nibName: "ImagePickerChooseImageCell", bundle: BundleUtil.getCurrentBundle()), forCellWithReuseIdentifier: imageCellID)
        self.collectionView.register(CLImagePickerCamaroCell.self, forCellWithReuseIdentifier: "CLImagePickerCamaroCell")
        if self.singleType != nil {
            self.collectionView.register(UINib.init(nibName: "CLSingleTypeCell", bundle: BundleUtil.getCurrentBundle()), forCellWithReuseIdentifier: "CLSingleTypeCell")
        }

        self.collectionView.contentInset = UIEdgeInsets(top: KNavgationBarHeight, left: 0, bottom: 44, right: 0)
        self.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: KNavgationBarHeight, left: 0, bottom: 44, right: 0)
        if #available(iOS 11.0, *) {
            self.collectionView.contentInsetAdjustmentBehavior = .never
        } else {
        }
        
        // 单选隐藏下面的确定
        if self.singleType == nil {  // 说明不是单选
            self.bottomView.isHidden = false
        } else {
            self.bottomView.isHidden = true
        }

        let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
        if item == -1 { // 防止相册为0
            return
        }
        
        
        let lastItemIndex = IndexPath.init(row: item, section: 0)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
            self.collectionView?.scrollToItem(at: lastItemIndex, at: .top, animated: false)
        }
    }

    override func backBtnclick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func rightBtnClick() {
        // 记得pop，不然控制器释放不掉
        self.dismiss(animated: true) { 
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    deinit {
        print("CLImagePickerSingleViewController释放")
        CLNotificationCenter.removeObserver(self)
    }
    
    // MARK: UIScrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    fileprivate func updateCachedAssets() {
        
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        // The preheat window is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start caching and to stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in self.photoArr![indexPath.row].phAsset ?? PHAsset() }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in self.photoArr![indexPath.row].phAsset ?? PHAsset() }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        
        // Store the preheat rect to compare against in the future.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
}

extension CLImagePickerSingleViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // 相机
        if indexPath.row == (self.photoArr?.count ?? 1) - 1 && self.isAllPhoto && showCamaroInPicture {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CLImagePickerCamaroCell", for: indexPath) as! CLImagePickerCamaroCell
            cell.clickCamaroCell = {[weak self]() in

                CLPickersTools.instence.authorizeCamaro { (state) in
                    if state == .authorized {
                        if self?.isCameraAvailable() == false {
                            PopViewUtil.alert(message: "相机不可用", leftTitle: "", rightTitle: "确定", leftHandler: nil, rightHandler: nil)
                            return
                        }
                        DispatchQueue.main.async {
                            self?.cameraPicker = UIImagePickerController()
                            self?.cameraPicker.delegate = self
                            self?.cameraPicker.sourceType = .camera
                            (self?.cameraPicker)!.modalPresentationStyle = .fullScreen
                            self?.present((self?.cameraPicker)!, animated: true, completion: nil)
                        }
                    }
                }

            }
            return cell
        }
    
        if self.singleType == nil {  // 说明不是单选
            let model = self.photoArr?[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellID, for: indexPath) as! ImagePickerChooseImageCell
            cell.onlyChooseImageOrVideo = self.onlyChooseImageOrVideo
            cell.representedAssetIdentifier = (model?.phAsset?.localIdentifier)!
            cell.model = model

            imageManager.requestImage(for: (model?.phAsset)!, targetSize:thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                if cell.representedAssetIdentifier == model?.phAsset?.localIdentifier {
                    cell.iconView.image = image
                }
            })
            cell.imagePickerChooseImage = {[weak self] () in
                let chooseCount = CLPickersTools.instence.getSavePictureCount()
                if chooseCount == 0 {
                    self?.sureBtn.setTitle(sureStr, for: .normal)
                    self?.sureBtn.isEnabled = false
                    self?.lookBtn.isEnabled = false
                    self?.resetBtn.isEnabled = false
                } else {
                    self?.sureBtn.setTitle("\(sureStr)(\(chooseCount))", for: .normal)
                    self?.sureBtn.isEnabled = true
                    self?.lookBtn.isEnabled = true
                    self?.resetBtn.isEnabled = true
                }
            }
            return cell
        } else {  // 是单选
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CLSingleTypeCell", for: indexPath) as! CLSingleTypeCell
            let model = self.photoArr?[indexPath.row]
            cell.representedAssetIdentifier = (model?.phAsset?.localIdentifier)!
            cell.singleModelImageCanEditor = self.singleModelImageCanEditor
            cell.model = model
            imageManager.requestImage(for: (model?.phAsset)!, targetSize:thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
                if cell.representedAssetIdentifier == model?.phAsset?.localIdentifier {
                    cell.iconView.image = image
                }
            })
            cell.singleChoosePicture = { [weak self] (assetArr,img) in

                if self?.singleType == .singlePictureCrop {  // 单选裁剪
                    if assetArr.first?.mediaType == .video {
                        self?.choosePictureComplete(assetArr: assetArr, img: img)
                        return
                    }
                    let cutVC = CLCropViewController()
                    if self?.singlePictureCropScale != nil {
                        cutVC.scale = (self?.singlePictureCropScale)!
                    }
                    cutVC.originalImage = img
                    cutVC.clCropClouse = {[weak self] (cutImg) in
                        self?.choosePictureComplete(assetArr: assetArr, img: cutImg)
                    }
                    cutVC.asset = assetArr.first
                    self?.navigationController?.pushViewController(cutVC, animated: true)
                } else {
                    self?.choosePictureComplete(assetArr: assetArr, img: img)
                }
            }
            // 编辑图片
            cell.singleChoosePictureAndEditor =  { [weak self] (assetArr,img) in
                let editorVC = EditorViewController.init(nibName: "EditorViewController", bundle: BundleUtil.getCurrentBundle())
                editorVC.editorImage = img
                editorVC.editorImageComplete = {(img) in
                    self?.choosePictureComplete(assetArr: assetArr, img: img)

                    // 记得pop，不然控制器释放不掉
                    self?.dismiss(animated: true) {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
                editorVC.modalPresentationStyle = .fullScreen
                self?.present(editorVC, animated: true, completion: nil)
            }

            return cell
        }
    }
    
    func isCameraAvailable() -> Bool{
        return UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
    }

}

extension CLImagePickerSingleViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        self.dismiss(animated: true) {}
        
        PopViewUtil.share.showLoading()

        // 保存到相册
        let type = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as? String
        if type == "public.image" {
            CLPickersTools.instence.authorizeSave { (state) in
                if state == .authorized {
                    let photo = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)]
                    UIImageWriteToSavedPhotosAlbum(photo as! UIImage, self, #selector(CLImagePickerSingleViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                } else {
                    DispatchQueue.main.async(execute: {
                        PopViewUtil.alert(title: photoLimitStr, message: clickSetStr, leftTitle: cancelStr, rightTitle: setStr, leftHandler: {
                            // 点击了取消
                            PopViewUtil.share.stopLoading()
                            picker.dismiss(animated: true, completion: nil)
                        }, rightHandler: {
                            let url = URL(string: UIApplication.openSettingsURLString)
                            if let url = url, UIApplication.shared.canOpenURL(url) {
                                if #available(iOS 10, *) {
                                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                                                              completionHandler: {
                                                                (success) in
                                    })
                                } else {
                                    UIApplication.shared.openURL(url)
                                }
                            }
                        })
                    })
                }
            }
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 保存图片的结果
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if let err = error {
            UIAlertView(title: errorStr, message: err.localizedDescription, delegate: nil, cancelButtonTitle: sureStr).show()
        } else {
        
            var dataArr = CLPickersTools.instence.loadData()
            let newModel = dataArr.first?.values.first?.last
            
            let amount = dataArr.first?.values.first?.count ?? 1
            let index = amount-1
            
            self.photoArr?.insert(newModel!, at: index)
            self.collectionView.reloadData()
            let lastItemIndex = IndexPath.init(item: (self.photoArr?.count ?? 1)-1, section: 0)
            self.collectionView?.scrollToItem(at: lastItemIndex, at: .top, animated: false)
            
            // 发送通知更新列表的数据
            dataArr.removeFirst()
            var arr = self.photoArr
            arr?.removeLast()
            dataArr.insert([self.navTitle:arr!], at: 0)
            CLNotificationCenter.post(name: NSNotification.Name(rawValue:CLPhotoListRefreshNotic), object: dataArr)
            
            PopViewUtil.share.stopLoading()
        }
    }

}
private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
