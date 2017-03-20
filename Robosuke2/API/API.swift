//
//  API.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 9/20/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import Alamofire
import ObjectMapper

/*
使用例
API.call(Endpoint.RequestProduct.Get) { response in
    switch response {
    case .Success(let result):
        print("success \(result)")
    case .Failure(let error):
        print("failure \(error)")
    }
}
*/

class API {
    class func call<T: RequestProtocol, V>(request: T, completion: @escaping (Result<V>) -> Void) where T.ResponseType == V  {
        Alamofire.request(request)
            .validate(statusCode: 200...401)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                print(String(data: response.data!, encoding: .utf8)!)
                switch response.result {
                case .success(let json) :
                    completion(request.fromJson(json, statusCode: response.response?.statusCode))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }

    class func callArray<T: RequestProtocol, V>(request: T, completion: @escaping (Result<Array<V>>) -> Void) where T.ResponseType == V {
        Alamofire.request(request)
            .validate(statusCode: 200...401)
            .validate(contentType: ["application/json"])
            .responseJSON { response in
                print(String(data: response.data!, encoding: .utf8)!)
                switch response.result {
                case .success(let json):
                    completion(request.fromJsonArray(json, statusCode: response.response?.statusCode))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }

    class func download<T: RequestProtocol>(request: T, completion: @escaping (Result<Data>) -> Void) where T.ResponseType == Data {
        Alamofire.request(request)
            .validate(statusCode: 200...401)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
        }
    }

    class func getToken() -> String? {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let login = appDelegate.login else {
            return nil
        }
        return login.token
    }
}

protocol RequestProtocol: URLRequestConvertible {
    associatedtype ResponseType

    var baseURL: String { get }
    var method: Alamofire.HTTPMethod { get }
    var path: String { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    var encoding: ParameterEncoding { get }

    func fromJson(_ json: Any, statusCode: Int?) -> Result<ResponseType>
    func fromJsonArray(_ json: Any, statusCode: Int?) -> Result<Array<ResponseType>>
}

extension RequestProtocol {
    var method: HTTPMethod {
        return .get
    }

    var baseURL: String {
        return "http://ami-lab.jp/store"
    }

    var headers: [String: String]? {
        guard let token = API.getToken() else {
            return nil
        }
        return ["Authorization": "JWT \(token)"]
    }

    var parameters: [String: Any]? {
        return nil
    }

    var encoding: ParameterEncoding {
        return URLEncoding.default
    }

    func asURLRequest() throws -> URLRequest {
        let url = "\(baseURL)\(path)"
        var urlRequest: URLRequest
        print(url)
        guard let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {

            let errorInfo = [NSLocalizedDescriptionKey: "URL encoding error" , NSLocalizedRecoverySuggestionErrorKey: "Good luck!"]
            let error = NSError(domain: "com.example.app", code: 0, userInfo: errorInfo)
            throw error
        }

        urlRequest = URLRequest(url: try encodedUrl.asURL())
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        do {
            if let parameters = parameters {
                urlRequest.httpBody = try JSONSerialization.data(
                    withJSONObject: parameters, options: JSONSerialization.WritingOptions())
            }
        } catch {
            // No-op
        }
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        return urlRequest
    }

    /*
     NSError について

     1) domain は 識別子。独自で設定する際は com.company.app が通常
     2) code: エラーコード
     3) UserInfoのDictionary: エラーの概要（NSLocalizedDescriptionKey）と復旧方法（NSLocalizedRecoverySuggestionErrorKey）
     */
    func fromJson(_ json: Any, statusCode: Int?) -> Result<ResponseType> {
        guard let statusCode = statusCode else {
            return .failure(NSErrorType.system.error)
        }
        switch statusCode {
        case (200..<300):
            guard let value = json as? ResponseType else {
                return .failure(NSErrorType.system.error)
            }
            return .success(value)
        case 401:
            return .failure(NSErrorType.unauthorization(json).error)
        default:
            return .failure(NSErrorType.system.error)
        }
    }

    func fromJsonArray(_ json: Any, statusCode: Int?) -> Result<Array<ResponseType>> {
        guard let statusCode = statusCode else {
            return .failure(NSErrorType.system.error)
        }
        switch statusCode {
        case (200..<300):
            guard let value = json as? Array<ResponseType> else {
                return .failure(NSErrorType.system.error)
            }
            return .success(value)
        case 401:
            return .failure(NSErrorType.unauthorization(json).error)
        default:
            return .failure(NSErrorType.system.error)
        }
    }

    func fromData(_ data: Data, statusCode: Int?) -> Result<Data> {
        guard let statusCode = statusCode else {
            return .failure(NSErrorType.system.error)
        }
        switch statusCode {
        case (200..<300):
            return .success(data)
        case 401:
            return .failure(NSErrorType.unauthorization(data).error)
        default:
            return .failure(NSErrorType.system.error)
        }
    }

}

extension RequestProtocol where ResponseType: Mappable {
    func fromJson(_ json: Any, statusCode: Int?) -> Result<ResponseType> {
        guard let statusCode = statusCode else {
            return .failure(NSErrorType.system.error)
        }
        switch statusCode {
        case (200..<300):
            guard let value = Mapper<ResponseType>().map(JSONObject: json) else {
                return .failure(NSErrorType.system.error)
            }
            return .success(value)
        case 401:
            return .failure(NSErrorType.unauthorization(json).error)
        default:
            return .failure(NSErrorType.system.error)
        }
    }

    func fromJsonArray(_ json: Any, statusCode: Int?) -> Result<Array<ResponseType>> {
        guard let statusCode = statusCode else {
            return .failure(NSErrorType.system.error)
        }
        switch statusCode {
        case (200..<300):
            guard let value = Mapper<ResponseType>().mapArray(JSONObject: json) else {
                return .failure(NSErrorType.system.error)
            }
            return .success(value)
        case 401:
            return .failure(NSErrorType.unauthorization(json).error)
        default:
            return .failure(NSErrorType.system.error)
        }
    }
}

enum NSErrorType {
    case system
    case unauthorization(Any)
    
    var code: Int {
        switch self {
        case .system:
            return 0
        case .unauthorization:
            return 401
        }
    }
    
    var descriptionKey: String {
        return "エラー"
    }
    
    var recoverySuggestionErrorKey: String {
        switch self {
        case .system:
            return "接続環境の良いところで再度お試しください"
        case .unauthorization(let errorJson):
            guard let errorMessage = self.getErrorMessage(error: errorJson as AnyObject) else {
                return NSErrorType.system.recoverySuggestionErrorKey
            }
            return errorMessage
        }
    }

    var error: NSError {
        let errorInfo = [ NSLocalizedDescriptionKey: self.descriptionKey, NSLocalizedRecoverySuggestionErrorKey: self.recoverySuggestionErrorKey ]
        let error = NSError(domain: "com.example.app", code: self.code, userInfo: errorInfo)
        return error
    }
    
    /**
     token の有効期限が切れていた場合のレスポンスは以下のような Json です
     { "detail": "Signature has expired" }
     */
    private func getErrorMessage(error: AnyObject) -> String? {
        guard let message = error["detail"] else {
            return nil
        }
        return message as! String?
    }
}
