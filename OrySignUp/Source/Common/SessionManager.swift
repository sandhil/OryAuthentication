
import Foundation
import RxSwift
import Alamofire

class SessionManager {
    let defaults: BetterUserDefaults
    let backendClient: BackendClient
    init(backendClient: BackendClient, defaults: BetterUserDefaults) {
        self.backendClient = backendClient
        self.defaults = defaults
        self.user = defaults.user
    }
    
    private(set) var user: User? = nil {
        didSet {
            defaults.user = user
        }
    }
    
    var isLoggedIn: Bool? {
        get { return try? defaults.value(forKey: "isLoggedIn") }
        set { defaults.set(newValue, forKey: "isLoggedIn") }
    }
    
    func setUSer(user: User?) {
        self.user = user
    }
    
    func getLoginFlow() -> Single<JSONFlow> {
        let apiRequest: ApiRequest = ApiRequest(method: .get, endPoint: .loginFlow)
        return backendClient.load(request: apiRequest)
    }
    
    func getRegistrationFlow() -> Single<JSONFlow> {
        let apiRequest: ApiRequest = ApiRequest(method: .get, endPoint: .registrationFlow)
        return backendClient.load(request: apiRequest)
    }
    
    func signUp(flowId: String, parameters: [String : Any]) -> Single<JSONFlow> {
        let apiRequest: ApiRequest = ApiRequest(method: .post, endPoint: .register(flowId), parameters: parameters)
        return backendClient.load(request: apiRequest)
            .doOnSuccess { _ in
                let traits = parameters["traits"] as? [String: Any]
                let email = traits?["email"] as? String
                let userName = traits?["username"] as? String
                let user = User(userId: userName, email: email)
                self.setUSer(user: user)
                self.isLoggedIn = true
                
            }
    }
    
    func signIn(flowId: String, parameters: [String : Any]) -> Single<JSONFlow> {
        let apiRequest: ApiRequest = ApiRequest(method: .post, endPoint: .login(flowId), parameters: parameters)
        return backendClient.load(request: apiRequest)
            .doOnSuccess { _ in
                let userName = parameters["password_identifier"] as? String
                let user = User(userId: userName, email: userName)
                self.setUSer(user: user)
                self.isLoggedIn = true
                
            }
    }
    
}
