//
//  ImagePickerListCell.swift
//  ImageDeal
//
//  Created by darren on 2017/7/27.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class CLImagePickerListCell: UITableViewCell {

    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    var rowData: [String:[CLImagePickerPhotoModel]]? {
        didSet{
            self.titleLable.text = rowData?.keys.first
            let arr = rowData?.values.first
            if arr != nil {
                self.subTitleLabel.text = "(\(arr!.count))"
            } else {
                self.subTitleLabel.text = ""
            }
            var assetModel: CLImagePickerPhotoModel?
            if arr != nil {
                 assetModel = arr!.last
            }
            if assetModel?.phAsset == nil {
                return
            }
            CLPickersTools.instence.getAssetThumbnail(targetSize:CGSize(width:60*UIScreen.main.scale,height:60*UIScreen.main.scale),asset: (assetModel?.phAsset!)!) { (image, info) in
                self.iconView.image = image
            }
        }
    }
    
    static func cellWithTableView(tableView:UITableView) -> CLImagePickerListCell{
        let bundle = Bundle.main
        let ID = "ImagePickerListCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: ID)
        if cell == nil {
            cell = bundle.loadNibNamed("CLImagePickerListCell", owner: nil, options: nil)?.last as! CLImagePickerListCell?
        }
        cell?.selectionStyle = .default
        cell?.accessoryType = .disclosureIndicator
        return cell! as! CLImagePickerListCell
    }
}
