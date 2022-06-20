//
//  URLConvertible.swift
//  Stocks
//
//  Created by Furqan on 20/06/2022.
//

import Foundation


/// Types adopting the `URLConvertible` protocol can be used to construct URLs, which are then used to construct
/// URL requests.
public protocol URLConvertible {
    /// Returns a URL that conforms to RFC 2396 or throws an `Error`.
    ///
    /// - throws: An `Error` if the type cannot be converted to a `URL`.
    ///
    /// - returns: A URL or throws an `Error`.
    func asURL() throws -> URL
}

extension String: URLConvertible {
    /// Returns a URL if `self` represents a valid URL string that conforms to RFC 2396 or throws an Error.
    ///
    /// - throws: invalidURL` if `self` is not a valid URL string.
    ///
    /// - returns: A URL or throws an Error.
    public func asURL() throws -> URL {
        guard let url = URL(string: self) else { throw CEError.invalidURL(url: self) }
        return url
    }
}

extension URL: URLConvertible {
    /// Returns self.
    public func asURL() throws -> URL { return self }
}

extension URLComponents: URLConvertible {
    /// Returns a URL if `url` is not nil, otherwise throws an `Error`.
    ///
    /// - throws: An invalidURL` if `url` is `nil`.
    ///
    /// - returns: A URL or throws an Error
    public func asURL() throws -> URL {
        guard let url = url else { throw CEError.invalidURL(url: self) }
        return url
    }
}

// MARK: -

/// Types adopting the `URLRequestConvertible` protocol can be used to construct URL requests.
public protocol URLRequestConvertible {
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`
    ///
    /// - returns: A URL request.
    func asURLRequest() throws -> URLRequest
}

extension URLRequestConvertible {
    /// The URL request.
    public var urlRequest: URLRequest? { return try? asURLRequest() }
}

extension URLRequest: URLRequestConvertible {
    /// Returns a URL request or throws if an `Error` was encountered.
    public func asURLRequest() throws -> URLRequest { return self }
}


