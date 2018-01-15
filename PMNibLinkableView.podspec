Pod::Spec.new do |s|
  s.name             = 'PMNibLinkableView'
  s.version          = '0.4.0'
  s.summary          = 'Inject view from nib file to storyboard'
  s.description      = 'Inject view from nib file to storyboard.'
  s.homepage         = 'https://github.com/IvanUshakov/PMNibLinkableView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Ivan' => '' }
  s.source           = { :git => 'https://github.com/IvanUshakov/PMNibLinkableView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'

  s.source_files = 'PMNibLinkableView.{h,m}'
end