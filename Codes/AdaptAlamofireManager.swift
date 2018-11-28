// Inject your headers rather than setting them hardly ;)
// In Alamofire 4 or above there is RequestAdapter protocol 
// that used to inspected and adapted the request before being created.
// So we can do what ever needed here in request 
// Ex. Inject Access token to specified URL

// Here we create our logic to confirms RequestAdapter protocl 
// so we can set our Alamofire manager adapter to it.
class AccessTokenAdapter: RequestAdapter {
    private let accessToken: String
    
    init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    // Required function from RequestAdapter protocol
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        // Code for what we need to do in request befor it created.
        var urlRequest = urlRequest
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix("https://httpbin.org") {
            urlRequest.setValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        return urlRequest
    }
}

// Our singleton for AlamofireManager
class AlamofireManager {
    
    static let shared = AlamofireManager()
    var sessionManager: SessionManager!
    
    private init() {
        let configuration = URLSessionConfiguration.default
        sessionManager = Alamofire.SessionManager(configuration: configuration)
    }
    
}

// Create your custom tokens and inject them before any request as needed
let authHandler = AccessTokenAdapter(accessToken: "1234")
AlamofireManager.shared.sessionManager.adapter = authHandler
AlamofireManager.shared.sessionManager.request("https://httpbin.org/get")