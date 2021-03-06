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
    static let key = "06100f51aea69eb90e9933cd56b3500c"
    
    var headers: [String : String]? {
        return nil
    }
    
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

class FlickrConnector {
    static let shared = FlickrConnector()
    
    let provider: MoyaProvider<FlickrConnectorTarget>
    
    init(provider: MoyaProvider<FlickrConnectorTarget> = MoyaProvider<FlickrConnectorTarget>()) {
        self.provider = provider
    }
    
    @discardableResult
    func search(tag: String, page: Int, completion: @escaping (((Photos?) -> ()))) -> Cancellable {
        print("Will search photos with tag: \(tag) and page: \(page)")
        
        return provider.request(.search(tag: tag, page: page)) { result in
            switch result {
            case .success(let response):
                do {
                    let photos: Photos? = try JSONDecoder().decode(Photos.self, from: response.data)
                    completion(photos)
                } catch let error {
                    print("Parsing failed with error: \(error)")
                    
                    completion(nil)
                }
            case .failure(let error):
                print("Failed with error: \(error)")
                
                completion(nil)
            }
        }
    }
    
    @discardableResult
    func sizes(id: String, completion: @escaping ((([Size]?) -> ())))  -> Cancellable {
        return provider.request(.sizes(id: id)) { result in
            switch result {
            case .success(let response):
                do {
                    let sizes: Sizes? = try JSONDecoder().decode(Sizes.self, from: response.data)
                    completion(sizes?.sizes)
                } catch let error {
                    print("Parsing failed with error: \(error)")
                    completion(nil)
                }
            case .failure(let error):
                print("Failed with error: \(error)")
                completion(nil)
                
            }
        }
    }
    
    func pinningManager() -> Manager {
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
