//
//  WebServiceConfiguration.swift
//  Stocks
//
//  Created by Furqan on 20/06/2022.
//

import Foundation

enum WebServiceEnvironment {
    case development, production
    
    func getString() -> String {
        switch self {
            case .development: return "DEV"
            case .production: return "PROD"
        }
    }
}


final class WebServiceConfiguration {
   
    static var customConfig = customConfiguration()
    
    static func customConfiguration() -> URLSessionConfiguration {
        /// Custom Configuration for URLSession
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        configuration.timeoutIntervalForRequest = 240
        configuration.timeoutIntervalForResource = 240
        return configuration
    }
    
    static func getEnviroment() -> WebServiceEnvironment {
        return .development
    }
}


protocol Endpoint {
    var baseURL: String { get } // https://server/api/1.0/
    var path: String { get } // /users/
    var fullURL: String { get } // This will automatically be set. https://server/api/1.0/user/
    var method: HTTPMethod { get } // .get
    var parameters: Dictionary<String,Any>? { get }
    var headers: [String: String] { get } // ["Authorization" : "Bearer SOME_TOKEN"]
}


extension Endpoint { // global settings
    
    var baseURL: String {
        if WebServiceConfiguration.getEnviroment() == .production {
            return Constants.URLs.API_BaseUrl
        }
        else {
            return Constants.URLs.API_BaseUrl
        }
    }
    
    var fullURL: String {
        return baseURL + path
    }
    
    
    var headers: [String: String] {
        var httpHeaders = [String: String]()
        httpHeaders["Content-Type"] = "application/json"  // the request is JSON
        httpHeaders["User-Agent"] = "IPHONE" // user agent
        httpHeaders["Accept"] = "application/json" // the response expected to be in JSON format
        return httpHeaders
    }
     
    
}


/// Serializers to process Request & Responses

protocol ResponseSerializer {
    func serialize(data: Data) -> Data?
}


protocol RequestSerializer {
    func serialize(parameters: [String: Any]) -> [String: Any]
}
