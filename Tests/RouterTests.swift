//
//  RouterTests.swift
//  Vapor
//
//  Created by Tanner Nelson on 2/18/16.
//  Copyright © 2016 Tanner Nelson. All rights reserved.
//

import XCTest

class RouterTests: XCTestCase {
    
    func testMultipleHostsRouting() {
        let router = NodeRouter()
        
        let data_1 = [UInt8]("1".utf8)
        let data_2 = [UInt8]("2".utf8)
        
        router.register(hostname: nil, method: .Get, path: "test") { request in
            return Response(status: .OK, data: data_1, contentType: .Text)
        }
        
        router.register(hostname: "vapor.test", method: .Get, path: "test") { request in
            return Response(status: .OK, data: data_2, contentType: .Text)
        }
        
        let request_1 = Request(method: .Get, path: "test", address: nil, headers: ["host": "other.test"], body: [])
        let request_2 = Request(method: .Get, path: "test", address: nil, headers: ["host": "vapor.test"], body: [])
        
        let handler_1 = router.route(request_1)
        let handler_2 = router.route(request_2)
        
        if let response_1 = handler_1?(request_1) {
            XCTAssert(response_1.data == data_1, "Incorrect response returned by Handler 1")
        } else {
            XCTFail("Handler 1 did not return a response")
        }
        
        if let response_2 = handler_2?(request_2) {
            XCTAssert(response_2.data == data_2, "Incorrect response returned by Handler 2")
        } else {
            XCTFail("Handler 2 did not return a response")
        }
    }
    
    func testURLParameterDecoding() {
        let router = NodeRouter()
        
        let percentEncodedString = "testing%20parameter%21%23%24%26%27%28%29%2A%2B%2C%2F%3A%3B%3D%3F%40%5B%5D"
        let decodedString = "testing parameter!#$&'()*+,/:;=?@[]"
        
        var handlerRan = false
        
        router.register(hostname: nil, method: .Get, path: "test/:string") { request in
            
            let testParameter = request.parameters["string"]
            
            XCTAssert(testParameter == decodedString, "URL parameter was not decoded properly")
            
            handlerRan = true
            
            return Response(status: .OK, data: [], contentType: .None)
        }
        
        let request = Request(method: .Get, path: "test/\(percentEncodedString)", address: nil, headers: [:], body: [])
        let handler = router.route(request)
        
        handler?(request)
        
        XCTAssert(handlerRan, "The handler did not run, and the parameter test also did not run")
    }
    
}
