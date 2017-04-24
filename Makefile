ANDROID_PROJECT = $(shell ls android_project/)
IOS_WORKSPACE = $(shell ls ios_project | grep xcworkspace)
IOS_SCHEME = $(shell echo $(IOS_WORKSPACE) | cut -f1 -d'.')

# we specify a root target for android to prevent all of the targets from spidering out
./build_ios/libcpp.xcodeproj: libcpp.gyp ./deps/djinni/support-lib/support_lib.gyp bridge.idl
	sh ./run_djinni.sh
	deps/gyp/gyp --depth=. -f xcode -DOS=ios --generator-output ./build_ios -Ideps/djinni/common.gypi ./libcpp.gyp
 
ios: ./build_ios/libcpp.xcodeproj
	sh ./run_djinni.sh
	./objective-c_to_swift_bridging_header_generator.sh
	xcodebuild -workspace ios_project/$(IOS_WORKSPACE) \
	  -scheme $(IOS_SCHEME) \
	  -configuration 'Debug' # \
	  # -sdk iphonesimulator
 
# we specify a root target for android to prevent all of the targets from spidering out
GypAndroid.mk: libcpp.gyp ./deps/djinni/support-lib/support_lib.gyp bridge.idl
	sh ./run_djinni.sh
	ANDROID_BUILD_TOP=$(shell dirname `which ndk-build`) deps/gyp/gyp --depth=. -f android -DOS=android -Ideps/djinni/common.gypi ./libcpp.gyp --root-target=libcpp_jni
 
android_install:
	adb push android_project/$(ANDROID_PROJECT)/app/build/outputs/apk/app-debug.apk \
	         /data/local/tmp/pl.ekk.mkk.unknownwordsrecognizer
	adb shell pm install -r "/data/local/tmp/pl.ekk.mkk.djinnidemo"
	adb shell am start -n "pl.ekk.mkk.djinnidemo/pl.ekk.mkk.djinnidemo.MainActivity" \
	                   -a android.intent.action.MAIN \
	                   -c android.intent.category.LAUNCHER

# this target implicitly depends on GypAndroid.mk since gradle will try to make it
android: GypAndroid.mk
	cd android_project/$(ANDROID_PROJECT)/ && ./gradlew app:assembleDebug
	@echo 'Apks produced at:'
	@python deps/djinni/example/glob.py ./ '*.apk'

clean:
	ndk-build -C android_project/$(ANDROID_PROJECT)/app/ clean
	-xcodebuild -workspace ios_project/$(IOS_WORKSPACE) -scheme $(IOS_SCHEME) -configuration 'Debug' -sdk iphonesimulator clean
	-rm -rf ios_project/$(IOS_SCHEME)/$(IOS_SCHEME)-Bridging-Header.h
	-rm -rf android_project/$(ANDROID_PROJECT)/app/libs/
	-rm -rf android_project/$(ANDROID_PROJECT)/app/obj/
	-rm -rf android_project/$(ANDROID_PROJECT)/app/build/
	-rm -rf android_project/$(ANDROID_PROJECT)/app/build_ios/
	-rm -rf generated-src/cpp/*
	-rm -rf generated-src/java/*
	-rm -rf generated-src/jni/*
	-rm -rf generated-src/objc/*
	-rm -rf build_ios/*
	-rm GypAndroid.mk libcpp_jni.target.mk
