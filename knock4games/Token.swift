//
//  Token.swift
//  knock4games
//
//  Created by Pofat Tseng on 2017/5/7.
//  Copyright © 2017年 Pofat. All rights reserved.
//

import Foundation

struct Token {
    let name: String
    let token: String
    let iat: Date
    let exp: Date
    
    init?(data: Data) {
        guard let obj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            print("faile to get json")
            return nil
        }
        
        guard let tokenObj = obj?["token"] as? [String: Any] else {
            return nil
        }
        
        guard let name = tokenObj["name"] as? String else {
            return nil
        }
        
        guard let token = tokenObj["token"] as? String else {
            return nil
        }
        
        guard let iat = tokenObj["iat"] as? Double else {
            return nil
        }
        
        guard let exp = tokenObj["exp"] as? Double else {
            return nil
        }
        
        self.name = name
        self.token = token
        
        self.iat = Date(timeIntervalSince1970: iat)
        self.exp = Date(timeIntervalSince1970: exp)
    }
}


extension Token: Decodable {
    static func parseArray(data: Data) -> [Token]? {
        fatalError("Not implemented in this project. To make this work, please implement at \(#file), \(#line)")
    }
    
    static func parse(data: Data) -> Token? {
        return Token(data: data)
    }
}


struct TokenRequest: Request {
    let name: String
    let pwd: String
    var path: String { return "" }
    var parameter: [String : Any]? { return ["name" : name, "pwd": pwd] }
    let method: HTTPMethod = .post
    
    typealias Response = Token
}

