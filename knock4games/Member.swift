//
//  Member.swift
//  knock4games
//
//  Created by Pofat Tseng on 2017/5/7.
//  Copyright © 2017年 Pofat. All rights reserved.
//

import Foundation

struct Member {
    let id: Int
    let name: String
}

extension Member: Decodable {
    static func parse(data: Data) -> Member? {
        fatalError("Not implemented in this project. To make this work, please implement at \(#file), \(#line)")
    }
    
    static func parseArray(data: Data) -> [Member]? {
        guard let obj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let arrayObj = obj?["data"] as? [[String: Any]] else {
            return nil
        }
        
        guard arrayObj.count > 0 else {
            return []
        }
        
        var result: [Member] = []
        
        arrayObj.forEach {
            if let id = $0["ID"] as? Int, let name = $0["name"] as? String {
                result.append(Member(id: id, name: name))
            }
        }
        
        return result
    }
}

struct MemberListRequest: Request {
    let authToken: String
    
    // Request protocl
    var path: String { return "/member" }
    var extraHeader: [(key: String, value: String)]? {
        return [("Authorization", authToken)]
    }
    let method: HTTPMethod = .get
    
    typealias Response = Member
}

