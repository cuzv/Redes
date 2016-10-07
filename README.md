[![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/cuzv/PhotoBrowser/blob/master/LICENSE)
[![CocoaPods Compatible](https://img.shields.io/badge/CocoaPods-v2.0.0-green.svg)](https://github.com/CocoaPods/CocoaPods)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Weibo](https://img.shields.io/badge/Weibo-cuzval-yellowgreen.svg)](http://weibo.com/cuzval/)
[![Twitter](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](http://twitter.com/mochxiao)

# Redes

High-level network layer abstraction library written in Swift.

## Why not just use `Alamofire` directly

- If one day the project manager tell you need to use `Socket` reconstruct all network interfaces, you are going to all the business code to replace the ` Alamofire` to new `Socket` requests?
- A few days late, the project manager tell you some old interfaces must compatible with previous methods, but requires the use of `Socket` new interfaces to achieve, you are going to change the network interfaces which you already reconstructed back?
- Direct use `Alamofire`, all requests related parameters are located in the business code, and there are several different methods of calling the request, such as uploading and downloading and a normal request invoke methods on the inconsistency. Pack all related parameters into an object, you can use only one very method to achieve all different situations request call. Conforms to the [Command Pattern](https://en.wikipedia.org/wiki/Command_pattern) rules
- Wrap network layer, brings more conducive to expansion. If you preferred use `Alamofire` and` Socket` both, only need to specify which way you want to use for request in command inside, and then expand the corresponding request mode implement (default only implements `Alamofire`)
- The code change of network layer does not affect the  business layer, underlying free replacement transducer, a request to call as long as the business layer rule to conform `redes` ask

## Requirements

- iOS 9.0+
- Xcode 8.0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.36 adds supports for Swift and embedded frameworks. You can install it with the following command:

``` bash
$ gem install cocoapods
```

To integrate Redes into your Xcode project using CocoaPods, specify it in your `Podfile`:

``` ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

pod 'Redes'
```

Then, run the following command:

``` bash
$ pod install
```

You should open the `{Project}.xcworkspace` instead of the `{Project}.xcodeproj` after you installed anything from CocoaPods.

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh) using the following command:

``` bash
$ brew update
$ brew install carthage
```

To integrate Redes into your Xcode project using Carthage, specify it in your `Cartfile`:

``` ogdl
github "cuzv/Redes"
```

Then, run the following command to build the Redes framework:

``` bash
$ carthage update
```

At last, you need to set up your Xcode project manually to add the Redes framework.

On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, drag and drop each framework you want to use from the Carthage/Build folder on disk.

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script with the following content:

```
/usr/local/bin/carthage copy-frameworks
```

and add the paths to the frameworks you want to use under “Input Files”:

```
$(SRCROOT)/Carthage/Build/iOS/Redes.framework
```

For more information about how to use Carthage, please see its [project page](https://github.com/Carthage/Carthage).

Since Redes related to [Alamofire](https://github.com/Alamofire/Alamofire), you should do those produce again for Alamofire

## Usage

- Make your API conforms to `Requestable`

``` swift
struct LoginApi: Requestable {
    var userName: String = ""
    var passWord: String = ""

    var url: URLConvertible {
        return "https://host/to/path"
    }
    
	var method: HTTPMethod {
        return .POST
    }
    
    var var bodies: HTTPBodies {
        return [
            "user": userName,
            "pass": passWord
        ]
    }
    
    var headers: HTTPHeaders {
        return [:]
    }
}
```

- Build api and start request & process result

``` swift
let loginRequest = LoginApi().action()

loginRequest.responseJSON {
    debugPrint($0.result)
}

loginRequest.responseJSON(queue: DispatchQueue.global()) {
    debugPrint($0.result)
}
.responseString {
	switch $0.result {
	case .success(let value):
		debugPrint(value)
	case .failure(let error):
         debugPrint(error)
  	}
}
// .cancel()
```

- More information see the demo in project. (Before you run this project, checkout `API.swift` and change the setups to your server configuration.)

### Caching

Caching is handled on the system framework level by [`URLCache`](https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSURLCache_Class/Reference/Reference.html#//apple_ref/occ/cl/NSURLCache).

### Notice

-   v0.x for swift 2.2
-   v1.x for swift 2.3
-   v2.x for swift 3.x

## License

`Redes` is available under the MIT license. See the LICENSE file for more info.

## Contact

Follow me on Twitter ([@mochxiao](https://twitter.com/mochxiao))
