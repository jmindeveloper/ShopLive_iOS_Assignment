//
//  ShopLive_iOS_Assignment_NetworkManagerTests.swift
//  ShopLive_iOS_AssignmentTests
//
//  Created by J_Min on 7/4/24.
//

import Foundation
import XCTest
//import Combine
@testable import ShopLive_iOS_Assignment

final class ShopLive_iOS_Assignment_NetworkManagerTests: XCTestCase {
    var networkManager: NetworkManager!
    var mockSession: MockURLSession!
    var resource: Resource!
    var subscriptions: Set<SLAnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        networkManager = NetworkManager(session: mockSession)
        resource = Resource(
            base: "https://example.com",
            path: "",
            params: [:]
        )
        subscriptions = Set<SLAnyCancellable>()
    }
    
    override func tearDown() {
        networkManager = nil
        mockSession = nil
        subscriptions = nil
        super.tearDown()
    }
    
    func test_getMarvelCharactersSuccess() async throws {
        // Given
        let jsonString = """
            {
                "data": {
                    "count": 1,
                    "results": [
                        {
                            "id": 1017100,
                            "name": "아이언맨",
                            "description": "블루스컬",
                            "thumbnail": {
                                "path": "http://example.com",
                                "extension": "jpg"
                            }
                        }
                    ]
                }
            }
            """
        mockSession.data = jsonString.data(using: .utf8)
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        do {
            try networkManager.getMarvelCharacters(resource: resource)
        } catch {
            XCTFail()
        }
        
        Thread.sleep(forTimeInterval: 0.5)
        
        // Then
        networkManager.characterPublisher
            .sink { characters in
                XCTAssertEqual(characters.count, 1)
                XCTAssertEqual(characters.first?.name, "아이언맨")
            }.store(in: &subscriptions)
    }
    
    func test_getMarvelCharactersFailure_badServerResponse() async throws {
        // Given
        mockSession.data = nil
        
        // When
        do {
            try networkManager.getMarvelCharacters(resource: resource)
        } catch {
            // Then
            XCTAssertEqual(error as? URLError, URLError(.badServerResponse))
        }
    }
    
    func test_getMarvelCharactersFailure_badURL() async throws {
        // Given
        mockSession.error = URLError(.badURL)
        
        // When
        do {
            try networkManager.getMarvelCharacters(resource: resource)
        } catch {
            // Then
            XCTAssertEqual(error as? URLError, URLError(.badURL))
        }
    }
    
    func test_getImageDataSuccess() async throws {
        // Given
        let imageData = "image_data".data(using: .utf8)
        mockSession.data = imageData
        
        mockSession.response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        
        // When
        let data = try await networkManager.getImageData(url: URL(string: "https://example.com"))
        
        // Then
        XCTAssertEqual(data, imageData)
    }
    
    func test_getImageDataFailure_badServerResponse() async throws {
        // Given
        mockSession.data = nil
        
        // When
        do {
            let data = try await networkManager.getImageData(url: URL(string: "https://example.com"))
            XCTFail()
        } catch {
            // Then
            XCTAssertEqual(error as? URLError, URLError(.badServerResponse))
        }
    }
    
    func test_getImageDataFailure_badURL() async throws {
        // Given
        mockSession.error = URLError(.badURL)
        
        // When
        do {
            let data = try await networkManager.getImageData(url: URL(string: "https://example.com"))
            XCTFail()
        } catch {
            // Then
            XCTAssertEqual(error as? URLError, URLError(.badURL))
        }
    }
}
