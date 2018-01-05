//
//  FlickrTargetTests.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//

import XCTest
import Moya
@testable import FlickrGallery

class FlickrConnectorTests: XCTestCase {
    let timeout = 5.0
    let testPhotos = Photos(photos: [Photo(id: "testID", title: "testTitle")])
    let testSizes = Sizes(sizes: [
        Size(label: "Large Square", source: "testSource"),
        Size(label: "Large", source: "testSource"),
        ])
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSearch_ShouldSucceed() {
        let expectation = self.expectation(description: "Search")
        
        let flickrConnector = mockedConnector(responseObject: testPhotos)
        
        flickrConnector.search(tag: "kittens", page: 1) { (photos) in
            XCTAssertNotNil(photos)
            XCTAssertEqual(photos!, self.testPhotos)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSizes_ShouldSucceed() {
        let expectation = self.expectation(description: "Sizes")
        
        let flickrConnector = mockedConnector(responseObject: testSizes)
        
        flickrConnector.sizes(id: "31456463045") { (sizes) in
            XCTAssertNotNil(sizes)
            XCTAssertNotNil(sizes?.filter { $0.label == .square }.first)
            XCTAssertNotNil(sizes?.filter { $0.label == .large }.first)
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: timeout, handler: nil)
    }
}

extension FlickrConnectorTests {
    fileprivate func mockedConnector<T: Encodable>(responseObject: T) -> FlickrConnectorMocked {
        return FlickrConnectorMocked(responseObject: responseObject)
    }
}

class FlickrConnectorMocked: FlickrConnector {
    init<T: Encodable>(responseObject: T) {
        let response = try! JSONEncoder().encode(responseObject)
        
        let endpointClosure = { (target: FlickrConnectorTarget) -> Endpoint<FlickrConnectorTarget> in
            let url = URL(target: target).absoluteString
            return Endpoint(url: url,
                            sampleResponseClosure: { .networkResponse(200, response) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
        
        super.init(provider: MoyaProvider(
            endpointClosure: endpointClosure,
            stubClosure: MoyaProvider.delayedStub(0.5)
        ))
    }
}
