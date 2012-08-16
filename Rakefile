def discover_latest_sdk_version
  latest_iphone_sdk = `xcodebuild -showsdks | grep -o "iphoneos.*$"`.chomp
  version_part = latest_iphone_sdk[/iphoneos(.*)/,1]
  version_part
end

desc "Build the arm library"
task :build_iphone_lib do
  sh "xcodebuild -configuration Debug -sdk iphoneos#{discover_latest_sdk_version} BUILD_DIR=build clean build"
end

desc "Build the i386 library"
task :build_simulator_lib do
  sh "xcodebuild -configuration Debug -sdk iphonesimulator#{discover_latest_sdk_version} BUILD_DIR=build clean build"
end

task :combine_libraries do
  FileUtils.mkdir_p 'dist'
  sh %Q|lipo -create -output "dist/libPublicAutomation.a" "build/Debug-iphoneos/libPublicAutomation.a" "build/Debug-iphonesimulator/libPublicAutomation.a"|
end

task :copy_headers do
  raise 'TODO'
end

desc "Build a univeral library for both iphone and iphone simulator"
task :build_lib => [:build_iphone_lib,:build_simulator_lib,:combine_libraries]

task :default => :build_lib
