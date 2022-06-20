//
//  WebServiceLogger.swift
//  Stocks
//
//  Created by Furqan on 20/06/2022.
//

import Foundation

class WebServiceLogger {
    
    static func logRequest(endpoint: Endpoint) {
        print("\n****************")
        print(endpoint.fullURL)
        print("RQ_METHOD: ", endpoint.method.rawValue)
        print("RQ_HEADERS {")
        for (key, value) in endpoint.headers {
            print(key + " : " + value)
        }
        print("}")
        print("\nRQ_PARAMETERS {")
        endpoint.parameters?.forEach { print("\($0): \($1)") }
        print("}")
        print("******************************************************")
    }
    
}
