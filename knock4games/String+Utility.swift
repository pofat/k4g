 //
//  String+Utility.swift
//  knock4games
//
//  Created by Pofat Diuit on 2017/5/8.
//  Copyright © 2017年 Pofat. All rights reserved.
//

import Foundation

extension String {
    static func random(length: Int) -> String {
        let letters = Array("abcdefghijklmnopqrstuvwxyz".characters)
        let len = UInt32(letters.count)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let index = arc4random_uniform(len)
            let nextChar = letters[Int(index)]
            randomString += String(nextChar)
        }
        
        return randomString
    }
}
