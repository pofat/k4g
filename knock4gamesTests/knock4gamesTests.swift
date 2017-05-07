//
//  knock4gamesTests.swift
//  knock4gamesTests
//
//  Created by Pofat Tseng on 2017/5/1.
//  Copyright © 2017年 Pofat. All rights reserved.
//

import XCTest
@testable import knock4games

class knock4gamesTests: XCTestCase {
    
    var sender: TestRequestSender!
    
    override func setUp() {
        super.setUp()
        
        sender = TestRequestSender()
    }
    
    override func tearDown() {
        
        sender = nil
        super.tearDown()
    }
    
    func testTokenRequest() {
        let tokenReq = TokenRequest(name: "ken", pwd: "hello")
        XCTAssertEqual(tokenReq.method, .post)
        
        sender.send(tokenReq) { token in
            XCTAssertNotNil(token)
            XCTAssertEqual(token!.name, "ken")
            XCTAssertEqual(token!.iat, Date(timeIntervalSince1970: 1482748545))
            XCTAssertEqual(token!.exp, Date(timeIntervalSince1970: 1482766545))
            XCTAssertEqual(token!.token, "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoia2VuIiwiaWF0IjoxNDgyNzQ4NTQ1LCJleHAiOjE0ODI3NjY1NDV9.BxQ5Ex7hhzXTMhb3EPl-9MdjFVy1ZCKLrGb19beaFns")
        }
    }
    
    func testMemberListRequest() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoia2VuIiwiaWF0IjoxNDgyNzQ4NTQ1LCJleHAiOjE0ODI3NjY1NDV9.BxQ5Ex7hhzXTMhb3EPl-9MdjFVy1ZCKLrGb19beaFns"
        
        let memberListReq = MemberListRequest(authToken: token)
        
        // assert request
        XCTAssertNotNil(memberListReq.extraHeader)
        XCTAssertEqual(memberListReq.extraHeader!.count, 1)
        XCTAssertEqual(memberListReq.extraHeader![0].key, "Authorization")
        XCTAssertEqual(memberListReq.extraHeader![0].value, token)
        
        sender.send(arrayReq: memberListReq) { memberList in
            
            // assert response
            XCTAssertNotNil(memberList)
            XCTAssertEqual(memberList!.count, 4)
            
            for i in 0 ..< memberList!.count {
                XCTAssertEqual(memberList![i].id, i + 1)
            }
        }
    }
    
    func testAddMemberRequest() {
        let token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoia2VuIiwiaWF0IjoxNDgyNzQ4NTQ1LCJleHAiOjE0ODI3NjY1NDV9.BxQ5Ex7hhzXTMhb3EPl-9MdjFVy1ZCKLrGb19beaFns"
        
        let addMemberReq = AddMemberReqeust(authToken: token)
        
        // assert request
        XCTAssertNotNil(addMemberReq.extraHeader)
        XCTAssertEqual(addMemberReq.extraHeader!.count, 1)
        XCTAssertEqual(addMemberReq.extraHeader![0].key, "Authorization")
        XCTAssertEqual(addMemberReq.extraHeader![0].value, token)
    }
}

struct TestRequestSender: RequestSender {
    func send<T : Request>(_ r: T, handler: @escaping (T.Response?) -> Void) {
        switch r.path {
        case "":
            guard let fileURL = Bundle(for: knock4gamesTests.self).url(forResource: "test_token", withExtension: "json") else {
                fatalError("File not accessible")
            }
            guard let data = try? Data(contentsOf: fileURL) else {
                fatalError("File read failed")
            }
            
            handler(T.Response.parse(data: data))
        default:
            fatalError("Unkown path")
        }
    }
    
    func send<T>(arrayReq r: T, handler: @escaping ([T.Response]?) -> Void) where T : Request {
        switch r.path {
        case "/member":
            guard let fileURL = Bundle(for: knock4gamesTests.self).url(forResource: "test_memberlist", withExtension: "json") else {
                fatalError("File not accessible")
            }
            guard let data = try? Data(contentsOf: fileURL) else {
                fatalError("File read failed")
            }
            
            handler(T.Response.parseArray(data: data))
        default:
            fatalError("Unkonw path")
        }
        
    }
    
    func send<T>(operationReq r: T, handler: @escaping (Bool) -> Void) where T : Request {
        // do nothing
    }
}


