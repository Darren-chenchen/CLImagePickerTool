//
//  NavgationVCExt.swift
//  paso-ios
//
//  Created by darren on 2017/6/26.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if self.topViewController == nil {
            return .default
        }
        return self.topViewController!.preferredStatusBarStyle
    }
}
