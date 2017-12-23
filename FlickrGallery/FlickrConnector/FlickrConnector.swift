//
//  FlickrConnector.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//

import Moya
import Alamofire

enum FlickrConnectorTarget: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    static let key = "flickrKey"
    
    case search(tag: String, page: Int)
    case sizes(id: String)
    
    var baseURL: URL { return URL(string: "https://api.flickr.com")! }
    
    var path: String {
        switch self {
        case .search, .sizes:
            return "/services/rest/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .search, .sizes:
            return .get
        }
    }
    
    var parameters: [String: Any] {
        var params: [String: Any] = [
            "api_key" : FlickrConnectorTarget.key,
            "format" : "json",
            "nojsoncallback" : 1
        ]
        
        switch self {
        case .search(let tag, let page):
            params["method"] = "flickr.photos.search"
            params["tags"] = tag
            params["page"] = page
        case .sizes(let id):
            params["method"] = "flickr.photos.getSizes"
            params["photo_id"] = id
        }
        
        return params
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .search, .sizes:
            return URLEncoding.default
        }
        
    }
    
    var sampleData: Data {
        let sampleResponseName:String
        switch self {
        case .search:
            sampleResponseName = "search.json"
        case .sizes:
            sampleResponseName = "sizes.json"
        }
        
        let sampleResponsePath = Bundle.main.path(forResource: sampleResponseName, ofType: nil)!
        
        return (try! Data(contentsOf: URL(fileURLWithPath: sampleResponsePath)))
    }
    
    var task: Task {
        switch self {
        case .search, .sizes:
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
}

struct FlickrConnector {
    static let provider = MoyaProvider<FlickrConnectorTarget>()
    
    @discardableResult
    static func search(tag: String, page: Int, completion: @escaping (((Photos?) -> ()))) -> Cancellable {
        return provider.request(.search(tag: tag, page: page)) { result in
            switch result {
            case .success(let response):
                let photos: Photos? = try? response.mapObject(rootKey: "photos")
                completion(photos)
            case .failure(let error):
                print("Failed with error: \(error)")
                completion(nil)
            }
        }
    }
    
    @discardableResult
    static func sizes(id: String, completion: @escaping ((([Size]?) -> ())))  -> Cancellable {
        return provider.request(.sizes(id: id)) { result in
            switch result {
            case .success(let response):
                let sizes: Sizes? = try? response.mapObject(rootKey: "sizes")
                completion(sizes?.sizes)
            case .failure(let error):
                print("Failed with error: \(error)")
                completion(nil)
                
            }
        }
    }
    
    static func pinningManager() -> Manager {
        let policies: [String: ServerTrustPolicy] = [
            "api.flickr.com": .pinCertificates(
                certificates: ServerTrustPolicy.certificates(),
                validateCertificateChain: true,
                validateHost: false
            )
        ]
        
        let manager = Manager(
            configuration: URLSessionConfiguration.default,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: policies)
        )
        
        return manager
    }
}
