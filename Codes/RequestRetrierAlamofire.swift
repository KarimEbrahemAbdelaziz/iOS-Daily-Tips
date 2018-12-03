// Alamofire RequestRetrier Protocol Example.
// It allows a Request that encountered an Error while being executed
// to be retried with an optional delay if specified.
// The retrier allows you to inspect the Request after it has completed
// and run all Validation closures to determine whether it should be retried. 
// When using both the RequestAdapter and RequestRetrier protocols together, 
// you can create credential refresh systems for OAuth1, OAuth2, Basic Auth 
// and even exponential backoff retry policies. The possibilities are endless.

import Foundation
import Alamofire
import SwiftyJSON

class AlamofireManager {
    
    static let shared = AlamofireManager()
    var manager: SessionManager!
    
    private init() {
        let configuration = URLSessionConfiguration.default
        manager = Alamofire.SessionManager(configuration: configuration)
        let authHandler = AuthTokenHandler()
        manager.retrier = authHandler
    }
    
    func reset() {
        let configuration = URLSessionConfiguration.default
        manager = Alamofire.SessionManager(configuration: configuration)
        let authHandler = AuthTokenHandler()
        manager.retrier = authHandler
    }
    
}

class AuthTokenHandler: RequestRetrier {
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
    
    private let lock = NSLock()
    private var token = UserDefaults.standard.string(forKey: "userToken") ?? ""

    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // MARK: - RequestRetrier
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshTokens { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                    
                    if let refreshToken = refreshToken {
                        strongSelf.token = refreshToken
                        let defaults = UserDefaults.standard
                        let token = "Bearer " + refreshToken
                        defaults.set(token, forKey: "userToken")
                    }
                    
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
    
    // MARK: - Private - Refresh Tokens
    private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        
        isRefreshing = true

        sessionManager.request(UserRouter.renewToken())
            .responseJSON { [weak self] response in
                guard let strongSelf = self else { return }

                if let json = response.result.value as? [String: Any] {
                    let refreshToken = JSON(json)["data"]["token"].string
                    let statusCode = JSON(json)["status"]["code"].int
                    if statusCode == 200 {
                        completion(true, nil, refreshToken)
                    } else if statusCode == 400 {
                        // Handle situation if refresh token api return Error,
                        // in my case i would alert user he need to login again.

                        // Don't forget to cancel all requests
                        AlamofireManager.shared.manager.session.invalidateAndCancel()
                        // And reset the manager after invalidate it.
                        AlamofireManager.shared.reset()

                        completion(false, nil, nil)
                    }
                } else {
                    completion(false, nil, nil)
                }

                strongSelf.isRefreshing = false
        }
    }
    
}

// Usage
AlamofireManager.shared.manager.request(UserRouter.getInformationExample())
            // Validate is important so that RequestRetrier Should Functions get called.
            .validate()
            .responseJSON {
                response in
                
                switch(response.result) {
                    
                case .success(let data):
                    break

                case .failure:
                    completion(nil, APIError.networkError)
                    break
                }
        }