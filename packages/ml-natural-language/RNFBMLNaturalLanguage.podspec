require 'json'
require '../app/firebase_json'
package = JSON.parse(File.read(File.join(__dir__, 'package.json')))
appPackage = JSON.parse(File.read(File.join('..', 'app', 'package.json')))

coreVersionDetected = appPackage['version']
coreVersionRequired = package['peerDependencies'][appPackage['name']]
firebase_sdk_version = appPackage['sdkVersions']['ios']['firebase']
if coreVersionDetected != coreVersionRequired
  Pod::UI.warn "NPM package '#{package['name']}' depends on '#{appPackage['name']}' v#{coreVersionRequired} but found v#{coreVersionDetected}, this might cause build issues or runtime crashes."
end

Pod::Spec.new do |s|
  s.name                = "RNFBMLNaturalLanguage"
  s.version             = package["version"]
  s.description         = package["description"]
  s.summary             = <<-DESC
                            A well tested feature rich Firebase implementation for React Native, supporting iOS & Android.
                          DESC
  s.homepage            = "http://invertase.io/oss/react-native-firebase"
  s.license             = package['license']
  s.authors             = "Invertase Limited"
  s.source              = { :git => "https://github.com/invertase/react-native-firebase.git", :tag => "v#{s.version}" }
  s.social_media_url    = 'http://twitter.com/invertaseio'
  s.ios.deployment_target = "9.0"
  s.source_files        = 'ios/**/*.{h,m}'

  # React Native dependencies
  s.dependency          'React-Core'
  s.dependency          'RNFBApp'

  if defined?($FirebaseSDKVersion)
    Pod::UI.puts "#{s.name}: Using user specified Firebase SDK version '#{$FirebaseSDKVersion}'"
    firebase_sdk_version = $FirebaseSDKVersion
  end

  # Firebase dependencies
  s.dependency          'Firebase/MLNaturalLanguage', firebase_sdk_version

  if FirebaseJSON::Config.get_value_or_default('ml_natural_language_language_id_model', false)
    s.dependency          'Firebase/MLNLLanguageID', firebase_sdk_version
  end

  # ignore until after v6 release, add support in a feature release
  # if FirebaseJSON::Config.get_value_or_default('ml_natural_language_translate_model', false)
  #  s.dependency          'Firebase/MLNLTranslate', firebase_sdk_version
  # end

  if FirebaseJSON::Config.get_value_or_default('ml_natural_language_smart_reply_model', false)
    s.dependency          'Firebase/MLCommon', firebase_sdk_version
    s.dependency          'Firebase/MLNLSmartReply', firebase_sdk_version
  end

  if defined?($RNFirebaseAsStaticFramework)
    Pod::UI.puts "#{s.name}: Using overridden static_framework value of '#{$RNFirebaseAsStaticFramework}'"
    s.static_framework = $RNFirebaseAsStaticFramework
  else
    s.static_framework = false
  end
end