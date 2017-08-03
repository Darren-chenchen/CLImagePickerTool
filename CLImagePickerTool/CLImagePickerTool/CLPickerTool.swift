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

typealias CLPickerToolClouse = (Array<PHAsset>)->()

class CLPickerTool: NSObject {
    
    static let share = CLPickerTool()
    
    var cameraPicker: UIImagePickerController!
    
    var superVC: UIViewController?
    
    var clPickerToolClouse: CLPickerToolClouse?

    // 判断相机是放在外面还是内部
    public func setupImagePickerWith(MaxImagesCount: Int,cameraOut:Bool,superVC:UIViewController,didChooseImageSuccess:@escaping (Array<PHAsset>)->()) {
        
        self.superVC = superVC
        self.clPickerToolClouse = didChooseImageSuccess
        
        if cameraOut {  // 拍照功能在外面
            var alert: UIAlertController!
            alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let cleanAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel,handler:nil)
            let photoAction = UIAlertAction(title: "拍照", style: UIAlertActionStyle.default){ (action:UIAlertAction)in
                
                self.camera(superVC:superVC)
            }
            let choseAction = UIAlertAction(title: "从手机相册选择", style: UIAlertActionStyle.default){ (action:UIAlertAction)in
                
                // 判断用户是否开启访问相册功能
                if CLImagePickersTools.instence.authorize() == false {
                    return
                }
                
                let photo = CLImagePickersViewController.share.initWith(MaxImagesCount: MaxImagesCount,cameraOut:cameraOut) { (assetArr) in
                    if self.clPickerToolClouse != nil {
                        self.clPickerToolClouse!(assetArr)
                    }
                }
                superVC.present(photo, animated: true, completion: nil)
            }
            
            alert.addAction(cleanAction)
            alert.addAction(photoAction)
            alert.addAction(choseAction)
            superVC.present(alert, animated: true, completion: nil)

        } else {
            // 判断用户是否开启访问相册功能
            if CLImagePickersTools.instence.authorize() == false {
                return
            }
            let photo = CLImagePickersViewController.share.initWith(MaxImagesCount: MaxImagesCount,cameraOut:cameraOut) { (assetArr) in
                didChooseImageSuccess(assetArr)
            }
            superVC.present(photo, animated: true, completion: nil)
        }
    }
    
    func camera(superVC:UIViewController) {
        if CLImagePickersTools.instence.authorizeCamaro() == false {
            return
        }
        self.cameraPicker = UIImagePickerController()
        self.cameraPicker.delegate = self
        self.cameraPicker.sourceType = .camera
        superVC.present((self.cameraPicker)!, animated: true, completion: nil)
    }
    
    
    //MARK: - 提供asset数组转图片的方法供外界使用
    public static func convertAssetArrToImage(assetArr:Array<PHAsset>,scale:CGFloat) -> [UIImage] {

        var imageArr = [UIImage]()
        for item in assetArr {
            if item.mediaType == .image {  // 如果是图片
                CLPickerTool.share.getAssetOrigin(asset: item, dealImageSuccess: { (img, info) in
                    if img != nil {
                        
                        // 对图片压缩
                        let zipImageData = UIImageJPEGRepresentation(img!,scale)!
                        let image = UIImage(data: zipImageData)
                        imageArr.append(image!)
                    }
                })
            }
        }
        return imageArr
    }
    //MARK: - 提供asset数组中的视频文件转为AVPlayerItem数组
    public static func convertAssetArrToAvPlayerItemArr(assetArr:Array<PHAsset>) -> [AVPlayerItem] {
        
        var videoArr = [AVPlayerItem]()
        for item in assetArr {
            if item.mediaType == .video {  // 如果是图片
                let manager = PHImageManager.default()
                let videoRequestOptions = PHVideoRequestOptions()
                videoRequestOptions.deliveryMode = .automatic
                videoRequestOptions.version = .current
                videoRequestOptions.isNetworkAccessAllowed = true
                manager.requestPlayerItem(forVideo: item, options: videoRequestOptions) { (playItem, info) in
                    if playItem != nil {
                        videoArr.append(playItem!)
                    }
                }
            }
        }
        return videoArr
    }
    
    // 获取原图的方法  同步
    func getAssetOrigin(asset:PHAsset,dealImageSuccess:@escaping (UIImage?,[AnyHashable:Any]?) -> ()) -> Void {
        //获取原图
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions() //可以设置图像的质量、版本、也会有参数控制图像的裁剪
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize:PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (originImage, info) in
            dealImageSuccess(originImage,info)
        }
    }

}

extension CLPickerTool:UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        self.superVC?.dismiss(animated: true) {}
        
        // 保存到相册
        let type = info[UIImagePickerControllerMediaType] as? String
        if type == "public.image" {
            let photo = info[UIImagePickerControllerOriginalImage]
            UIImageWriteToSavedPhotosAlbum(photo as! UIImage, self, #selector(CLPickerTool.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.superVC?.dismiss(animated: true, completion: nil)
    }
    
    // 保存图片的结果
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer) {
        if let err = error {
            UIAlertView(title: "错误", message: err.localizedDescription, delegate: nil, cancelButtonTitle: "确定").show()
        } else {
            
            let dataArr = CLImagePickersTools.instence.loadData()
            let newModel = dataArr.first?.values.first?.last
            
            if self.clPickerToolClouse != nil {
                if newModel?.phAsset != nil {
                    self.clPickerToolClouse!([(newModel?.phAsset)!])
                }
            }
        }

    }
    
}

