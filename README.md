# CLImagePickerTool 照片选择器

![Pod Version](https://img.shields.io/cocoapods/v/CLImagePickerTool.svg?style=flat)
![Pod Platform](https://img.shields.io/cocoapods/p/CLImagePickerTool.svg?style=flat)
![Pod License](https://img.shields.io/cocoapods/l/CLImagePickerTool.svg?style=flat)

# 要求

- iOS 8.0+
- swift 3.0+

# 主要功能：

- 图片多选，设置最大可选择的照片数量，对选择后的照片进行压缩处理
- 点击图片进行查看，可缩放
- 视频预览、视频播放、照片预览
- 屏蔽视频文件
- 屏蔽图片资源显示视频资源
- 重置选中状态、预览、异步下载图片
- 视频文件和图片文件不能同时选择
- 图片编辑操作（马赛克，涂鸦，性能得到很大改善）
- 下载iCloud中的照片或者视频文件，显示下载进度
- 单选模式下图片可按照比例裁剪

# 使用方式
1.由于该库设计的图片较多，类也较多，为了避免和项目中的文件冲突建议使用pod管理，有什么问题和需求可及时提出。

pod 'CLImagePickerTool'


建议使用下面的方式及时下载最新版
pod 'CLImagePickerTool', :git => 'https://github.com/Darren-chenchen/CLImagePickerTool.git'

2.支持carthage管理
github "Darren-chenchen/CLImagePickerTool"


# 简介
1.基本用法，默认相机选择在内部、图片多选、支持选择视频文件

		// superVC 当前的控制器 MaxImagesCount最多选择的照片数量
		let imagePickTool = CLImagePickersTool()
		imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,cutImage) in
            print("返回的asset数组是\(asset)")		}

2.设置相机选择在外部 imagePickTool.cameraOut = true


		let imagePickTool = CLImagePickersTool()
		imagePickTool.cameraOut = true
	imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,cutImage) in
            print("返回的asset数组是\(asset)")		}
           
3.设置只支持照片文件，不支持视频文件imagePickTool.isHiddenVideo = true

		let imagePickTool = CLImagePickersTool()
		imagePickTool.isHiddenVideo = true
				imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,cutImage) in
            
        }
        
4.设置图片单选，屏蔽多选
		
		let imagePickTool = CLImagePickersTool()
        imagePickTool.singleImageChooseType = .singlePicture        
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,cutImage) in
            
        }
        

5.单选图片，选择完成后进行裁剪操作imagePickTool.singlePictureCropScale = 2 //宽/高
		
		let imagePickTool = CLImagePickersTool()
        
        imagePickTool.singleImageChooseType = .singlePictureCrop
		
	imagePickTool.setupImagePickerWith(MaxImagesCount: 1, superVC: self) { (asset,cutImage) in
            
        }

6.可以选择视频和图片，但是视频文件和图片文件不能同时选择

		let imagePickTool = CLImagePickersTool()
        imagePickTool.onlyChooseImageOrVideo = true
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,cutImage) in
            
        }


7.设置单选模式下图片可以编辑（涂鸦，马赛克等操作）

		let imagePickTool = CLImagePickersTool()
        imagePickTool.singleImageChooseType = .singlePicture
        imagePickTool.singleModelImageCanEditor = true
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,editorImage) in
            
            self.img.image = editorImage
        }
        
 8.只显示视频文件，不显示图片文件
 
 		let imagePickTool = CLImagePickersTool()
        imagePickTool.isHiddenImage = true
        imagePickTool.setupImagePickerWith(MaxImagesCount: 6, superVC: self) { (asset,editorImage) in
            
        }
        
 9.部分属性介绍
		 		
		// 是否隐藏视频文件，默认不隐藏
		public var isHiddenVideo: Bool = false
		// 是否隐藏图片文件，显示视频文件，默认不隐藏
		public var isHiddenImage: Bool = false
		// 设置单选图片，单选图片并裁剪属性，默认多选
		public var singleImageChooseType: CLImagePickersToolType?
		// 设置相机在外部，默认不在外部
		public var cameraOut: Bool = false
		// 单选模式下图片并且可裁剪。默认裁剪比例是1：1，也可以设置如下参数
		public var singlePictureCropScale: CGFloat?
		// 视频和照片只能选择一种，不能同时选择,默认可以同时选择
		public var onlyChooseImageOrVideo: Bool = false
		// 单选模式下，图片可以编辑，默认不可编辑
		public var singleModelImageCanEditor: Bool = false
		

#### 注意点
1.选择照片以后在返回的PHAsset对象，在CLPickerTool类中提供了PHAsset转image的方法，并可以设置图片压缩。

		let imageArr = CLImagePickersTool.convertAssetArrToImage(assetArr: asset, scale: 0.2)

该方法是同步方法当选择图片较多时可能会等待，我们可以提示一个加载框表示正在处理中

在某些情况下我们不需要原图，只需要缩略图即可，而且获取缩略图的速度是非常快的，我们只需要指定一下需要的图片尺寸即可。如下：

	 let imagePickTool = CLImagePickersTool()
     imagePickTool.setupImagePickerWith(MaxImagesCount: 10, superVC: self) { (asset,cutImage) in
            print("返回的asset数组是\(asset)")

            //获取缩略图，耗时较短
            let imageArr = CLImagePickersTool.convertAssetArrToThumbnailImage(assetArr: asset, targetSize: CGSize(width: 80, height: 80))
            print(imageArr)
        }
		
2.如果是视频文件，提供了PHAsset转AVPlayerItem对象的方法
		
		let Arr = CLImagePickersTool.convertAssetArrToAvPlayerItemArr(assetArr: asset)
		
3.你会发现在选择完图片后提供了2个回调参数 (asset,cutImage)  ，在一般情况下使用asset来转化自己想要的指定压缩大小的图片，而cutImage只有在单选裁剪的情况才会返回，其他情况返回nil



#### 预览

![(logo)](http://images2017.cnblogs.com/blog/818253/201708/818253-20170812093235663-1232169184.png)
![(logo)](http://images2017.cnblogs.com/blog/818253/201708/818253-20170812093301742-51120331.png)
![(logo)](http://images2017.cnblogs.com/blog/818253/201708/818253-20170812093305195-1671898135.png)
![(logo)](http://images2017.cnblogs.com/blog/818253/201708/818253-20170812093310538-791827879.png)
![(logo)](http://images2017.cnblogs.com/blog/818253/201708/818253-20170812093307742-483214885.png)
![(logo)](http://images2017.cnblogs.com/blog/818253/201708/818253-20170812093313101-1657275030.png)
![(logo)](http://images2017.cnblogs.com/blog/818253/201708/818253-20170812093217351-1999910054.png)
![(logo)](http://images2017.cnblogs.com/blog/818253/201708/818253-20170812093209617-1451644996.png)
![(logo)](http://images2017.cnblogs.com/blog/818253/201708/818253-20170812093228101-34143907.png)
![(logo)](http://images2017.cnblogs.com/blog/818253/201708/818253-20170812093802132-2072790927.png)
