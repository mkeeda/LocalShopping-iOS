//
//  AuthorizationModel.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 10/20/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import Alamofire

class AuthorizationModel {
    static let sharedInstance = AuthorizationModel()

    private typealias CachedTask = (Void) -> Void
    private var cachedTasks = Array<CachedTask>()
    private var isRefreshing = false

    func call<T: RequestProtocol, V>(request: T, completion: @escaping (Result<V>) -> Void) where T.ResponseType == V  {
        let cachedTask: CachedTask = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.call(request: request, completion: completion)
        }

        // token の更新中の場合は、リクエストをキャッシュして終了させる
        // token の更新が完了した際に cachedTasks の中身が実行される
        if self.isRefreshing {
            self.cachedTasks.append(cachedTask)
            return
        }

        return API.call(request: request) { response in
            switch response {
            case .success(let json):
                completion(.success(json))
            case .failure(let error):
                // NSError のメッセージが Signature has expired. の場合、リフレッシュトークンの処理を行う
                if error.localizedDescription == "Signature has expired." {
                    self.cachedTasks.append(cachedTask)
                    self.refreshTokens()
                    return
                }
                completion(.failure(error))
            }
        }
    }

    
    func callArray<T: RequestProtocol, V>(request: T, completion: @escaping (Result<Array<V>>) -> Void) where T.ResponseType == V  {
        let cachedTask: CachedTask = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.callArray(request: request, completion: completion)
        }

        // token の更新中の場合は、リクエストをキャッシュして終了させる
        // token の更新が完了した際に cachedTasks の中身が実行される
        if self.isRefreshing {
            self.cachedTasks.append(cachedTask)
            return
        }

        return API.callArray(request: request) { response in
            switch response {
            case .success(let json):
                completion(.success(json))
            case .failure(let error):
                // NSError のメッセージが Signature has expired. の場合、リフレッシュトークンの処理を行う
                if error.localizedDescription == "Signature has expired." {
                    self.cachedTasks.append(cachedTask)
                    self.refreshTokens()
                    return
                }
                completion(.failure(error))
            }
        }
    }


    func download<T: RequestProtocol>(request: T, completion: @escaping (Result<Data>) -> Void) where T.ResponseType == Data {
        let cachedTask: CachedTask = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.download(request: request, completion: completion)
        }

        // token の更新中の場合は、リクエストをキャッシュして終了させる
        // token の更新が完了した際に cachedTasks の中身が実行される
        if self.isRefreshing {
            self.cachedTasks.append(cachedTask)
            return
        }

        return API.download(request: request) { response in
            switch response {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                // NSError のメッセージが Signature has expired. の場合、リフレッシュトークンの処理を行う
                if error.localizedDescription == "Signature has expired." {
                    self.cachedTasks.append(cachedTask)
                    self.refreshTokens()
                    return
                }
                completion(.failure(error))
            }
        }
    }

    func refreshTokens() {
        self.isRefreshing = true

        if let token = API.getToken() {
            API.call(request: Endpoint.Login.refresh(token: token)) { response in
                self.isRefreshing = false
                switch response {
                case .success(let result):
                    // ログイン情報の更新
                    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.login = result
                    let cachedTasksCopy = self.cachedTasks
                    self.cachedTasks.removeAll()
                    cachedTasksCopy.forEach { $0() }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

