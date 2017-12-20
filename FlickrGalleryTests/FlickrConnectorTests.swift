//
//  FlickrTargetTests.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//

import XCTest
@testable import FlickrGallery

class FlickrConnectorTests: XCTestCase {
    let timeout = 5.0
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSearch_ShouldSucceed() {
        let expectation = self.expectation(description: "Search")
        
        FlickrConnector.search(tag: "kittens", page: 1) { (photos) in
            XCTAssertNotNil(photos)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSizes_ShouldSucceed() {
        let expectation = self.expectation(description: "Sizes")
        
        FlickrConnector.sizes(id: "31456463045") { (sizes) in
            XCTAssertNotNil(sizes)
            XCTAssertNotNil(sizes?.filter { $0.label == .square }.first)
            XCTAssertNotNil(sizes?.filter { $0.label == .large }.first)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
}
