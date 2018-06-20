Pod::Spec.new do |s|
  s.name = 'CLImagePickerTool'
  s.version = '2.3.0'
  s.license = 'MIT'
  s.summary = 'This is a picture selector'
  s.homepage = 'https://github.com/Darren-chenchen/CLImagePickerTool'
  s.authors = { 'Darren-chenchen' => '1597887620@qq.com' }
  s.source = { :git => 'https://github.com/Darren-chenchen/CLImagePickerTool.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'CLImagePickerTool/CLImagePickerTool/**/*.swift'
  s.resource_bundles = { 
	'CLImagePickerTool' => ['CLImagePickerTool/CLImagePickerTool/images/**/*.png','CLImagePickerTool/CLImagePickerTool/**/*.{xib,storyboard}','CLImagePickerTool/CLImagePickerTool/**/*.{lproj,strings}']
  }
end
