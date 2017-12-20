//
//  Photo.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//

import Argo
import Runes
import Curry

struct Photo {
    let id: String
    let title: String
    let sizes: [Size]?
    
    init(id: String, title: String) {
        self.id = id
        self.title = title
        self.sizes = nil
    }
}

extension Photo: Argo.Decodable {
    static func decode(_ json: JSON) -> Decoded<Photo> {
        return curry(Photo.init)
            <^> json <| "id"
            <*> json <| "title"
    }
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
