//
//  Photo.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//

struct Photo: Decodable {
    let id: String
    let title: String
    let sizes: [Size]?
    
    
    enum PhotoKeys: String, CodingKey {
        case id = "id"
        case title = "title"
    }
    
    init(id: String, title: String) {
        self.id = id
        self.title = title
        self.sizes = nil
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PhotoKeys.self)
        
        let id: String = try container.decode(String.self, forKey: .id)
        let title: String = try container.decode(String.self, forKey: .title)
        
        self.id = id
        self.title = title
        self.sizes = nil
    }
}

extension Photo {
    
}

extension Photo {
    static func homeContentMatches(_ lhs: Photo, _ rhs: Photo) -> Bool {
        return lhs == rhs
    }
    
    static func homeContentMatches(_ lhs: [Photo], _ rhs: [Photo]) -> Bool {
        if lhs.count != rhs.count { return false }
        
        for (index, device) in lhs.enumerated() {
            if !homeContentMatches(rhs[index], device) {
                return false
            }
        }
        
        return true
    }
}

// MARK: Equatable
extension Photo: Equatable { }

func ==(lhs: Photo, rhs: Photo) -> Bool {
    return lhs.id == rhs.id
}
