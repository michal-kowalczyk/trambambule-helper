# djinni4swift

This project is meant to be a helper during Djinni's presentations. It consists of:

- Android project
- iOS project (with Swift)

In the same time it acts as an example of using Swift with Djinni thanks to [a script](objective-c_to_swift_bridging_header_generator.sh) that generates bridging headers in order to let use generated by Djinni Objective-C classes in Swift.

Project illustrates how to perform:

- a simple call in Java/Swift to C++,
- a call in Java/Swift to C++ with an object implemented in Java/Swift passed that can be used in C++ code in order to give a result back to Java/Swift code.

Requirements

- python
- Android
  - android ndk and ndk-build on your PATH to build for android
  - android ndk path provided in ```android_project/DjinniDemo/local.properties``` (as in [example](android_project/DjinniDemo/local.properties.example))
- iOS
  - xcode & xcodebuild

In order to build projects, run:

- ```make ios```
- ```make android```

Sometimes cleaning projects is required:

- ```make clean```

For more information about djinni, please visit:

- [djinni's github page](https://github.com/dropbox/djinni)
- [mobile c++ tutorials](http://mobilecpptutorials.com)

