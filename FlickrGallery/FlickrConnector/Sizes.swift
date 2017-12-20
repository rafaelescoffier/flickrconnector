//
//  Sizes.swift
//  FlickrGallery
//
//  Created by Rafael d'Escoffier on 14/09/17.
//  Copyright © 2017 Rafael Escoffier. All rights reserved.
//

import Argo
import Runes
import Curry

struct Sizes {
    let sizes: [Size]
}

extension Sizes: Argo.Decodable {
    static func decode(_ json: JSON) -> Decoded<Sizes> {
        return curry(Sizes.init)
            <^> json <|| ["size"]
    }
}

struct Size {
    let label: SizeType
    let source: String
    
    init(label: String, source: String) {
        self.label = SizeType(rawValue: label) ?? .unknown
        self.source = source
    }
}

extension Size: Argo.Decodable {
    static func decode(_ json: JSON) -> Decoded<Size> {
        return curry(Size.init)
            <^> json <| "label"
            <*> json <| "source"
    }
}

enum SizeType: String {
    case square = "Large Square"
    case large = "Large"
    case original = "Original"
    case unknown
}
