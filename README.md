# CLImagePickerTool
语言：swift   这是一个多图片选择的控件，支持图片多选，视频预览、照片预览

# 效果预览
![(logo)](http://images2017.cnblogs.com/blog/818253/201708/818253-20170803183347350-2103590869.gif)


# 使用方式
		MaxImagesCount 最大选择的照片数量
		cameraOut 相机的选择是放外面还是放在内部
		superVC 当前的控制器CLPickerTool.share.setupImagePickerWith(MaxImagesCount: 6, cameraOut: false, superVC: self) { (asset) in
            print("返回的asset数组是\(asset)")
		}

选择照片以后在返回的PHAsset对象，在CLPickerTool类中提供了PHAsset转image的方法，并可以设置图片压缩。

		let imageArr = CLPickerTool.convertAssetArrToImage(assetArr: asset, scale: 0.2)
		
如果是视频文件，提供了PHAsset转AVPlayerItem对象的方法
		
		let Arr = CLPickerTool.convertAssetArrToAvPlayerItemArr(assetArr: asset)

