//
//  Photos.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//

struct Photos: Decodable {
    let photos: [Photo]?
    
    enum PhotosKeys: String, CodingKey {
        case photo = "photos"
    }
    
    enum PhotoKeys: String, CodingKey {
        case photo = "photo"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PhotosKeys.self)
        let photoContainer = try container.nestedContainer(keyedBy: PhotoKeys.self, forKey: .photo)
        
        let photos: [Photo] = try photoContainer.decode([Photo].self, forKey: .photo)
        
        self.photos = photos
    }
}


