# Redes

High-level network layer abstraction library written in Swift.

## Why not just use `Alamofire` directly

- If one day the project manager tell you need to use `Socket` reconstruct all network interfaces, you are going to all the business code to replace the ` Alamofire` to new `Socket` requests?
- A few days late, the project manager tell you some old interfaces must compatible with previous methods, but requires the use of `Socket` new interfaces to achieve, you are going to change the network interfaces which you already reconstructed back?
- Direct use `Alamofire`, all requests related parameters are located in the business code, and there are several different methods of calling the request, such as uploading and downloading and a normal request invoke methods on the inconsistency. Pack all related parameters into an object, you can use only one very method to achieve all different situations request call. Conforms to the [Command Pattern](https://en.wikipedia.org/wiki/Command_pattern) rules
- wrap network layer, brings more conducive to expansion. If you preferred use `Alamofire` and` Socket` both, only need to specify which way you want to use for request in command inside, and then expand the corresponding request mode implement (default only implements `Alamofire`)
- The code change of network layer does not affect the  business layer, underlying free replacement transducer, a request to call as long as the business layer rule to conform `redes` ask

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

- Build api and start request & process result

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