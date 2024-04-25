

import Foundation
import Alamofire
import RxSwift
import RxAlamofire

struct ApiRequest {
    
    let method: HTTPMethod
    let endPoint: EndPoint
    var parameters: [String: Any]? = nil
    var encoding: ParameterEncoding = JSONEncoding.default
    
}

class ApiClient {
    
    var session: Session?
    let baseURL: URL?
    var headers: HTTPHeaders?
    var accessToken: String?
    var refreshToken: String?
    private let defaults = BetterUserDefaults(defaults: UserDefaults.standard)
    
    init(baseURL: URL? = nil) {
        self.baseURL = baseURL
        let configuration = URLSessionConfiguration.ephemeral
        session = Session(configuration: configuration)
        headers = headerData()
    }
    
    func loadRequest<T: Codable>(apiRequest: ApiRequest) -> Single<T> {
        headers = headerData()
        return request(apiRequest.method, path(apiRequest.endPoint.description), parameters: apiRequest.parameters, encoding: apiRequest.encoding, headers: headers)
            .validate { request, response, data in
                let statusCode  = response.statusCode
                if (statusCode <= 299 && statusCode >= 200 || statusCode == 400){
                    return .success(())
                } else {
                    let error = AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: response.statusCode))
                    return .failure(error)
                }
            }
            .responseString()
            .map { response, dataString in
                let jsonData = dataString.data(using: String.Encoding.utf8)!
                let baseApiResponse = try JSONDecoder().decode(T.self, from: jsonData)
                if response.statusCode == 400 {
                    let jsonFlow = baseApiResponse as? JSONFlow
                    if let nodes = jsonFlow?.ui?.nodes, !nodes.isEmpty {
                      for node in nodes {
                          if let messages = node?.messages, !messages.isEmpty {
                              let message = messages.first as? Message
                              throw APIError.apiError(message?.text ?? "")
                        }
                      }
                    }
                    if let messages = jsonFlow?.ui?.messages, !messages.isEmpty {
                        let message = messages.first as? Message
                        throw APIError.apiError(message?.text ?? "")
                    }
                }
                return baseApiResponse
            }
            .asSingle()
    }
    
    private func path(_ path: String) -> String {
        return (baseURL != nil) ? "\(baseURL!.absoluteString)\(path)" : path
    }
    
    func headerData() -> HTTPHeaders {
        var header = HTTPHeaders()
        
        if (accessToken != nil) {
            header.add(name: "Authorization", value: "Bearer \(accessToken ?? "")")
        }
        return header
    }
    
    func setAccessToken(token: String, refreshToken: String) {
        accessToken = token
        self.refreshToken = refreshToken
    }
    
}

enum EndPoint: CustomStringConvertible {
    
    case login(String)
    case register(String)
    case registrationFlow
    case loginFlow
    
    
    
    var description: String {
        switch self {
        case .login(let flowId): return "self-service/login?flow=\(flowId)"
        case .register(let flowId): return "self-service/registration?flow=\(flowId)"
        case .registrationFlow: return "self-service/registration/api"
        case .loginFlow: return "self-service/login/api"
        }
    }
}

enum DecodableError: Error {
    case illegalInput
}

extension Decodable {
    
    static func fromJSON(_ string: String?) throws -> Self {
        guard string != nil else { throw DecodableError.illegalInput }
        let data = string!.data(using: .utf8)!
        return try JSONDecoder().decode(self, from: data)
    }
    
}

enum APIError: Error {
    case apiError(String)
}

enum RefreshTokenError: Error {
    case refreshTokenExpired(String)
}

func parseError(_ error: Error) -> String? {
    var errorMessage = error.localizedDescription
    if let apiError = error as? APIError {
        switch apiError {
        case .apiError(let message):
            errorMessage = message
        }
    } else {
        if let afError = error as? AFError {
            if case .responseValidationFailed(let responseValidationError) = afError.underlyingError?.asAFError, case .customValidationFailed(let error) = responseValidationError {
                let apiError = error as? APIError
                switch apiError {
                case .apiError(let message):
                    errorMessage = message
                case .none:
                    errorMessage = "Something went wrong"
                }
            } else {
                errorMessage = "Something went wrong"
            }
        }
    }
    return errorMessage
}
