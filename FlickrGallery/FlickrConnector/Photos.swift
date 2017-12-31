//
//  Photos.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//

struct Photos: Codable {
    let photos: [Photo]?
    
    enum PhotosKeys: String, CodingKey {
        case photo = "photos"
    }
    
    enum PhotoKeys: String, CodingKey {
        case photo = "photo"
    }
    
    init(photos: [Photo]?) {
        self.photos = photos
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PhotosKeys.self)
        let photoContainer = try container.nestedContainer(keyedBy: PhotoKeys.self, forKey: .photo)
        
        let photos: [Photo] = try photoContainer.decode([Photo].self, forKey: .photo)
        
        self.photos = photos
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PhotosKeys.self)
        var photoContainer = container.nestedContainer(keyedBy: PhotoKeys.self, forKey: .photo)
        
        try photoContainer.encode(photos, forKey: .photo)
    }
}

// MARK: Equatable
extension Photos: Equatable { }

func ==(lhs: Photos, rhs: Photos) -> Bool {
    switch (lhs.photos, rhs.photos) {
    case (.some(let lhsValue), .some(let rhsValue)):
        return lhsValue == rhsValue
    case (.none, .none):
        return true
    default:
        return false
    }
}

