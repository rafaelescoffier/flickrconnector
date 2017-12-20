//
//  Photos.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//

import Argo
import Runes
import Curry

struct Photos {
    let photos: [Photo]?
}

extension Photos: Argo.Decodable {
    static func decode(_ json: JSON) -> Decoded<Photos> {
        return curry(Photos.init)
            <^> json <||? ["photo"]
    }
}
