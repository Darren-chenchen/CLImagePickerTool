//
//  CLPickerTool.swift
//  ImageDeal
//
//  Created by darren on 2017/8/3.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

public enum CLImagePickerToolType {
    case singlePicture   // 图片单选
    case singlePictureCrop   // 单选并裁剪
}
public enum CLImagePickerToolStatusBarType {
    case black   // 黑色
    case white   // 白色
}

public typealias CLPickerToolClouse = (Array<PHAsset>,UIImage?)->()

public class CLImagePickerTool: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
        
    @objc var cameraPicker: UIImagePickerController!
    
    private weak var superVC: UIViewController?
    
    public var clPickerToolClouse: CLPickerToolClouse?
    
    // 是否隐藏视频文件，默认不隐藏
    @objc public var isHiddenVideo: Bool = false
    // 是否隐藏图片文件，显示视频文件，默认不隐藏
    @objc public var isHiddenImage: Bool = false
    // 设置单选图片，单选图片并裁剪属性，默认多选
    public var singleImageChooseType: CLImagePickerToolType?
    // 设置相机在外部，默认不在外部
    @objc public var cameraOut: Bool = false
    // 单选模式下图片并且可裁剪。默认裁剪比例是1：1，也可以设置如下参数
    public var singlePictureCropScale: CGFloat?
    // 视频和照片只能选择一种，不能同时选择,默认可以同时选择
    @objc public var onlyChooseImageOrVideo: Bool = false
    // 单选模式下，图片可以编辑，默认不可编辑
    @objc public var singleModelImageCanEditor: Bool = false
    // 配置导航栏的颜色，默认是毛玻璃效果
    public var navColor: UIColor? = nil
    // 配置导航栏文字的颜色
    public var navTitleColor: UIColor? = nil
    // 配置状态栏的颜色
    public var statusBarType: CLImagePickerToolStatusBarType = .black
    // 相册中是否展示拍照图片
    public var showCamaroInPicture = true
    // 文字和图片的颜色 85 182 55
    public var tineColor = UIColor.init(red: 85/255.0, green: 182/255.0, blue: 55/255.0, alpha: 1) {
        didSet {
            CLPickersTools.instence.tineColor = tineColor
        }
    }
    
    private let isPad: Bool = UIDevice.current.model == "iPad"
    
    // 第二种弹出方式
    @available(*, deprecated, message: "Use 'cl_setupImagePickerAnotherWayWith' instead.")
    public func setupImagePickerAnotherWayWith(maxImagesCount: Int,superVC: UIViewController,didChooseImageSuccess:@escaping (Array<PHAsset>,UIImage?)->()) {
        CLPickersTools.instence.authorize(authorizeClouse: { (state) in

            if state == .authorized {
                let anotherVC = CLImagePickerAnotherViewController.init(nibName: "CLImagePickerAnotherViewController", bundle: BundleUtil.getCurrentBundle())
                anotherVC.modalPresentationStyle = .custom
                anotherVC.transitioningDelegate = CLPresent.instance
                
                anotherVC.MaxImagesCount = maxImagesCount
                anotherVC.isHiddenVideo = self.isHiddenVideo
                anotherVC.isHiddenImage = self.isHiddenImage
                anotherVC.onlyChooseImageOrVideo = self.onlyChooseImageOrVideo
                
                anotherVC.singleChooseImageCompleteClouse = { (assetArr:Array<PHAsset>,image) in
                    didChooseImageSuccess(assetArr,image)
                }
                anotherVC.modalPresentationStyle = .fullScreen
                superVC.present(anotherVC, animated: true, completion: nil)
            }
        })
    }
    
    public func cl_setupImagePickerAnotherWayWith(maxImagesCount: Int,superVC: UIViewController? = nil, didChooseImageSuccess:@escaping (Array<PHAsset>,UIImage?)->()) {
        CLPickersTools.instence.authorize(authorizeClouse: { (state) in
            
            self.superVC = superVC
            if self.superVC == nil {
                self.superVC = self.getCurrentViewcontroller()
            }
            if state == .authorized {
                let anotherVC = CLImagePickerAnotherViewController.init(nibName: "CLImagePickerAnotherViewController", bundle: BundleUtil.getCurrentBundle())
                anotherVC.modalPresentationStyle = .custom
                anotherVC.transitioningDelegate = CLPresent.instance
                
                anotherVC.MaxImagesCount = maxImagesCount
                anotherVC.isHiddenVideo = self.isHiddenVideo
                anotherVC.isHiddenImage = self.isHiddenImage
                anotherVC.onlyChooseImageOrVideo = self.onlyChooseImageOrVideo
                
                anotherVC.singleChooseImageCompleteClouse = { (assetArr:Array<PHAsset>,image) in
                    didChooseImageSuccess(assetArr,image)
                }
                self.superVC?.present(anotherVC, animated: true, completion: nil)
            }
        })
    }

    // 判断相机是放在外面还是内部
    @available(*, deprecated, message: "Use 'cl_setupImagePickerWith' instead.")
    @objc public func setupImagePickerWith(MaxImagesCount: Int,superVC:UIViewController,didChooseImageSuccess:@escaping (Array<PHAsset>,UIImage?)->()) {
        
        self.superVC = superVC
        self.clPickerToolClouse = didChooseImageSuccess

        if self.cameraOut == true {  // 拍照功能在外面
            var alert: UIAlertController!
            alert = UIAlertController(title: nil, message: nil, preferredStyle: isPad ? .alert : .actionSheet)
            let cleanAction = UIAlertAction(title: cancelStr, style: UIAlertAction.Style.cancel,handler:nil)
            let photoAction = UIAlertAction(title: tackPhotoStr, style: UIAlertAction.Style.default){ (action:UIAlertAction)in
                // 访问相机
                self.camera(superVC:superVC)
            }
            let choseAction = UIAlertAction(title: chooseStr, style: UIAlertAction.Style.default){ (action:UIAlertAction)in
                
                self.gotoPhoto(MaxImagesCount: MaxImagesCount)
            }
            
            alert.addAction(cleanAction)
            alert.addAction(photoAction)
            alert.addAction(choseAction)
            alert.modalPresentationStyle = .fullScreen
            superVC.present(alert, animated: true, completion: nil)

        } else {
            self.gotoPhoto(MaxImagesCount: MaxImagesCount)
        }
    }
    
    @objc public func cl_setupImagePickerWith(MaxImagesCount: Int,superVC:UIViewController? = nil,didChooseImageSuccess:@escaping (Array<PHAsset>,UIImage?)->()) {
        
        self.superVC = superVC
        if self.superVC == nil {
            self.superVC = self.getCurrentViewcontroller()
        }
        if self.superVC == nil {
            print("未获取到当前控制器")
            return
        }
        self.clPickerToolClouse = didChooseImageSuccess
        
        if self.cameraOut == true {  // 拍照功能在外面
            var alert: UIAlertController!
            alert = UIAlertController(title: nil, message: nil, preferredStyle: isPad ? .alert : .actionSheet)
            let cleanAction = UIAlertAction(title: cancelStr, style: UIAlertAction.Style.cancel,handler:nil)
            let photoAction = UIAlertAction(title: tackPhotoStr, style: UIAlertAction.Style.default){ (action:UIAlertAction)in
                // 访问相机
                self.cl_camera(superVC: self.superVC)
            }
            let choseAction = UIAlertAction(title: chooseStr, style: UIAlertAction.Style.default){ (action:UIAlertAction)in
                
                self.gotoPhoto(MaxImagesCount: MaxImagesCount)
            }
            
            alert.addAction(cleanAction)
            alert.addAction(photoAction)
            alert.addAction(choseAction)
            alert.modalPresentationStyle = .fullScreen

            self.superVC!.present(alert, animated: true, completion: nil)
            
        } else {
            self.gotoPhoto(MaxImagesCount: MaxImagesCount)
        }
    }
    
    // 访问相册
    func gotoPhoto(MaxImagesCount: Int) {
        // 判断用户是否开启访问相册功能
        CLPickersTools.instence.authorize(authorizeClouse: { (state) in
            if state == .authorized {
                let photo = CLImagePickersViewController.share.initWith(
                    MaxImagesCount: MaxImagesCount,
                    isHiddenVideo:self.isHiddenVideo,
                    cameraOut:self.cameraOut,
                    singleType:self.singleImageChooseType,
                    singlePictureCropScale:self.singlePictureCropScale,
                    onlyChooseImageOrVideo:self.onlyChooseImageOrVideo,
                    singleModelImageCanEditor:self.singleModelImageCanEditor,
                    showCamaroInPicture: self.showCamaroInPicture,
                    isHiddenImage:self.isHiddenImage,
                    navColor:self.navColor,
                    navTitleColor:self.navTitleColor,
                    statusBarType:self.statusBarType
                ) { (assetArr,cutImage) in
                    if self.clPickerToolClouse != nil {
                        self.clPickerToolClouse!(assetArr,cutImage)
                    }
                }
                photo.modalPresentationStyle = .fullScreen
                self.superVC?.present(photo, animated: true, completion: nil)
            }
        })
    }
    
    // 访问相机
    @available(*, deprecated, message: "Use 'cl_camera' instead.")
    @objc public func camera(superVC:UIViewController) {
        
        CLPickersTools.instence.authorizeCamaro { (state) in
            if state == .authorized {
                if self.isCameraAvailable() == false {
                    PopViewUtil.alert(message: "相机不可用", leftTitle: "", rightTitle: "确定", leftHandler: nil, rightHandler: nil)
                    return
                }
                DispatchQueue.main.async {
                    self.cameraPicker = UIImagePickerController()
                    self.cameraPicker.delegate = self
                    self.cameraPicker.sourceType = .camera
                    self.cameraPicker.modalPresentationStyle = .fullScreen
                    superVC.present((self.cameraPicker)!, animated: true, completion: nil)
                }
            }
        }
    }
    @objc public func cl_camera(superVC:UIViewController? = nil) {
        self.superVC = superVC
        if self.superVC == nil {
            self.superVC = self.getCurrentViewcontroller()
        }
        if self.superVC == nil {
            print("未获取到当前控制器")
            return
        }
        CLPickersTools.instence.authorizeCamaro { (state) in
            if state == .authorized {
                if self.isCameraAvailable() == false {
                    PopViewUtil.alert(message: "相机不可用", leftTitle: "", rightTitle: "确定", leftHandler: nil, rightHandler: nil)
                    return
                }
                DispatchQueue.main.async {
                    self.cameraPicker = UIImagePickerController()
                    self.cameraPicker.delegate = self
                    self.cameraPicker.sourceType = .camera
                    self.cameraPicker.modalPresentationStyle = .fullScreen
                    self.superVC!.present((self.cameraPicker)!, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    func isCameraAvailable() -> Bool{
        return UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
    }
    
    
    //MARK: - 提供asset数组转图片的方法供外界使用---原图,异步方法，每转换成一张图片就返回出去
    @objc public static func convertAssetArrToOriginImage(assetArr:Array<PHAsset>,scale:CGFloat,successClouse:@escaping (UIImage,PHAsset)->(),failedClouse:@escaping ()->()) {
        
        for item in assetArr {
            
            CLImagePickerTool.getAssetOrigin(asset: item, dealImageSuccess: { (img, info) in
                if img != nil {
                    // 对图片压缩
                    if img!.jpegData(compressionQuality: scale) == nil {
                    } else {
                        let zipImageData = img!.jpegData(compressionQuality: scale)!
                        
                        let image = UIImage(data: zipImageData)
                        
                        successClouse(image!,item)
                    }
                    
                }
            }, dealImageFailed: {
                failedClouse()
            })
        }
    }
    
    
    //MARK: - 提供asset数组转图片的方法供外界使用---缩略图
    @objc public static func convertAssetArrToThumbnailImage(assetArr:Array<PHAsset>,targetSize:CGSize) -> [UIImage] {
        
        var imageArr = [UIImage]()
        for item in assetArr {
            if item.mediaType == .image {  // 如果是图片
                CLPickersTools.instence.getAssetThumbnail(targetSize: targetSize, asset: item, dealImageSuccess: { (img, info) in
                    imageArr.append(img ?? UIImage())
                })
            }
        }
        return imageArr
    }

    //MARK: - 提供asset数组中的视频文件转为AVPlayerItem数组
    @objc public static func convertAssetToAvPlayerItem(asset:PHAsset,successClouse:@escaping (AVPlayerItem)->(),failedClouse:@escaping ()->(),progressClouse:@escaping (Double)->()) {
        
        if asset.mediaType == .video {
            let manager = PHImageManager.default()
            let videoRequestOptions = PHVideoRequestOptions()
            videoRequestOptions.deliveryMode = .automatic
            videoRequestOptions.version = .current
            videoRequestOptions.isNetworkAccessAllowed = true
            
            videoRequestOptions.progressHandler = {
                (progress, error, stop, info) in
                
                DispatchQueue.main.async(execute: {
                    if (error != nil) {
                        failedClouse()
                    } else {
                        progressClouse(progress)
                    }
                })
            }
            
            manager.requestPlayerItem(forVideo: asset, options: videoRequestOptions) { (playItem, info) in
                DispatchQueue.main.async(execute: {
                    if playItem != nil {
                        successClouse(playItem!)
                    }
                })
            }
        }
    }
    
    // 获取原图的方法  同步
    @objc static func getAssetOrigin(asset:PHAsset,dealImageSuccess:@escaping (UIImage?,[AnyHashable:Any]?) -> (),dealImageFailed:@escaping () -> ()) -> Void {
        //获取原图
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions() //可以设置图像的质量、版本、也会有参数控制图像的裁剪
        option.isNetworkAccessAllowed = true  // iCloud上的照片需要下载
        option.resizeMode   = .fast
        option.isSynchronous = true
        option.progressHandler = {
            (progress, error, stop, info) in
            DispatchQueue.main.async(execute: {
                print(progress, "异步获取icloud中的照片文件",error ?? "error")
                if (error != nil) {
                    dealImageFailed()
                }
            })
        }

        manager.requestImage(for: asset, targetSize:PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (originImage, info) in
            dealImageSuccess(originImage,info)
        }
    }
    // 获取缩略图的方法  异步
    @objc static func getAssetThumbnail(targetSize:CGSize,asset:PHAsset,dealImageSuccess:@escaping (UIImage?,[AnyHashable:Any]?) -> ()) -> Void {
        let imageSize: CGSize?
        
        if targetSize.width < KScreenWidth && targetSize.width < 600 {
            imageSize = CGSize(width: targetSize.width*UIScreen.main.scale, height: targetSize.height*UIScreen.main.scale)
        } else {
            let aspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
            var pixelWidth = targetSize.width * UIScreen.main.scale * 1.5;
            // 超宽图片
            if (aspectRatio > 1.8) {
                pixelWidth = pixelWidth * aspectRatio
            }
            // 超高图片
            if (aspectRatio < 0.2) {
                pixelWidth = pixelWidth * 0.5
            }
            let pixelHeight = pixelWidth / aspectRatio
            imageSize = CGSize(width:pixelWidth, height:pixelHeight)
        }
        
        //获取缩略图
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions() //可以设置图像的质量、版本、也会有参数控制图像的裁剪
        option.resizeMode   = .fast
        option.isNetworkAccessAllowed = false
        manager.requestImage(for: asset, targetSize:imageSize!, contentMode: .aspectFill, options: option) { (thumbnailImage, info) in
            dealImageSuccess(thumbnailImage,info)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        PopViewUtil.share.showLoading()
        // 保存到相册
        let type = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaType)] as? String
        if type == "public.image" {
            CLPickersTools.instence.authorizeSave { (state) in
                if state == .authorized {
                    let photo = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)]
                    UIImageWriteToSavedPhotosAlbum(photo as! UIImage, self, #selector(CLImagePickerTool.image(_:didFinishSavingWithError:contextInfo:)), nil)
                } else {
                    DispatchQueue.main.async(execute: {
                        PopViewUtil.alert(title: photoLimitStr, message: clickSetStr, leftTitle: cancelStr, rightTitle: setStr, leftHandler: {
                            // 点击了取消
                            PopViewUtil.share.stopLoading()
                            picker.dismiss(animated: true, completion: nil)
                        }, rightHandler: {
                            PopViewUtil.share.stopLoading()
                            picker.dismiss(animated: true, completion: nil)
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
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 保存图片的结果
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if let err = error {
            PopViewUtil.share.stopLoading()
            UIAlertView(title: errorStr, message: err.localizedDescription, delegate: nil, cancelButtonTitle: sureStr).show()
        } else {

            let dataArr = CLPickersTools.instence.loadData()
            let newModel = dataArr.first?.values.first?.last
            guard let phasset = newModel?.phAsset else {return}
            if phasset.mediaType == .video {
                return
            }
            print("22222222222222")
            var cameroImage: UIImage?
            CLPickersTools.instence.getAssetOrigin(asset: phasset) { (img, info) in
                PopViewUtil.share.stopLoading()
                print("333333333333")
                if img != nil {
                    cameroImage = img
                    if self.singleImageChooseType == .singlePictureCrop && self.singleModelImageCanEditor != true {  // 单选
                        self.crop(image: cameroImage!, phasset: phasset)
                        print("裁剪")
                        
                    } else if self.singleImageChooseType != .singlePictureCrop && self.singleModelImageCanEditor == true {  // 编辑
                        print("编辑")
                        self.editor(image: cameroImage!, phasset: phasset)
                        
                    } else if self.singleImageChooseType == .singlePictureCrop && self.singleModelImageCanEditor == true {  // 编辑并裁剪
                        print("编辑并裁剪")
                        self.crop(image: cameroImage!, phasset: phasset)
                    } else {
                        print("其他")
                        self.cameraPicker.dismiss(animated: true, completion: nil)
                        if self.clPickerToolClouse != nil {
                            self.clPickerToolClouse!([phasset],image)
                        }
                    }
                } else {  // 说明本地没有需要到iCloud下载
                }
            }
        }
    }
    
    // 相机-裁剪
    func crop(image: UIImage,phasset: PHAsset) {
        let cutVC = CLCropViewController()
        if self.singlePictureCropScale != nil {
            cutVC.scale = (self.singlePictureCropScale)!
        }
        cutVC.originalImage = image
        cutVC.enterType = .camero
        cutVC.asset = phasset
        cutVC.clCropClouse = {[weak self] (cutImg) in
            if self?.clPickerToolClouse != nil {
                self?.clPickerToolClouse!([phasset],cutImg)
            }
            
            self?.cameraPicker.dismiss(animated: true, completion: nil)
        }
        cutVC.cancelClouse = {[weak self]() in
            self?.cameraPicker.dismiss(animated: true, completion: nil)
        }
        self.cameraPicker.pushViewController(cutVC, animated: true)
    }
    // 相机-编辑
    func editor(image: UIImage,phasset: PHAsset) {
        let editorVC = EditorViewController.init(nibName: "EditorViewController", bundle: BundleUtil.getCurrentBundle())
        editorVC.editorImage = image
        editorVC.editorImageComplete = {[weak self](img) in
            self?.cameraPicker.dismiss(animated: true, completion: nil)

            if self?.clPickerToolClouse != nil {
                self?.clPickerToolClouse!([phasset],img)
            }
        }
        self.cameraPicker.pushViewController(editorVC, animated: true)
    }
    
    // 获取当前控制器
    func getCurrentViewcontroller() -> UIViewController?{
        let rootController = UIApplication.shared.keyWindow?.rootViewController
        if let tabController = rootController as? UITabBarController   {
            if let navController = tabController.selectedViewController as? UINavigationController{
                return navController.children.last
            }else{
                return tabController
            }
        }else if let navController = rootController as? UINavigationController {
            return navController.children.last
        }else{
            return rootController
        }
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
