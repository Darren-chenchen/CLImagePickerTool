//
//  ImagePickersTools.swift
//  ImageDeal
//
//  Created by darren on 2017/7/27.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class CLImagePickersTools {
    
    static let instence = CLImagePickersTools()
        
    fileprivate var dataArr = [[String:[CLImagePickerPhotoModel]]]()
    
    func loadData() -> Array<[String:[CLImagePickerPhotoModel]]>{
        
        self.dataArr.removeAll()
        
        self.fetchAllSystemAblum()
        self.fetchAllUserCreatedAlbum()
        
        var flagData: [String:[CLImagePickerPhotoModel]]?
        for i in 0..<self.dataArr.count {
            let dict = self.dataArr[i]
            if dict.keys.first == "所有照片" {
                flagData = dict
                self.dataArr.remove(at: i)
                break
            }
        }
        
        if flagData != nil {
            self.dataArr.insert(flagData!, at: 0)
        }
        return dataArr
    }
    
    //1、列出系统所有的相册，并获取每一个相册中的PHAsset对象
    fileprivate func fetchAllSystemAblum() -> Void {
        let smartAlbums:PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        print("智能\(smartAlbums.count)个")
        
        //smartAlbums中保存的是各个智能相册对应的PHAssetCollection
        for i in 0..<smartAlbums.count {
            
            //获取一个相册(PHAssetCollection)
            let collection = smartAlbums[i]
            
            if collection.isKind(of: PHAssetCollection.classForCoder()) {
                
                //赋值
                let assetCollection = collection
                
                //从每一个智能相册获取到的PHFetchResult中包含的才是真正的资源(PHAsset)
                let assetsFetchResults:PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
                
                print("\(String(describing: assetCollection.localizedTitle))相册,共有照片数:\(assetsFetchResults.count)")
                
                var array = [CLImagePickerPhotoModel]()
                assetsFetchResults.enumerateObjects({ (asset, i, nil) in
                    //获取每一个资源(PHAsset)
                    let model = CLImagePickerPhotoModel()
                    model.phAsset = asset
                    array.append(model)
                })
                
                if assetCollection.localizedTitle == nil || array.count == 0 {
                    continue
                }

                var titleStr: String?
                if assetCollection.localizedTitle == "Favorites" {
                    titleStr = "收藏"
                } else if assetCollection.localizedTitle == "Videos" {
                    titleStr = "视频"
                } else if assetCollection.localizedTitle == "All Photos" || assetCollection.localizedTitle == "Camera Roll" {
                    titleStr = "所有照片"
                } else if assetCollection.localizedTitle == "Recently Added" {
                    titleStr = "最近添加"
                } else if assetCollection.localizedTitle == "Screenshots" {
                    titleStr = "屏幕快照"
                } else if assetCollection.localizedTitle == "Selfies" {
                    titleStr = "自拍"
                } else if assetCollection.localizedTitle == "Recently Deleted" {
                    titleStr = "最近删除"
                } else {
                    continue
                }
                dataArr.append([titleStr!:array])
            }
        }
    }
    
    //2、列出用户创建的相册，并获取每一个相册中的PHAsset对象，代码如下：
    fileprivate func fetchAllUserCreatedAlbum() -> Void {
        let topLevelUserCollections:PHFetchResult = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        
        //topLevelUserCollections中保存的是各个用户创建的相册对应的PHAssetCollection
        print("用户创建\(topLevelUserCollections.count)个")
        
        for i in 0..<topLevelUserCollections.count {
            
            //获取一个相册(PHAssetCollection)
            let collection = topLevelUserCollections[i]
            if collection.isKind(of: PHAssetCollection.classForCoder()) {
                
                //类型强制转换
                let assetCollection = collection as! PHAssetCollection
                
                
                //从每一个智能相册中获取到的PHFetchResult中包含的才是真正的资源(PHAsset)
                let assetsFetchResults:PHFetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
                
                print("\(String(describing: assetCollection.localizedTitle))相册，共有照片数:\(assetsFetchResults.count)")
                
                var array = [CLImagePickerPhotoModel]()
                assetsFetchResults.enumerateObjects({ (asset, i, nil) in
                    //获取每一个资源(PHAsset)
                    let model = CLImagePickerPhotoModel()
                    model.phAsset = asset
                    array.append(model)
                })
                
                if assetCollection.localizedTitle == nil || array.count == 0 {
                    continue
                }
                dataArr.append([assetCollection.localizedTitle!:array])
            }
        }
    }
    
    
    //3、获取所有资源的集合，并按资源的创建时间排序
    fileprivate func getAllSourceCollection() -> Void {
        
        let options:PHFetchOptions = PHFetchOptions.init()
        var assetArray = [PHAsset]()
        options.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: true)]
        let assetFetchResults:PHFetchResult = PHAsset.fetchAssets(with: options)
        for i in 0..<assetFetchResults.count {
            //获取一个资源(PHAsset)
            let asset = assetFetchResults[i]
            //添加到数组
            assetArray.append(asset)
        }
    }
    
    
    //4、获取缩略图方法
    //    PHImageRequestOptions 中常常会用的几个属性如下：
    //    networkAccessAllowed 参数控制是否允许网络请求，默认为 NO，如果不允许网络请求，那么就没有然后了，当然也拉取不到 iCloud 的图像原件。deliveryMode 则用于控制请求的图片质量。synchronous 控制是否为同步请求，默认为 NO，如果?synchronous 为 YES，即同步请求时，deliveryMode 会被视为 PHImageRequestOptionsDeliveryModeHighQualityFormat，即自动返回高质量的图片，因此不建议使用同步请求，否则如果界面需要等待返回的图像才能进一步作出反应，则反应时长会很长。
//    还有一个与 iCloud 密切相关的属性?progressHandler，当图像需要从 iCloud 下载时，这个 block 会被自动调用，block 中会返回图像下载的进度，图像的信息，出错信息。开发者可以利用这些信息反馈给用户当前图像的下载进度以及状况，但需要注意?progressHandler 不在主线程上执行，因此在其中需要操作 UI，则需要手工放到主线程执行
    func getAssetThumbnail(targetSize:CGSize,asset:PHAsset,dealImageSuccess:@escaping (UIImage?,[AnyHashable:Any]?) -> ()) -> Void {
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
    
    //5、获取原图的方法
    func getAssetOrigin(asset:PHAsset,dealImageSuccess:@escaping (UIImage?,[AnyHashable:Any]?) -> ()) -> Void {
        
        //获取原图
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions() //可以设置图像的质量、版本、也会有参数控制图像的裁剪
        manager.requestImage(for: asset, targetSize:PHImageManagerMaximumSize, contentMode: .aspectFit, options: option) { (originImage, info) in
            dealImageSuccess(originImage,info)
        }
    }
    
    
    // 6.判断照片是否存在本地
    func testImageInLocal(asset: PHAsset) -> Bool {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = false
        option.isSynchronous = true
        
        var isInLocalAblum: Bool?
        manager.requestImageData(for: asset, options: option, resultHandler: { (imageData, dataUTI, orientation, info) in
            isInLocalAblum = imageData == nil ? true:false
        })
        
        return isInLocalAblum!
    }
    
    // 存储用户选择的照片
    func savePicture(asset: PHAsset,isAdd: Bool){
        // 如果是添加
        if isAdd {
            // 取出之前的数据
            let dataArr = UserDefaults.standard.value(forKey: CLChooseImageAssetLocalIdentifierKey)
            if dataArr == nil {  // 第一次存
                let arr = [asset.localIdentifier]
                UserDefaults.standard.set(arr, forKey: CLChooseImageAssetLocalIdentifierKey)
                UserDefaults.standard.synchronize()
            } else {
                var arr: Array<String> = dataArr as! Array<String>
                arr.append(asset.localIdentifier)
                UserDefaults.standard.set(arr, forKey: CLChooseImageAssetLocalIdentifierKey)
                UserDefaults.standard.synchronize()
            }
        } else {  // 非选中
            // 取出之前的数据
            let dataArr = UserDefaults.standard.value(forKey: CLChooseImageAssetLocalIdentifierKey)
            var arr: Array<String> = dataArr as! Array<String>
            arr.remove(at: arr.index(of: asset.localIdentifier)!)
            UserDefaults.standard.set(arr, forKey: CLChooseImageAssetLocalIdentifierKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    // 获取保存的数量
    func getSavePictureCount() -> Int{
        let dataArr = UserDefaults.standard.value(forKey: CLChooseImageAssetLocalIdentifierKey)
        if dataArr == nil {
            return 0
        } else {
            return (dataArr as! Array<String>).count
        }
    }
    
    // 通过localIdentifier取出用户选择的照片
    func getChoosePictureArray() -> Array<PHAsset> {
        let dataArr = UserDefaults.standard.value(forKey: CLChooseImageAssetLocalIdentifierKey)
        if dataArr == nil {
            return [PHAsset]()
        } else {
            var arr = [PHAsset]()
            let assetArrResult = PHAsset.fetchAssets(withLocalIdentifiers: dataArr as! Array<String>, options: nil)
            assetArrResult.enumerateObjects({ (asset, i, nil) in
                //获取每一个资源(PHAsset)
                arr.append(asset)
            })
            return arr
        }
    }
    
    // 清除保存的数据
    func clearPicture() {
        let arr = [String]()
        UserDefaults.standard.set(arr, forKey: CLChooseImageAssetLocalIdentifierKey)
        UserDefaults.standard.synchronize()
    }
    
    //MARK: - 渐变色
    func setupBottomViewGradient(superView:UIView) {
        //  创建 CAGradientLayer 对象
        let gradientLayer = CAGradientLayer()
        //  设置 gradientLayer 的 Frame
        gradientLayer.frame = superView.bounds;
        //  创建渐变色数组，需要转换为CGColor颜色
        gradientLayer.colors = [CoustomColor(0, g: 0, b: 0, a: 0).cgColor,CoustomColor(0, g: 0, b: 0, a: 0.5).cgColor,CoustomColor(0, g: 0, b: 0, a: 1.0).cgColor]
        //  设置三种颜色变化点，取值范围 0.0~1.0
        gradientLayer.locations = [0.0,0.4,1]
        //  添加渐变色到创建的 UIView 上去
        superView.layer.addSublayer(gradientLayer)
    }

    
    // 用户是否开启权限
    func authorize()->Bool{
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            // 请求授权
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    _ = self.authorize()
                })
            })
        default: ()
        DispatchQueue.main.async(execute: { () -> Void in
            
            PopViewUtil.alert(title: "照片访问受限", message: "点击“设置”，允许访问您的照片", leftTitle: "取消", rightTitle: "设置", leftHandler: {
                
            }, rightHandler: {
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:],
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
        return false
    }
    
    // 用户是否开启相机权限
    func authorizeCamaro()->Bool{
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            // 请求授权
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    _ = self.authorize()
                })
            })
        default: ()
        DispatchQueue.main.async(execute: { () -> Void in
            
            PopViewUtil.alert(title: "相机访问受限", message: "点击“设置”，允许访问您的相机", leftTitle: "取消", rightTitle: "设置", leftHandler: {
                
            }, rightHandler: {
                let url = URL(string: UIApplicationOpenSettingsURLString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:],
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
        return false
    }

}
