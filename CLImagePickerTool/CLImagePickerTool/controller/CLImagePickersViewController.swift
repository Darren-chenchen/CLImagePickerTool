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

typealias CLChooseImageCompleteClouse = (Array<PHAsset>)->()

//MARK: - 导航控制器
class CLImagePickersViewController: UINavigationController {
    
    static let share = CLImagePickersViewController()
    
    var imageCompleteClouse: CLChooseImageCompleteClouse?
    
    let albumVC =  CLImageAlbumPickerController()

    func initWith(MaxImagesCount: Int,cameraOut:Bool,didChooseImageSuccess:@escaping (Array<PHAsset>)->()) -> CLImagePickersViewController {
        
        // 存储用户设置的最多图片数量
        UserDefaults.standard.set(MaxImagesCount, forKey: "CLImagePickerMaxImagesCount")
        UserDefaults.standard.synchronize()
        
        CLNotificationCenter.addObserver(self, selector: #selector(CLPhotoListRefreshNoticMethod(notic:)), name: NSNotification.Name(rawValue:CLPhotoListRefreshNotic), object: nil)
        
        // 清除保存的数据
        CLPickersTools.instence.clearPicture()
        
        let dataArr = CLPickersTools.instence.loadData()
        
        albumVC.dataArr = dataArr
        albumVC.cameraOut = cameraOut
        albumVC.imageCompleteClouse = didChooseImageSuccess
        let vc = CLImagePickersViewController.init(rootViewController: albumVC)
        vc.setupOnce(array: dataArr,cameraOut:cameraOut,didChooseImageSuccess:didChooseImageSuccess)
        return vc
    }
    func setupOnce(array:[[String:[CLImagePickerPhotoModel]]],cameraOut:Bool,didChooseImageSuccess:@escaping (Array<PHAsset>)->()) {
        
        self.imageCompleteClouse = didChooseImageSuccess

        let rowData = array.first
        let singleVC = CLImagePickerSingleViewController.init(nibName: "CLImagePickerSingleViewController", bundle: BundleUtil.getCurrentBundle())
        singleVC.navTitle = rowData?.keys.first ?? ""
        singleVC.photoArr = rowData?.values.first
        if singleVC.navTitle == "所有照片" {
            if cameraOut == false {  // 相机不是放在外面
                singleVC.isAllPhoto = true
            }
        }
        singleVC.singleChooseImageCompleteClouse = { (assetArr:Array<PHAsset>) in
            self.imageCompleteClouse!(assetArr)
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
    
    var imageCompleteClouse: CLChooseImageCompleteClouse?
    
    var cameraOut: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        self.initView()
        
        // 判断用户是否开启访问相册功能
        if CLPickersTools.instence.authorize() == true {
            self.tableView.reloadData()
        }
    }
    
    override func rightBtnClick() {
        self.dismiss(animated: true, completion: nil)
    }
    func initView() {
        self.navTitle = "相册"
        self.backBtn.isHidden = true
        self.rightBtn.setTitle("取消", for: .normal)
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
        if singleVC.navTitle == "所有照片" {
            if cameraOut == false {  // 相机不是放在外面
                singleVC.isAllPhoto = true
            }
        }
        singleVC.singleChooseImageCompleteClouse = { (assetArr:Array<PHAsset>) in
            self.imageCompleteClouse!(assetArr)
        }
        self.navigationController?.pushViewController(singleVC, animated: true)
    }
}


