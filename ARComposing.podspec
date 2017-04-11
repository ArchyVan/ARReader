Pod::Spec.new do |s|
  s.name         = 'ARComposing'
  s.summary      = 'Quick Layout Engine.'
  s.version      = '0.0.2'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { 'ArchyVan' => '2440938213@qq.com' }
  s.homepage     = 'https://github.com/ArchyVan/ARReader'
  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.source       = { :git => 'https://github.com/ArchyVan/ARReader.git', :tag => s.version.to_s }
  
  s.requires_arc = true
  s.source_files = 'ARReader/ARComposing/**/*.{h,m}'
  s.public_header_files = 'ARReader/ARComposing/**/*.{h}'

  s.frameworks = 'UIKit', 'CoreFoundation', 'CoreText', 'CoreGraphics', 'CoreImage', 'QuartzCore'

end