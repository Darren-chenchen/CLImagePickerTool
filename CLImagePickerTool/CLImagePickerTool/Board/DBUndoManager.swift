//
//  DBUndoManager.swift
//  testDemoSwift
//
//  Created by darren on 2017/6/21.
//  Copyright © 2017年 陈亮陈亮. All rights reserved.
//

import UIKit

class DBUndoManager {
    
    var index = -1
    // 数组中保存图片
    var imageArray = [UIImage]()
    
    var canUndo: Bool {
        get {
            return index != -1
        }
    }
    
    var canRedo: Bool {
        get {
            return index + 1 <= imageArray.count
        }
    }
    
    func addImage(_ image: UIImage) {
        // 添加之前先判断是不是还原到最初的状态
        if index == -1 {
            imageArray.removeAll()
        }
        
        let imgData = image.pngData()
        let img = UIImage.init(data: imgData!)
        
        imageArray.append(img!)
        index = imageArray.count - 1
    }
    
    func imageForUndo() -> UIImage? {
        index = index-1
        if index>=0 {
            let imgData = imageArray[index].pngData()
            let img = UIImage.init(data: imgData!)
            return img
        } else {
            index = -1
            return nil
        }
    }
    
    func imageForRedo() -> UIImage? {
        index = index+1
        if index<=imageArray.count-1 {
            let imgData = imageArray[index].pngData()
            let img = UIImage.init(data: imgData!)
            return img
        } else {
            index = imageArray.count-1
            let imgData = imageArray[index].pngData()
            let img = UIImage.init(data: imgData!)
            return img
        }
    }
}
