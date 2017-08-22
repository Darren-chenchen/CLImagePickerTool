//
//  ImagePickersViewController.swift
//  ImageDeal
//
//  Created by darren on 2017/7/27.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

typealias CLChooseImageCompleteClouse = (Array<PHAsset>,UIImage?)->()

//MARK: - 导航控制器
class CLImagePickersViewController: UINavigationController {
    
    static let share = CLImagePickersViewController()
    
    var imageCompleteClouse: CLChooseImageCompleteClouse?
    
    let albumVC =  CLImageAlbumPickerController()

    func initWith(MaxImagesCount: Int,isHiddenVideo:Bool,cameraOut:Bool,singleType:CLImagePickersToolType?,singlePictureCropScale:CGFloat?,onlyChooseImageOrVideo:Bool,singleModelImageCanEditor: Bool,didChooseImageSuccess:@escaping (Array<PHAsset>,UIImage?)->()) -> CLImagePickersViewController {
        
        // 存储用户设置的最多图片数量
        UserDefaults.standard.set(MaxImagesCount, forKey: CLImagePickerMaxImagesCount)
        UserDefaults.standard.synchronize()
        
        CLNotificationCenter.addObserver(self, selector: #selector(CLPhotoListRefreshNoticMethod(notic:)), name: NSNotification.Name(rawValue:CLPhotoListRefreshNotic), object: nil)
        
        // 清除保存的数据
        CLPickersTools.instence.clearPicture()
        // 如果用户之前设置的是onlyChooseImageOrVideo类型，记得将这个类型刚开始就置空
        UserDefaults.standard.set(0, forKey: UserChooserType)
        UserDefaults.standard.synchronize()
        
        CLPickersTools.instence.isHiddenVideo = isHiddenVideo  // 是否隐藏视频文件赋值
        let dataArr = CLPickersTools.instence.loadData()
        
        albumVC.dataArr = dataArr
        albumVC.cameraOut = cameraOut
        albumVC.imageCompleteClouse = didChooseImageSuccess
        albumVC.singleType = singleType
        albumVC.singlePictureCropScale = singlePictureCropScale
        albumVC.onlyChooseImageOrVideo = onlyChooseImageOrVideo
        albumVC.singleModelImageCanEditor = singleModelImageCanEditor
        
        let vc = CLImagePickersViewController.init(rootViewController: albumVC)
        vc.setupOnce(array: dataArr,cameraOut:cameraOut,singleType:singleType,singlePictureCropScale:singlePictureCropScale,onlyChooseImageOrVideo:onlyChooseImageOrVideo,singleModelImageCanEditor:singleModelImageCanEditor,didChooseImageSuccess:didChooseImageSuccess)
        return vc
    }
    func setupOnce(array:[[String:[CLImagePickerPhotoModel]]],cameraOut:Bool,singleType:CLImagePickersToolType?,singlePictureCropScale:CGFloat?,onlyChooseImageOrVideo:Bool,singleModelImageCanEditor:Bool,didChooseImageSuccess:@escaping (Array<PHAsset>,UIImage?)->()) {
        
        self.imageCompleteClouse = didChooseImageSuccess

        let rowData = array.first
        let singleVC = CLImagePickerSingleViewController.init(nibName: "CLImagePickerSingleViewController", bundle: BundleUtil.getCurrentBundle())
        singleVC.navTitle = rowData?.keys.first ?? ""
        singleVC.photoArr = rowData?.values.first
        if singleVC.navTitle == allPhoto || singleVC.navTitle == allPhoto2 || singleVC.navTitle == allPhoto3 {
            if cameraOut == false {  // 相机不是放在外面
                singleVC.isAllPhoto = true
            }
        }
        singleVC.onlyChooseImageOrVideo = onlyChooseImageOrVideo
        singleVC.singlePictureCropScale = singlePictureCropScale
        singleVC.singleType = singleType
        singleVC.singleModelImageCanEditor = singleModelImageCanEditor
        singleVC.singleChooseImageCompleteClouse = { (assetArr:Array<PHAsset>,image) in
            self.imageCompleteClouse!(assetArr,image)
        }
        self.pushViewController(singleVC, animated: true)        
    }
    
    deinit {
        print("CLImagePickersViewController释放")
        CLNotificationCenter.removeObserver(self)
    }
    
    func CLPhotoListRefreshNoticMethod(notic:Notification) {
        albumVC.dataArr = notic.object as? [[String : [CLImagePickerPhotoModel]]]
    }
    
}

//MARK: - 相册列表控制器
class CLImageAlbumPickerController: CLBaseImagePickerViewController {
    
    var imageCompleteClouse: CLChooseImageCompleteClouse?
    
    // 相机是否放在内部
    var cameraOut: Bool = false
    // 单选状态的类型
    var singleType: CLImagePickersToolType?
    // 图片裁剪比例
    var singlePictureCropScale: CGFloat?
    // 视频和照片只能选择一种，不能同时选择,默认可以同时选择
    var onlyChooseImageOrVideo: Bool = false
    // 单选模式下图片可以编辑
    var singleModelImageCanEditor: Bool = false
    
    lazy var tableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect(x:0,y:64,width:KScreenWidth,height:KScreenHeight-64), style: .plain)
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        self.view.addSubview(tableView)
        return tableView
    }()
    
    fileprivate var dataArr: [[String:[CLImagePickerPhotoModel]]]? {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.initView()
        
        // 判断用户是否开启访问相册功能
        CLPickersTools.instence.authorize(authorizeClouse: { (state) in
            if state == .authorized {
                self.tableView.reloadData()
            } else {
                return
            }
        })

    }
    
    override func rightBtnClick() {
        self.dismiss(animated: true, completion: nil)
    }
    func initView() {
        self.navTitle = photoStr
        self.backBtn.isHidden = true
        self.rightBtn.setTitle(cancelStr, for: .normal)
    }
    
    deinit {
        print("CLImageAlbumPickerController释放")        
    }
}

//MARK: - UITableViewDelegate,UITableViewDataSource
extension CLImageAlbumPickerController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataArr == nil {
            return 0
        } else {
            return self.dataArr!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CLImagePickerListCell.cellWithTableView(tableView: tableView)
        cell.rowData = self.dataArr?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let rowData = self.dataArr?[indexPath.row]
        let singleVC = CLImagePickerSingleViewController.init(nibName: "CLImagePickerSingleViewController", bundle: BundleUtil.getCurrentBundle())
        singleVC.navTitle = rowData?.keys.first ?? ""
        singleVC.photoArr = rowData?.values.first
        if singleVC.navTitle == allPhoto || singleVC.navTitle == allPhoto2 || singleVC.navTitle == allPhoto3 {
            if cameraOut == false {  // 相机不是放在外面
                singleVC.isAllPhoto = true
            }
        }
        singleVC.onlyChooseImageOrVideo = onlyChooseImageOrVideo
        singleVC.singleType = singleType
        singleVC.singleModelImageCanEditor = singleModelImageCanEditor
        singleVC.singlePictureCropScale = singlePictureCropScale
        singleVC.singleChooseImageCompleteClouse = { (assetArr:Array<PHAsset>,image) in
            self.imageCompleteClouse!(assetArr,image)
        }
        self.navigationController?.pushViewController(singleVC, animated: true)
    }
}


