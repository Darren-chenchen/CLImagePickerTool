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

public enum CLImagePickersToolType {
    case singlePicture   // 图片单选
    case singlePictureCrop   // 单选并裁剪
}

typealias CLPickerToolClouse = (Array<PHAsset>,UIImage?)->()

public class CLImagePickersTool: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
        
    @objc var cameraPicker: UIImagePickerController!
    
    @objc var  superVC: UIViewController?
    
    @objc var clPickerToolClouse: CLPickerToolClouse?
    
    // 是否隐藏视频文件，默认不隐藏
    @objc public var isHiddenVideo: Bool = false
    // 是否隐藏图片文件，显示视频文件，默认不隐藏
    @objc public var isHiddenImage: Bool = false
    // 设置单选图片，单选图片并裁剪属性，默认多选
    public var singleImageChooseType: CLImagePickersToolType?
    // 设置相机在外部，默认不在外部
    @objc public var cameraOut: Bool = false
    // 单选模式下图片并且可裁剪。默认裁剪比例是1：1，也可以设置如下参数
    public var singlePictureCropScale: CGFloat?
    // 视频和照片只能选择一种，不能同时选择,默认可以同时选择
    @objc public var onlyChooseImageOrVideo: Bool = false
    // 单选模式下，图片可以编辑，默认不可编辑
    @objc public var singleModelImageCanEditor: Bool = false
    
    // 判断相机是放在外面还是内部
    @objc public func setupImagePickerWith(MaxImagesCount: Int,superVC:UIViewController,didChooseImageSuccess:@escaping (Array<PHAsset>,UIImage?)->()) {
        
        self.superVC = superVC
        self.clPickerToolClouse = didChooseImageSuccess
        
        if self.cameraOut == true {  // 拍照功能在外面
            var alert: UIAlertController!
            alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let cleanAction = UIAlertAction(title: cancelStr, style: UIAlertActionStyle.cancel,handler:nil)
            let photoAction = UIAlertAction(title: tackPhotoStr, style: UIAlertActionStyle.default){ (action:UIAlertAction)in
                
                self.camera(superVC:superVC)
            }
            let choseAction = UIAlertAction(title: chooseStr, style: UIAlertActionStyle.default){ (action:UIAlertAction)in
                
                // 判断用户是否开启访问相册功能
                CLPickersTools.instence.authorize(authorizeClouse: { (state) in
                    if state == .authorized {
                        let photo = CLImagePickersViewController.share.initWith(MaxImagesCount: MaxImagesCount,isHiddenVideo:self.isHiddenVideo,cameraOut:self.cameraOut,singleType:self.singleImageChooseType,singlePictureCropScale:self.singlePictureCropScale,onlyChooseImageOrVideo:self.onlyChooseImageOrVideo,singleModelImageCanEditor:self.singleModelImageCanEditor,isHiddenImage:self.isHiddenImage) { (assetArr,cutImage) in
                            if self.clPickerToolClouse != nil {
                                self.clPickerToolClouse!(assetArr,cutImage)
                            }
                        }
                        superVC.present(photo, animated: true, completion: nil)
                    }
                })
            }
            
            alert.addAction(cleanAction)
            alert.addAction(photoAction)
            alert.addAction(choseAction)
            superVC.present(alert, animated: true, completion: nil)

        } else {
            // 判断用户是否开启访问相册功能
            CLPickersTools.instence.authorize(authorizeClouse: { (state) in
                if state == .authorized {
                    let photo = CLImagePickersViewController.share.initWith(MaxImagesCount: MaxImagesCount,isHiddenVideo:self.isHiddenVideo,cameraOut:self.cameraOut,singleType:self.singleImageChooseType,singlePictureCropScale:self.singlePictureCropScale,onlyChooseImageOrVideo:self.onlyChooseImageOrVideo,singleModelImageCanEditor:self.singleModelImageCanEditor,isHiddenImage:self.isHiddenImage) { (assetArr,cutImage) in
                        didChooseImageSuccess(assetArr,cutImage)
                    }
                    superVC.present(photo, animated: true, completion: nil)
                }
            })
            
        }
    }
    
    @objc public func camera(superVC:UIViewController) {
        
        CLPickersTools.instence.authorizeCamaro { (state) in
            if state == .authorized {
                self.cameraPicker = UIImagePickerController()
                self.cameraPicker.delegate = self
                self.cameraPicker.sourceType = .camera
                superVC.present((self.cameraPicker)!, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - 提供asset数组转图片的方法供外界使用---原图,异步方法，每转换成一张图片就返回出去
    @objc public static func convertAssetArrToOriginImage(assetArr:Array<PHAsset>,scale:CGFloat,successClouse:@escaping (UIImage,PHAsset)->(),failedClouse:@escaping ()->()) {
        
        for item in assetArr {
//            if item.mediaType == .image {  // 如果是图片
                CLImagePickersTool.getAssetOrigin(asset: item, dealImageSuccess: { (img, info) in
                    if img != nil {
                        // 对图片压缩
                        let zipImageData = UIImageJPEGRepresentation(img!,scale)!
                        let image = UIImage(data: zipImageData)

                        successClouse(image!,item)
                    }
                }, dealImageFailed: {
                    failedClouse()
                })
//            }
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
    
    // 获取原图的方法  异步
    @objc static func getAssetOrigin(asset:PHAsset,dealImageSuccess:@escaping (UIImage?,[AnyHashable:Any]?) -> (),dealImageFailed:@escaping () -> ()) -> Void {
        //获取原图
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions() //可以设置图像的质量、版本、也会有参数控制图像的裁剪
        option.isNetworkAccessAllowed = true  // iCloud上的照片需要下载
        option.resizeMode   = .fast
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
    // 获取缩略图的方法  同步
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
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true) {}
        
        // 保存到相册
        let type = info[UIImagePickerControllerMediaType] as? String
        if type == "public.image" {
            let photo = info[UIImagePickerControllerOriginalImage]
            UIImageWriteToSavedPhotosAlbum(photo as! UIImage, self, #selector(CLImagePickersTool.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 保存图片的结果
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if let err = error {
            UIAlertView(title: errorStr, message: err.localizedDescription, delegate: nil, cancelButtonTitle: sureStr).show()
        } else {
            
            let dataArr = CLPickersTools.instence.loadData()
            let newModel = dataArr.first?.values.first?.last
            
            if self.clPickerToolClouse != nil {
                if newModel?.phAsset != nil {
                    self.clPickerToolClouse!([(newModel?.phAsset)!],image)
                }
            }
        }
    }

}

