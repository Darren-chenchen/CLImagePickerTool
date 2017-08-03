//
//  BundleUtil.swift
//  PopupAlert-iOS
//
//  Created by darren on 2017/8/2.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class BundleUtil {
    
    static func getCurrentBundle() -> Bundle{
                
        let podBundle = Bundle(for: CLImagePickersTool.self)
        let bundleURL = podBundle.url(forResource: "CLImagePickerTool", withExtension: "bundle")
        if bundleURL != nil {
            let bundle = Bundle(url: bundleURL!)!
            return bundle
        }else{
            return Bundle.main
        }
    }

}
