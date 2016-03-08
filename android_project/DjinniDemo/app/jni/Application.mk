# Android makefile for uwr shared lib, jni wrapper around libhelloworld C API
 
# APP_ABI := armeabi-v7a armeabi x86
APP_ABI := x86  # all
# APP_ABI := all
APP_OPTIM := release
APP_PLATFORM := android-8
# GCC 4.9 Toolchain
NDK_TOOLCHAIN_VERSION = 4.9
# GNU libc++ is the only Android STL which supports C++11 features
APP_STL := gnustl_static
# APP_STL := c++_static
# APP_STL := c++_shared
APP_BUILD_SCRIPT := jni/Android.mk
APP_MODULES := libcpp_jni
APP_CFLAGS += -Wall -Wextra -pedantic -pipe
