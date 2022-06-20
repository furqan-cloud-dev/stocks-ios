//
//  Webservice.swift
//  Stocks
//
//  Created by Furqan on 20/06/2022.
//


import Foundation
import Combine


enum APIError: Error, LocalizedError {
    case malformedURL, unknown, apiError(reason: String), parserError(reason: String), networkError(from: URLError)

    var errorDescription: String? {
        switch self {
        case .malformedURL:
            return "invalid url"
        case .unknown:
            return "Unknown error"
        case .apiError(let reason), .parserError(let reason):
            return reason
        case .networkError(let from):
            return from.localizedDescription
        }
    }
}


final class Webservice {
    
    let session = URLSession.shared
    
    func request<T: Codable>(ofType: T.Type, endpoint: Endpoint) -> AnyPublisher<T, APIError> {
        return processRequest(urlString: endpoint.fullURL, method: endpoint.method, parameters: endpoint.parameters, headers: endpoint.headers)
    }
    
    
    func processRequest<T: Codable>(urlString: String, method: HTTPMethod, parameters: [String: Any]?, parametersEncoding: ParameterEncoding = JSONEncoding.default, headers: [String: String]?) -> AnyPublisher<T, APIError> {
        
        
        guard let url = URL(string: urlString) else {
            return Result<T, APIError>
                .Publisher(.failure(.malformedURL))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // parameters encoding
        if let param = parameters {
            if method == .post {
                request = try! parametersEncoding.encode(request, with: param)
            }
            else if method == .get {
                request = try! URLEncoding.default.encode(request, with: param)
            }
        }
        
        print(parameters ?? [:])
        
        if let requestHeaders = headers {
            for (key, value) in requestHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
    
        /// Clear url cache -  if required
        URLCache.shared.removeAllCachedResponses()
        return performRequest(request: request)
    }
    
    
    func performRequest<T: Codable>(request: URLRequest) -> AnyPublisher<T, APIError> {
        return session
            .dataTaskPublisher(for: request)
            .tryMap({ data, response in
                
                print(response)
                print(data)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }
                if (httpResponse.statusCode == 401) {
                    throw APIError.apiError(reason: "Unauthorized")
                }
                if (httpResponse.statusCode == 403) {
                    throw APIError.apiError(reason: "Resource forbidden")
                }
                if (httpResponse.statusCode == 404) {
                    throw APIError.apiError(reason: "Resource not found")
                }
                if (httpResponse.statusCode == 400) {
                    throw APIError.apiError(reason: "bad request")
                }
                if (405..<500 ~= httpResponse.statusCode) {
                    throw APIError.apiError(reason: "client error")
                }
                if (500..<600 ~= httpResponse.statusCode) {
                    throw APIError.apiError(reason: "server error")
                }
                
                
                if ((200...299).contains(httpResponse.statusCode) == false) {
                    throw APIError.apiError(reason: "response is invalid")
                }
                
                return data
            })
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                print(error)
                
                if let error = error as? APIError {
                    return error
                }
                if let urlerror = error as? URLError {
                    return APIError.networkError(from: urlerror)
                }
                
                if let error = error as? DecodingError {
                    return APIError.parserError(reason: error.localizedDescription)
                }
                
                // if all else fails, return the unknown error condition
                return APIError.unknown
            }
            .eraseToAnyPublisher()
    }
    
    
    
    
    
    
    func fetch(request: URLRequest) -> AnyPublisher<Data, APIError> {
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.unknown
                }
                if (httpResponse.statusCode == 401) {
                    throw APIError.apiError(reason: "Unauthorized")
                }
                if (httpResponse.statusCode == 403) {
                    throw APIError.apiError(reason: "Resource forbidden")
                }
                if (httpResponse.statusCode == 404) {
                    throw APIError.apiError(reason: "Resource not found")
                }
                if (405..<500 ~= httpResponse.statusCode) {
                    throw APIError.apiError(reason: "client error")
                }
                if (500..<600 ~= httpResponse.statusCode) {
                    throw APIError.apiError(reason: "server error")
                }
                return data
            }
            .mapError { error in
                // if it's our kind of error already, we can return it directly
                if let error = error as? APIError {
                    return error
                }
                
                
                
        
                // if it is a TestExampleError, convert it into our new error type
//                if error is TestExampleError {
//                    return APIError.parserError(reason: "Our example error")
//                }
                // if it is a URLError, we can convert it into our more general error kind
                if let urlerror = error as? URLError {
                    return APIError.networkError(from: urlerror)
                }
                // if all else fails, return the unknown error condition
                return APIError.unknown
            }
            .eraseToAnyPublisher()
    }
    
}
