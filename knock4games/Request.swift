//
//  Request.swift
//  knock4games
//
//  Created by Pofat Tseng on 2017/5/7.
//  Copyright © 2017年 Pofat. All rights reserved.
//

import Foundation

// Request method
enum HTTPMethod {
    case post, get
}

extension HTTPMethod: RawRepresentable {
    typealias RawValue = String
    
    init?(rawValue: RawValue) {
        switch rawValue {
        case "get", "GET":
            self = .get
        case "post", "POST":
            self = .post
        default:
            return nil
        }
    }
    
    var rawValue: RawValue {
        switch self {
        case .post:
            return "POST"
        case .get:
            return "GET"
        }
    }
}

// Main protocol for request
protocol Request {
    var path: String { get }
    var method: HTTPMethod { get }
    var parameter: [String: Any]? { get }
    var extraHeader: [(key: String, value: String)]? { get }
    
    associatedtype Response: Decodable
}

extension Request {
    var parameter: [String: Any]? {
        return nil
    }
    
    var extraHeader: [(key: String, value: String)]? {
        return nil
    }
}



protocol RequestSender {
    var host: String { get }
    func send<T: Request>(_ r: T, handler: @escaping (T.Response?) -> Void )
    func send<T: Request>(arrayReq r: T, handler: @escaping ([T.Response]?) -> Void)
    func send<T: Request>(operationReq r: T, handler: @escaping(Bool) -> Void)
}

extension RequestSender {
    var host: String {
        return "http://52.197.192.141:3443"
    }
}


// Struct to handle network request
struct URLSessionRequestSender: RequestSender {
    // Request of single element in response
    func send<T : Request>(_ r: T, handler: @escaping (T.Response?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: requestBuilder(r)) { data, res, error in
            if let data = data, let res = T.Response.parse(data: data) {
                DispatchQueue.main.async {
                    handler(res)
                }
            } else {
                DispatchQueue.main.async {
                    handler(nil)
                }
            }
        }
        
        task.resume()
    }
    // Reuqest of element array in response
    func send<T: Request>(arrayReq r: T, handler: @escaping ([T.Response]?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: requestBuilder(r)) {
            data, res, error in
            if error == nil, let data = data, let res = T.Response.parseArray(data: data) {
                DispatchQueue.main.async {
                    handler(res)
                }
            } else {
                DispatchQueue.main.async {
                    handler(nil)
                }
            }
        }
        task.resume()
    }
    
    func send<T: Request>(operationReq r: T, handler: @escaping(Bool) -> Void) {
        
        let task = URLSession.shared.dataTask(with: requestBuilder(r)) {
            data, res, error in
            if error == nil, let response = res as? HTTPURLResponse, response.statusCode == 200 {
                DispatchQueue.main.async { handler(true) }
            } else {
                DispatchQueue.main.async { handler(false) }
            }
        }
        
        task.resume()
    }
    
    private func requestBuilder<T: Request>(_ r: T) -> URLRequest {
        let url = URL(string: host.appending(r.path))!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let extraHeader = r.extraHeader {
            extraHeader.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        }
        request.httpMethod = r.method.rawValue
        
        if let body = r.parameter, let data = try? JSONSerialization.data(withJSONObject: body, options: []) {
            request.httpBody = data
        }
        
        return request
    }
}



// Object protocol
protocol Decodable {
    static func parse(data: Data) -> Self?
    static func parseArray(data: Data) -> [Self]?
}
