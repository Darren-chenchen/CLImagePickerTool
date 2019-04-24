//
//  PopViewUtil.swift
//  testPop
//
//  Created by darren on 2017/6/28.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

public class PopViewUtil: NSObject {
    
    @objc public static let share = PopViewUtil()
    @objc var activite: UIActivityIndicatorView?
    
    @objc public func showLoading() {
        activite = UIActivityIndicatorView.init(style: .whiteLarge)
        activite?.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        activite?.center = (UIApplication.shared.keyWindow?.center)!
        activite?.color = UIColor.black
        UIApplication.shared.keyWindow?.addSubview(activite!)
        self.activite?.startAnimating()
    }
    @objc public func stopLoading() {
        self.activite?.stopAnimating()
        self.activite?.removeFromSuperview()
        self.activite = nil
    }
    
    //MARK: - Returns: 当前控制器
    @objc public static func getCurrentViewcontroller() -> UIViewController?{
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
    
    //MARK: - 标准的样式(标题，内容，左按钮，右按钮)
    @objc public static func  alert(title: String!,message: String!,leftTitle: String!,rightTitle: String!,leftHandler: (() -> ())?,rightHandler: (() -> ())?){
//        let alertVC = HDAlertViewController()
//        alertVC.alert(title: title, message: message, leftTitle: leftTitle, rightTitle: rightTitle, leftHandler: leftHandler, rightHandler: rightHandler)
        let alertView = HDAlertWindowView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height))
        alertView.alert(title: title, message: message, leftTitle: leftTitle, rightTitle: rightTitle, leftHandler: leftHandler, rightHandler: rightHandler)
    }
    
    //MARK: - 只有内容，左按钮，右按钮 或者只显示一个按钮
    @objc public static func alert(message: String!,leftTitle: String!,rightTitle: String!,leftHandler: (() -> ())?,rightHandler: (() -> ())?){
//        let alertVC = HDAlertViewController()
//        alertVC.alert(message: message, leftTitle: leftTitle, rightTitle: rightTitle, leftHandler: leftHandler, rightHandler: rightHandler)
        let alertView = HDAlertWindowView.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height))
        alertView.alert(message: message, leftTitle: leftTitle, rightTitle: rightTitle, leftHandler: leftHandler, rightHandler: rightHandler)
    }
}

//MARK: - toast相关
extension PopViewUtil {
    
}
