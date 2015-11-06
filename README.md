# Redes

High-level network layer abstraction library written in Swift.

## Features

- [x] Wrap `Alamofire`, which means support `Alamofire`'s all features
- [ ] Networking status check
- [ ] Result cache

## Requirements

- iOS 8.0+
- Xcode 7.1+

## Usage

- Make your API conforms to `protocol<Requestable, Responseable>`

``` swift
struct LoginApi: Requestable, Responseable {
    var userName: String = ""
    var passWord: String = ""

    var requestURLPath: URLStringConvertible {
        return "https://host/to/path"
    }
    var requestMethod: Redes.Method {
        return .POST
    }
    var requestBodyParameters: [String: AnyObject] {
        return [
            "user": userName,
            "pass": passWord
        ]
    }
}
```

- Build api and start request && process result

``` swift
import Redes
let loginApi = LoginApi(userName: "user", passWord: "pass")
    Redes.request(loginApi)
        .responseJSON {
            debugPrint($0)
        }
        .responseString {
            switch $0 {
            case .Success(_, let string):
                debugPrint(string)
            case .Failure(_, let error):
                debugPrint(error)
            }
        }
//        .cancel()
```

- More information see the demo in project.

## License

`Redes` is available under the MIT license. See the LICENSE file for more info.

## Contact

Follow me on Twitter ([@mochxiao](https://twitter.com/mochxiao))